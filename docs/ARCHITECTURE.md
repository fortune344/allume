# Architecture — Allumé

## Vue d'ensemble

```
[Flutter App] ──── lecture données ────► [Supabase]
[Flutter App] ──── signaux capteurs ───► [FastAPI / Fly.io] ──► [Supabase]
[GitHub Actions] ─ scraper cron ───────► [Supabase]
[Supabase] ──────── realtime ──────────► [Flutter App]
[FastAPI] ──────── notification ───────► [FCM] ──► [Flutter App]
```

---

## Composants

### 1. Application Flutter (mobile/)

Rôle : interface utilisateur, capteurs, affichage carte.

Responsabilités :
- Écran d'accueil : état du courant dans la zone de l'utilisateur
- Carte : zones de Lomé colorées par état (vert/rouge/gris)
- Service en arrière-plan (Foreground Service) : écoute les événements capteurs
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
- Calcule un score pondéré (voir DECISIONS.md pour les poids)
- Si score > 0.6 ET signaux de 2+ appareils différents → coupure communautaire confirmée
- Si score < 0.2 pendant 30 min → coupure terminée

### 3. Scraper CEET (backend/scraper/)

Exécution : GitHub Actions, cron toutes les 6 heures

Rôle : surveiller ceet.tg, extraire les nouvelles annonces, les stocker.

Flux :
1. Télécharge https://www.ceet.tg/tg/?cat=10 (liste des communiqués)
2. Compare avec les URLs déjà en base pour éviter les doublons
3. Pour chaque nouveau communiqué : télécharge la page, extrait texte
4. Parse le texte avec regex pour extraire dates/heures/zones
5. Mappe les noms de zones vers les zones OSM connues
6. Écrit dans Supabase

### 4. Supabase (base de données)

PostgreSQL 15 + PostGIS, hébergé sur Supabase free tier.

Tables principales : voir DECISIONS.md — Schéma de base de données.

Fonctionnalités utilisées :
- REST API auto-générée (lecture publique des coupures)
- Realtime (WebSocket pour mises à jour live dans l'app)
- Auth (comptes utilisateurs optionnels)
- PostGIS (polygones des quartiers, requêtes géospatiales)

---

## Flux de données — détection d'une coupure

```
1. Le courant coupe chez l'utilisateur
2. Son Wi-Fi tombe → Flutter détecte via NetworkCallback
3. Son téléphone se débranche → Flutter détecte via BatteryEvent
4. Flutter calcule un score local (> seuil minimal)
5. Flutter envoie POST /signals avec : zone_id, signal_type, score, session_id anonyme
6. FastAPI agrège avec les signaux des autres appareils dans la même zone
7. Si score agrégé > 0.6 ET 2+ appareils → INSERT dans community_outages
8. Supabase Realtime notifie les apps abonnées à cette zone
9. FCM envoie une notification push aux utilisateurs de la zone
```

---

## Contraintes techniques

- Budget : 0 FCFA. Toute l'infrastructure utilise des free tiers durables.
- Batterie : le service en arrière-plan doit consommer le minimum possible.
  Pas de GPS continu, pas de scan Wi-Fi actif fréquent.
- Réseau : l'app doit fonctionner en mode dégradé si le réseau est faible.
  Les signaux sont mis en file d'attente et envoyés dès que le réseau revient.
- Vie privée : aucun identifiant utilisateur n'est envoyé avec les signaux.
  La zone est déterminée sur l'appareil, jamais les coordonnées GPS brutes.
- Téléphones cibles : Tecno, Itel, Infinix, Samsung Galaxy A-series.
  Ces appareils ont des tueurs de processus agressifs — le Foreground Service
  avec notification persistante est obligatoire pour survivre en arrière-plan.
