# Architecture — Allumé

## Vue d'ensemble

```
                    SOURCES OFFICIELLES & RELAIS
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
   togoactualite.com    republiquetogolaise.com  togofirst.com
   icilome.com          impartialactu.tg         newafrique.net
   ceet.tg (OCR)
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              ▼
                   [GitHub Actions, cron 30 min]
                   Pipeline scraper unifié
                              │
                              ▼
              ┌───────────────────────────────┐
              │  Supabase (PostgreSQL+PostGIS)│
              │  - sources                    │
              │  - raw_articles               │
              │  - outage_events              │
              │  - outage_versions            │
              │  - zones                      │
              │  - device_signals             │
              │  - community_outages          │
              └───────────────────────────────┘
                ▲           │              ▲
                │           │ Realtime     │
        signaux │           ▼              │ lecture
        capteurs│      [Flutter App]       │
                │           │              │
                │           └──────────────┘
                │
       [FastAPI / Fly.io]
       - POST /signals
       - GET  /outages
       - GET  /zones/{id}/status
              ▲
              │ FCM
              ▼
       [Notifications push]
```

---

## Composants

### 1. Application Flutter (mobile/)

Rôle : interface utilisateur, capteurs, affichage carte.

Responsabilités :
- Écran d'accueil : état du courant dans la zone de l'utilisateur
- Carte : zones de Lomé colorées par état (vert/rouge/gris)
- Service en arrière-plan (Foreground Service) : écoute les événements capteurs
- Bouton de signalement manuel (poids 50% dans l'algorithme)
- Envoi des signaux anonymisés à l'API
- Réception des mises à jour temps réel via Supabase Realtime

Capteurs surveillés :
- Déconnexion Wi-Fi (NetworkCallback, temps réel)
- Changement d'état de charge batterie (BroadcastReceiver, temps réel)
- Chute du niveau sonore (mesure 5s toutes les 10 min)
- Chute de luminosité la nuit (capteur ambiant, temps réel)

### 2. FastAPI (backend/api/)

Hébergement : Fly.io free tier (always-on, 256MB RAM)

Rôle : logique serveur, agrégation des signaux, détection des coupures.

Endpoints principaux :
- POST /signals — reçoit un signal anonyme depuis l'app
- GET /outages — liste les coupures en cours (officielles + communautaires)
- GET /zones/{id}/status — état d'une zone spécifique

Logique de détection :
- Agrège les signaux par zone et fenêtre de 15 minutes
- Calcule un score pondéré (voir DECISIONS.md DEC-006)
- Si score > 0.6 ET signaux de 2+ appareils différents → coupure communautaire confirmée
- Si score < 0.2 pendant 30 min → coupure terminée

### 3. Pipeline scraper (backend/scraper/)

Exécution : GitHub Actions, cron unique toutes les 30 minutes.

Architecture par adaptateurs : un fichier Python par source dans `sources/`,
implémentant l'interface `Source` (méthodes `discover_recent()` et `extract(url)`).

Pipeline en 6 étapes :

```
1. DÉCOUVERTE
   Pour chaque source active (selon le tier et l'heure courante) :
     - Récupère les URLs récentes (RSS, page de catégorie, etc.)
     - Filtre par mots-clés dans le titre (CEET, coupure, électricité, ...)
     - Élimine les URLs déjà en base (raw_articles.source_url UNIQUE)

2. EXTRACTION
   Pour chaque nouvelle URL :
     - Télécharge la page
     - Extrait titre + texte propre
     - Stocke dans raw_articles avec parse_status='pending'

3. CLASSIFICATION
   Détermine le type de communiqué :
     - 'planned_outage' : coupure programmée avec dates/heures/zones
     - 'unplanned'      : panne ou interruption sans détails structurés
     - 'admin'          : paiements, fraude, marchés publics, etc.
   Si admin → on archive et on s'arrête là.

4. PARSING STRUCTURE
   Pour les 'planned_outage' uniquement :
     - Regex sur le pattern standard "Le X, de YH à ZH, zones..."
     - Mappage des noms de zones bruts vers la table zones
     - Si regex échoue → parse_status='failed' (LLM fallback en Phase 2+)

5. DÉDUPLICATION
   - Calcule event_hash = sha256(date + heure_début + sorted(zones))
   - Si event_hash existe dans outage_events :
       → on crée juste une nouvelle outage_version liée à l'event existant
       → on met à jour has_conflicts si les heures divergent
   - Sinon → on crée un nouvel outage_event + outage_version

6. ÉCRITURE
   - INSERT dans outage_events si nouveau
   - INSERT dans outage_versions (toujours, une par source)
   - INSERT dans outage_event_zones pour les zones identifiées
   - UPDATE source_count et has_conflicts sur l'event
```

Sources, par tier :

| Tier | Sources | Fréquence |
|------|---------|-----------|
| 1    | Togo Actualité, République Togolaise, Togo First | toutes les 30 min |
| 2    | Icilome, Impartial Actu, New Afrique | toutes les heures (heures paires) |
| 3    | ceet.tg (OCR Tesseract) | toutes les 4 heures |

Voir DECISIONS.md DEC-013 pour les détails du workflow GitHub Actions.

### 4. Supabase (base de données)

PostgreSQL 15 + PostGIS, hébergé sur Supabase free tier.

Tables principales : voir DECISIONS.md DEC-012 (schéma révisé multi-sources).

Fonctionnalités utilisées :
- REST API auto-générée (lecture publique des coupures)
- Realtime (WebSocket pour mises à jour live dans l'app)
- Auth (comptes utilisateurs optionnels)
- PostGIS (polygones des quartiers, requêtes géospatiales)

---

## Flux de données — détection d'une coupure

### Cas 1 : Coupure programmée annoncée par la CEET

```
1. CEET poste un communiqué sur Facebook / Togo Actualité le relaie
2. Cron GitHub Actions exécute le pipeline (sous 30 min)
3. Source togoactualite découvre l'article via RSS
4. Pipeline classifie 'planned_outage', extrait dates/heures/zones
5. INSERT dans outage_events
6. Supabase Realtime notifie les apps abonnées
7. FCM envoie une notification "Coupure prévue jeudi 9h-15h dans ta zone"
```

### Cas 2 : Coupure imprévue détectée par les utilisateurs

```
1. Le courant coupe chez plusieurs utilisateurs d'une même zone
2. Leur Wi-Fi tombe → Flutter détecte via NetworkCallback
3. Leur téléphone se débranche → Flutter détecte via BatteryEvent
4. Flutter calcule un score local (> seuil minimal)
5. Flutter envoie POST /signals avec : zone_id, signal_type, score, session_id anonyme
6. FastAPI agrège avec les signaux des autres appareils dans la même zone
7. Si score agrégé > 0.6 ET 2+ appareils → INSERT dans community_outages
8. Supabase Realtime notifie les apps abonnées à cette zone
9. FCM envoie une notification push aux utilisateurs de la zone
```

### Cas 3 : Conflit entre sources

```
1. Togo Actualité dit : coupure 9h-14h zones A, B
2. Icilome dit       : coupure 9h-15h zones A, B
3. Pipeline détecte le même event_hash mais des heures différentes
4. outage_events.has_conflicts = true
5. outage_events.best_starts_at = 9h, best_ends_at = 15h (fenêtre la plus prudente)
6. App affiche "Coupure prévue 9h-15h (2 sources, durée incertaine)"
7. Utilisateur peut consulter chaque version source par source
```

---

## Contraintes techniques

- **Budget : 0 FCFA.** Toute l'infrastructure utilise des free tiers durables.
- **Batterie :** le service en arrière-plan doit consommer le minimum possible.
  Pas de GPS continu, pas de scan Wi-Fi actif fréquent.
- **Réseau :** l'app doit fonctionner en mode dégradé si le réseau est faible.
  Les signaux sont mis en file d'attente et envoyés dès que le réseau revient.
- **Vie privée :** aucun identifiant utilisateur n'est envoyé avec les signaux.
  La zone est déterminée sur l'appareil, jamais les coordonnées GPS brutes.
- **Téléphones cibles :** Tecno, Itel, Infinix, Samsung Galaxy A-series.
  Ces appareils ont des tueurs de processus agressifs — le Foreground Service
  avec notification persistante est obligatoire pour survivre en arrière-plan.
- **Robustesse aux silences :** le scraper doit pouvoir tourner pendant des
  semaines sans trouver de communiqué pertinent (quand la CEET se tait) sans
  planter ni générer d'alertes.
