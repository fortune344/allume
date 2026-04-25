# Journal des décisions — Allumé

Ce fichier log les décisions importantes : pourquoi on a choisi X plutôt que Y.
Il sert de mémoire pour les 6 prochains mois, pas de documentation exhaustive.

---

## DEC-001 — Flutter plutôt que React Native

Date : 2026-04-25

Décision : Flutter (Dart) pour l'application mobile.

Pourquoi :
- Meilleur accès aux capteurs natifs Android via des plugins bien maintenus
  (flutter_foreground_task, battery_plus, noise_meter, wifi_scan, light_sensor)
- Performances supérieures sur les appareils Tecno/Itel/Infinix (compilé nativement)
- Rendu identique sur tous les constructeurs Android, important vu la fragmentation
  des ROM custom (HIOS, XOS sur Transsion)
- React Native Expo nécessiterait le "bare workflow" pour accéder aux capteurs natifs,
  ce qui ajoute de la complexité sans avantage réel pour notre cas d'usage

Alternative rejetée : React Native (Expo)

---

## DEC-002 — Supabase plutôt qu'une base auto-hébergée

Date : 2026-04-25

Décision : Supabase (free tier) pour PostgreSQL + PostGIS + Auth + Realtime.

Pourquoi :
- PostGIS inclus et configuré (essentiel pour les polygones de quartiers)
- Realtime WebSocket inclus (mises à jour live dans l'app sans polling)
- Auth intégré (on n'a pas à gérer JWT/sessions soi-même)
- REST API auto-générée pour la lecture des données publiques
- Free tier largement suffisant : 500MB DB, 50k MAU, 2GB bande passante
- Projet restera actif grâce au scraper qui tourne toutes les 6h
  (Supabase met en pause les projets inactifs depuis 7 jours)

Alternative rejetée : PostgreSQL auto-hébergé sur Fly.io
Raison du rejet : ajoute de la maintenance (backups, mises à jour) sans avantage réel à notre échelle.

---

## DEC-003 — GitHub Actions pour le scraper

Date : 2026-04-25

Décision : GitHub Actions avec cron toutes les 6 heures pour lancer le scraper CEET.

Pourquoi :
- Gratuit (illimité sur repo public, 2000 min/mois sur repo privé)
- Le scraper tourne environ 600 min/mois → bien en dessous des limites
- Logs accessibles directement depuis GitHub
- Pas de serveur supplémentaire à maintenir pour une tâche aussi simple
- Séparé de l'API : un bug dans le scraper n'affecte pas la disponibilité de l'API

Fréquence : toutes les 6 heures (00h, 06h, 12h, 18h UTC)
Raison : la CEET poste rarement plus d'une annonce par jour. 6h est un bon compromis
entre réactivité et économie de quota.

---

## DEC-004 — Fly.io pour FastAPI

Date : 2026-04-25

Décision : FastAPI sur Fly.io free tier pour la logique serveur.

Pourquoi :
- Free tier always-on (pas de cold start comme Render)
- 3 machines 256MB incluses gratuitement
- FastAPI en Python est cohérent avec le scraper (même langage, même écosystème)
- Séparation claire : Supabase stocke les données, FastAPI fait la logique

Alternative rejetée : Render (cold start de 30s après 15 min d'inactivité)
Alternative rejetée : Supabase Edge Functions (limite CPU de 50ms par invocation,
trop contraignant pour l'agrégation de signaux)

---

## DEC-005 — Schéma de base de données

Date : 2026-04-25

Tables :

zones
  id UUID PK
  name TEXT                    -- "Bè", "Tokoin"
  synonyms TEXT[]              -- ["Bè-Kpota", "marché de Bè", ...]
  geometry GEOMETRY(POLYGON)   -- PostGIS, SRID 4326
  arrondissement TEXT

ceet_announcements
  id UUID PK
  scraped_at TIMESTAMPTZ
  source_url TEXT
  raw_text TEXT
  published_date DATE
  parse_status TEXT            -- 'ok', 'partial', 'failed'

planned_outages
  id UUID PK
  announcement_id UUID FK → ceet_announcements
  zone_id UUID FK → zones
  starts_at TIMESTAMPTZ
  ends_at TIMESTAMPTZ
  status TEXT                  -- 'upcoming', 'active', 'done'

device_signals
  id UUID PK
  created_at TIMESTAMPTZ
  zone_id UUID FK → zones
  signal_type TEXT             -- 'wifi_disconnect', 'unplug', 'sound_drop', 'light_drop', 'manual'
  score FLOAT                  -- 0.0 à 1.0
  session_id TEXT              -- ID rotatif anonyme, jamais lié à un utilisateur réel
  TTL : supprimé après 7 jours (données de travail, pas d'historique)

community_outages
  id UUID PK
  zone_id UUID FK → zones
  detected_at TIMESTAMPTZ
  ended_at TIMESTAMPTZ
  confidence FLOAT             -- 0.0 à 1.0
  signal_count INT

---

## DEC-006 — Algorithme de détection, poids des signaux

Date : 2026-04-25

Poids initiaux (à ajuster avec les données terrain) :

  Signalement manuel          50%   (intentionnel, explicite, très fiable)
  Déconnexion Wi-Fi           30%   (temps réel via NetworkCallback)
  Débranchement batterie      15%   (temps réel via BroadcastReceiver)
  Chute sonore ambiant        10%   (périodique, toutes les 10 min)
  Chute luminosité (nuit)      5%   (temps réel, contextuel)
  Wi-Fi voisins disparus       5%   (scan passif, max 1x/30 min sur Android 9+)

Note : les poids dépassent 100% car les signaux sont rarement tous présents en même temps.
En pratique, on somme les signaux présents et on normalise.

Seuil de déclenchement côté serveur :
  Score agrégé > 0.6 ET signaux de 2+ appareils distincts → coupure confirmée
  Score agrégé > 0.6 ET 1 seul appareil → alerte personnelle uniquement
  Score < 0.2 pendant 30 min → coupure terminée

Raison des 2 appareils minimum : évite les faux positifs dus à un utilisateur
qui débranche son téléphone de la prise pour partir de chez lui.

---

## DEC-007 — Vie privée des signaux

Date : 2026-04-25

Données envoyées au backend :
  - zone_id (déterminé sur l'appareil à partir de la position GPS, jamais envoyé)
  - signal_type
  - score normalisé
  - session_id rotatif (renouvelé toutes les 24h, jamais lié à un compte)

Données qui ne quittent jamais le téléphone :
  - Coordonnées GPS précises
  - Contenu audio (on envoie uniquement le niveau dB)
  - SSIDs ou BSSIDs des réseaux Wi-Fi voisins
  - Tout identifiant permanent (IMEI, Android ID)

---

## DEC-008 — Distribution initiale sans Play Store

Date : 2026-04-25

Décision : distribution par APK direct pour la phase bêta.

Pourquoi :
  - Compte Play Store coûte 25 USD one-time (pas de budget)
  - La bêta cible 10-50 personnes du réseau personnel
  - APK direct via lien de téléchargement suffit largement pour cette phase
  - Le compte Play Store sera créé quand on aura 100+ utilisateurs satisfaits
    et une V1 stable à publier

Hébergement de l'APK : GitHub Releases (gratuit, dans le même repo)
