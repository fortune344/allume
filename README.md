# Allumé

Application mobile de suivi des coupures d'électricité au Togo.

Allumé détecte automatiquement les coupures de courant via les capteurs du téléphone, agrège les annonces officielles de la CEET, et affiche une carte communautaire des coupures en temps réel à Lomé.

---

## Stack technique

| Couche | Technologie |
|--------|-------------|
| Application mobile | Flutter (Dart) — Android |
| API serveur | Python FastAPI sur Fly.io |
| Base de données | Supabase (PostgreSQL + PostGIS) |
| Scraper CEET | Python + BeautifulSoup sur GitHub Actions |
| Notifications | Firebase Cloud Messaging |
| Carte | flutter_map + OpenStreetMap |

---

## Structure du projet

```
allume/
├── mobile/          # Application Flutter
│   └── lib/
│       └── main.dart
├── backend/
│   ├── api/         # FastAPI — logique serveur
│   ├── scraper/     # Scraper ceet.tg
│   └── tests/       # Tests Python
└── docs/
    ├── ARCHITECTURE.md
    └── DECISIONS.md
```

---

## Installation — environnement de développement

### Prérequis

- Flutter 3.41+
- Python 3.12+
- Un compte Supabase (gratuit)
- Android Studio + un téléphone Android en débogage USB

### 1. Cloner le dépôt

```bash
git clone https://github.com/fortune344/allume.git
cd allume
```

### 2. Backend Python

```bash
cd backend
python -m venv venv
venv\Scripts\activate      # Windows
pip install -r requirements.txt
cp .env.example .env       # puis remplis .env avec tes clés Supabase
```

### 3. Application Flutter

```bash
cd mobile
flutter pub get
flutter run
```

---

## Lancer le scraper manuellement

```bash
cd backend
python -m scraper.ceet
```

---

## Tests

```bash
cd backend
pytest tests/
```

---

## Documentation

- [Architecture](docs/ARCHITECTURE.md) — composants, flux de données, choix techniques
- [Décisions](docs/DECISIONS.md) — journal des décisions importantes

---

## Contexte

Le Togo, et particulièrement Lomé, vit des coupures d'électricité chroniques. La CEET (Compagnie Énergie Électrique du Togo) annonce parfois les coupures programmées, mais les annonces sont éparpillées, les zones mal définies, et les coupures imprévues jamais signalées. Allumé résout ce problème.
