"""
Scraper pour les communiqués de coupure de la CEET.
URL source : https://www.ceet.tg/tg/?cat=10

Phase 1 : implémentation complète.
Ce fichier contient la structure et les types attendus.
"""

CEET_BASE_URL = "https://www.ceet.tg/tg"
COMMUNIQUES_URL = f"{CEET_BASE_URL}/?cat=10"


def fetch_announcements() -> list[dict]:
    """
    Télécharge la liste des communiqués depuis ceet.tg.
    Retourne une liste de {url, titre, date_publiée}.
    """
    raise NotImplementedError("Implémenté en Phase 1")


def parse_announcement(html: str) -> dict:
    """
    Parse le HTML d'un article de communiqué.
    Retourne {raw_text, entries: [{starts_at, ends_at, zone_names}]}.
    """
    raise NotImplementedError("Implémenté en Phase 1")


def run():
    """Point d'entrée du scraper. Lancé par GitHub Actions."""
    raise NotImplementedError("Implémenté en Phase 1")


if __name__ == "__main__":
    run()
