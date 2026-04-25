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

---

## DEC-009 — Pivot stratégique : le scraper devient secondaire

Date : 2026-04-25

Constat terrain : ceet.tg ne publie quasi plus de communiqués détaillés sur les
coupures programmées depuis fin janvier 2026. Tous les communiqués restants sont
des images JPG (pas du HTML texte). La CEET communique principalement via Facebook
et les sites de presse togolais qui relaient les annonces.

Décision : le scraper de communiqués officiels reste utile mais cesse d'être le
cœur de l'app. La détection automatique multi-capteurs sur les téléphones devient
la source de données principale.

Conséquences :
  - Le scraper doit être robuste aux silences (pas planter quand il ne trouve rien)
  - Le scraper doit être modulaire (ajout/retrait de sources sans tout casser)
  - L'app affiche les coupures communautaires en priorité, les annonces officielles
    en complément
  - Argument produit renforcé : Allumé est utile précisément parce que la CEET
    communique mal

---

## DEC-010 — Architecture multi-sources par adaptateurs

Date : 2026-04-25

Décision : le scraper agrège plusieurs sources avec une architecture par adaptateurs.

Sources prévues, par tier :

  Tier 1 (sources principales) :
    - Togo Actualité (togoactualite.com)        — RSS WordPress confirmé
    - République Togolaise (republiquetogolaise.com)
    - Togo First (togofirst.com)                — bloque le bot, à investiguer

  Tier 2 (sources secondaires) :
    - Icilome (icilome.com)
    - Impartial Actu (impartialactu.tg)
    - New Afrique (newafrique.net)

  Tier 3 (origine officielle, peu utile actuellement) :
    - ceet.tg                                   — OCR Tesseract pour les rares
                                                  communiqués utiles qui y reparaissent

Interface commune (`Source` protocol) :
  - discover_recent() → liste d'URLs candidates
  - extract(url) → RawArticle standardisé

Filtre de pré-sélection sur le titre (mots-clés "CEET", "coupure", "électricité",
"délestage", "interruption", "fourniture") avant tout fetch de page complète.

Pourquoi cette architecture :
  - Ajouter une 7ème source = créer un fichier de 50 lignes
  - Si une source change son HTML, ça ne casse que cette source-là
  - Le pipeline central ne connaît pas les détails de chaque source

---

## DEC-011 — Déduplication et gestion des conflits

Date : 2026-04-25

Trois niveaux de déduplication :

  Niveau A (URL) : on ne reprocesse jamais la même URL d'article.
  Niveau B (event hash) : sha256(date_coupure + heure_début + sorted(zones)).
                          Si deux sources rapportent les mêmes faits, même hash,
                          elles sont liées au même outage_event.
  Niveau C (conflits) : si deux sources rapportent même date+zones mais heures
                        différentes, on stocke les deux versions et on flag
                        l'événement avec has_conflicts = true.

Gestion des conflits côté affichage :
  - On présente la fenêtre la plus prudente (début le plus tôt, fin la plus tard).
    Si on annonce 9h-15h et que c'est 9h-14h, l'utilisateur est agréablement surpris.
    L'inverse est inacceptable.
  - On affiche le nombre de sources qui ont confirmé (ex: "3 sources, 1 divergente").
  - L'utilisateur peut consulter chaque version source par source si besoin.

Pas de pondération de fiabilité par source au démarrage :
  - On n'a pas de données pour dire "Togo First est plus fiable qu'Icilome"
  - On observera les patterns sur 2-3 mois avant d'introduire des poids

---

## DEC-012 — Schéma de base de données révisé (supersède DEC-005)

Date : 2026-04-25

Nouvelles tables (multi-sources) :

  sources
    id UUID PK
    name TEXT                 -- 'togoactualite', 'republiquetogo', etc.
    base_url TEXT
    tier INT                  -- 1, 2, 3
    is_active BOOLEAN
    -- pas de reliability_weight tant qu'on n'a pas de données

  raw_articles
    id UUID PK
    source_id UUID FK → sources
    source_url TEXT UNIQUE    -- URL originale, sert à la dédup niveau A
    scraped_at TIMESTAMPTZ
    title TEXT
    content_text TEXT
    content_image_urls TEXT[] -- pour les communiqués avec images
    classification TEXT       -- 'planned_outage' | 'unplanned' | 'admin' | 'unknown'
    parse_status TEXT         -- 'ok' | 'partial' | 'failed'

  outage_events
    id UUID PK
    event_hash TEXT UNIQUE    -- dédup niveau B
    primary_date DATE
    best_starts_at TIMESTAMPTZ
    best_ends_at TIMESTAMPTZ
    has_conflicts BOOLEAN
    source_count INT
    created_at TIMESTAMPTZ

  outage_versions
    id UUID PK
    outage_event_id UUID FK → outage_events
    raw_article_id UUID FK → raw_articles
    starts_at TIMESTAMPTZ
    ends_at TIMESTAMPTZ
    zones JSONB               -- noms bruts extraits, avant mappage

  outage_event_zones          -- table de jonction event ↔ zone
    outage_event_id UUID FK
    zone_id UUID FK
    PRIMARY KEY (outage_event_id, zone_id)

Tables conservées (de DEC-005, mises à jour) :
  zones                       -- inchangé
  device_signals              -- inchangé
  community_outages           -- inchangé

Tables abandonnées :
  ceet_announcements          -- remplacé par raw_articles (multi-source)
  planned_outages             -- remplacé par outage_events + outage_versions

---

## DEC-013 — Workflow GitHub Actions unifié

Date : 2026-04-25

Décision : un seul workflow GitHub Actions qui s'auto-orchestre, plutôt que
plusieurs workflows par tier.

Cron unique : `*/30 * * * *` (toutes les 30 minutes)

Le script Python regarde l'heure courante et décide quoi scraper :
  - Toujours : Tier 1 (3 sources principales)
  - Si heure paire : Tier 2 (3 sources secondaires)
  - Si heure multiple de 4 : Tier 3 (ceet.tg avec OCR)
  - À 03h UTC une fois par jour : nettoyage (TTL device_signals, agrégats)

Pourquoi pas plusieurs crons :
  - GitHub Actions cron est peu fiable sur les intervalles courts (5-30 min de
    retard fréquents)
  - 1 schedule unique = 1 source de problème, pas 6
  - Plus simple à monitorer (un seul historique d'exécution)

Quota :
  ~48 runs/jour × ~90s = ~70 min/jour = ~2100 min/mois
  Le repo est public → minutes illimitées sur GitHub Actions
  Si on passait en privé un jour, il faudrait baisser la fréquence.

---

## DEC-014 — LLM fallback différé à plus tard

Date : 2026-04-25

Décision : Phase 1 du scraper en regex-only. Le fallback LLM (Gemini Flash 2.0
free tier) est différé à une phase ultérieure.

Pourquoi différer :
  - L'utilisateur préfère ne pas créer de compte Google AI Studio maintenant
  - Le format des communiqués CEET relayés est suffisamment standard pour qu'un
    parser regex bien construit couvre 80-90% des cas
  - Les 10-20% restants seront marqués `parse_status = 'partial'` ou 'failed'
    et reviendront via le fallback LLM en Phase 2 ou 3

Conséquence architecture :
  - On laisse une fonction `parse_with_llm(text) -> StructuredAnnouncement`
    déclarée mais non implémentée pour l'instant
  - Quand on l'activera, elle s'insérera juste après l'échec du regex sans
    modifier le pipeline
