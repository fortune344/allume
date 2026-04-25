-- ============================================================
-- Schéma de base de données — Allumé
-- Cible : Supabase (PostgreSQL 15 + PostGIS)
--
-- À exécuter dans le SQL Editor de Supabase au démarrage du projet.
-- Référence : DECISIONS.md DEC-012.
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================
-- 1. SOURCES — relais qu'on scrape
-- ============================================================
CREATE TABLE IF NOT EXISTS sources (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        TEXT NOT NULL UNIQUE,
    base_url    TEXT NOT NULL,
    tier        SMALLINT NOT NULL CHECK (tier IN (1, 2, 3)),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Données initiales : on inscrit les sources connues
INSERT INTO sources (name, base_url, tier) VALUES
    ('togoactualite',    'https://togoactualite.com',          1),
    ('republiquetogo',   'https://www.republiquetogolaise.com', 1),
    ('togofirst',        'https://www.togofirst.com',          1),
    ('icilome',          'https://icilome.com',                2),
    ('impartialactu',    'https://impartialactu.tg',           2),
    ('newafrique',       'https://newafrique.net',             2),
    ('ceet_official',    'https://www.ceet.tg',                3)
ON CONFLICT (name) DO NOTHING;


-- ============================================================
-- 2. ZONES — quartiers de Lomé
-- Geometries seront importées depuis OpenStreetMap (Phase 1B).
-- ============================================================
CREATE TABLE IF NOT EXISTS zones (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            TEXT NOT NULL UNIQUE,
    synonyms        TEXT[] NOT NULL DEFAULT '{}',
    arrondissement  TEXT,
    geometry        GEOMETRY(POLYGON, 4326),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_zones_geometry  ON zones USING GIST (geometry);
CREATE INDEX IF NOT EXISTS idx_zones_synonyms  ON zones USING GIN (synonyms);

-- Quartiers cibles pour le lancement (12 quartiers de Lomé)
-- Geometry NULL pour l'instant, à remplir depuis OSM ensuite.
INSERT INTO zones (name, synonyms) VALUES
    ('Bè',              ARRAY['Be', 'Bè-Kpota', 'Bè Kpota', 'marché de Bè']),
    ('Tokoin',          ARRAY['Tokoin Wuiti', 'Tokoin Habitat', 'Tokoin Hôpital']),
    ('Adidogomé',       ARRAY['Adidogome', 'Adidogomé Aképé']),
    ('Agoè',            ARRAY['Agoe', 'Agoè-Nyivé', 'Agoè Cacaveli']),
    ('Kodjoviakopé',    ARRAY['Kodjoviakope']),
    ('Hédzranawoé',     ARRAY['Hedzranawoe', 'Hédzranawoe']),
    ('Nyékonakpoè',     ARRAY['Nyekonakpoe']),
    ('Hanoukopé',       ARRAY['Hanoukope']),
    ('Lomé 2',          ARRAY['Lome 2', 'Lomé II']),
    ('Cacaveli',        ARRAY[]::TEXT[]),
    ('Baguida',         ARRAY[]::TEXT[]),
    ('Aflao Gakli',     ARRAY['Aflao'])
ON CONFLICT (name) DO NOTHING;


-- ============================================================
-- 3. RAW ARTICLES — tout ce qu'on a téléchargé brut
-- Niveau A de déduplication : source_url UNIQUE
-- ============================================================
CREATE TABLE IF NOT EXISTS raw_articles (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id           UUID NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
    source_url          TEXT NOT NULL UNIQUE,
    scraped_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    published_at        TIMESTAMPTZ,
    title               TEXT NOT NULL,
    content_text        TEXT NOT NULL DEFAULT '',
    content_image_urls  TEXT[] NOT NULL DEFAULT '{}',
    classification      TEXT NOT NULL DEFAULT 'unknown'
        CHECK (classification IN ('planned_outage', 'unplanned', 'admin', 'unknown')),
    parse_status        TEXT NOT NULL DEFAULT 'pending'
        CHECK (parse_status IN ('pending', 'ok', 'partial', 'failed', 'skipped'))
);

CREATE INDEX IF NOT EXISTS idx_raw_articles_source       ON raw_articles (source_id);
CREATE INDEX IF NOT EXISTS idx_raw_articles_scraped      ON raw_articles (scraped_at DESC);
CREATE INDEX IF NOT EXISTS idx_raw_articles_class_status ON raw_articles (classification, parse_status);


-- ============================================================
-- 4. OUTAGE EVENTS — événement de coupure dédupliqué
-- Niveau B de déduplication : event_hash UNIQUE
-- ============================================================
CREATE TABLE IF NOT EXISTS outage_events (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_hash        TEXT NOT NULL UNIQUE,
    primary_date      DATE NOT NULL,
    best_starts_at    TIMESTAMPTZ NOT NULL,
    best_ends_at      TIMESTAMPTZ NOT NULL,
    has_conflicts     BOOLEAN NOT NULL DEFAULT FALSE,
    source_count      INT NOT NULL DEFAULT 1,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (best_ends_at > best_starts_at)
);

CREATE INDEX IF NOT EXISTS idx_outage_events_date    ON outage_events (primary_date);
CREATE INDEX IF NOT EXISTS idx_outage_events_starts  ON outage_events (best_starts_at);


-- ============================================================
-- 5. OUTAGE VERSIONS — chaque interprétation d'un event par une source
-- ============================================================
CREATE TABLE IF NOT EXISTS outage_versions (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    outage_event_id   UUID NOT NULL REFERENCES outage_events(id) ON DELETE CASCADE,
    raw_article_id    UUID NOT NULL REFERENCES raw_articles(id) ON DELETE CASCADE,
    starts_at         TIMESTAMPTZ NOT NULL,
    ends_at           TIMESTAMPTZ NOT NULL,
    zones_raw         JSONB NOT NULL DEFAULT '[]',  -- noms bruts extraits
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (outage_event_id, raw_article_id)
);

CREATE INDEX IF NOT EXISTS idx_outage_versions_event   ON outage_versions (outage_event_id);
CREATE INDEX IF NOT EXISTS idx_outage_versions_article ON outage_versions (raw_article_id);


-- ============================================================
-- 6. OUTAGE EVENT ZONES — table de jonction event ↔ zones identifiées
-- ============================================================
CREATE TABLE IF NOT EXISTS outage_event_zones (
    outage_event_id  UUID NOT NULL REFERENCES outage_events(id) ON DELETE CASCADE,
    zone_id          UUID NOT NULL REFERENCES zones(id) ON DELETE CASCADE,
    PRIMARY KEY (outage_event_id, zone_id)
);

CREATE INDEX IF NOT EXISTS idx_outage_event_zones_zone ON outage_event_zones (zone_id);


-- ============================================================
-- 7. DEVICE SIGNALS — signaux anonymes envoyés par les téléphones
-- TTL : supprimés après 7 jours (données de travail uniquement)
-- ============================================================
CREATE TABLE IF NOT EXISTS device_signals (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    zone_id       UUID NOT NULL REFERENCES zones(id) ON DELETE CASCADE,
    signal_type   TEXT NOT NULL
        CHECK (signal_type IN ('manual_outage', 'manual_back', 'wifi_disconnect',
                               'unplug', 'sound_drop', 'light_drop', 'wifi_neighbors_lost')),
    score         REAL NOT NULL CHECK (score >= 0 AND score <= 1),
    session_id    TEXT NOT NULL  -- ID rotatif anonyme, jamais lié à un user
);

CREATE INDEX IF NOT EXISTS idx_device_signals_zone_time ON device_signals (zone_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_device_signals_created   ON device_signals (created_at);


-- ============================================================
-- 8. COMMUNITY OUTAGES — coupures détectées par agrégation des signaux
-- ============================================================
CREATE TABLE IF NOT EXISTS community_outages (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_id       UUID NOT NULL REFERENCES zones(id) ON DELETE CASCADE,
    detected_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at      TIMESTAMPTZ,
    confidence    REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    signal_count  INT NOT NULL DEFAULT 0,
    CHECK (ended_at IS NULL OR ended_at > detected_at)
);

CREATE INDEX IF NOT EXISTS idx_community_outages_zone_active
    ON community_outages (zone_id, detected_at DESC) WHERE ended_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_community_outages_detected
    ON community_outages (detected_at DESC);


-- ============================================================
-- Trigger : maintien de updated_at sur outage_events
-- ============================================================
CREATE OR REPLACE FUNCTION trg_set_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS outage_events_updated_at ON outage_events;
CREATE TRIGGER outage_events_updated_at
    BEFORE UPDATE ON outage_events
    FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();
