from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Allumé API",
    description="API de suivi des coupures d'électricité au Togo",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


# Les routes arrivent en Phase 1 et 2 :
# POST /signals    — signaux capteurs des téléphones
# GET  /outages    — coupures en cours (officielles + communautaires)
# GET  /zones      — liste des zones de Lomé
