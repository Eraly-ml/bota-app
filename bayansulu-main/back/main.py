import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

app = FastAPI(
    title="Bayan Sulu Kids API",
    description="Python/FastAPI backend supporting local player synchronization, leaderboards, and rewards.",
    version="1.0.0",
)

# Enable CORS for the local React frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for the MVP/development phase
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Schemas ---

class PlayerSyncRequest(BaseModel):
    name: str = Field(..., example="Алихан")
    age: int = Field(..., example=8)
    avatarId: int = Field(..., example=1)
    level: int = Field(..., example=3)
    xp: int = Field(..., example=150)
    botacoins: int = Field(..., example=450)
    streak: int = Field(..., example=2)
    unlockedBadges: List[str] = Field(default_factory=list, example=["astana_quiz", "almaty_memory"])

class PlayerResponse(BaseModel):
    id: str
    name: str
    age: int
    avatarId: int
    level: int
    xp: int
    botacoins: int
    streak: int
    unlockedBadges: List[str]
    lastSynced: str

class LeaderboardEntry(BaseModel):
    rank: int
    name: str
    avatarId: int
    level: int
    botacoins: int

class PrizeProduct(BaseModel):
    id: str
    nameRu: str
    nameKz: str
    cost: int
    image: str
    descriptionRu: str
    descriptionKz: str
    category: str

class PurchaseRequest(BaseModel):
    playerId: str
    prizeId: str

class CouponResponse(BaseModel):
    id: str
    prizeId: str
    code: str
    purchasedAt: str
    used: bool

# --- Mock Database ---

players_db = {
    "demo_player_1": {
        "id": "demo_player_1",
        "name": "Айсулу",
        "age": 7,
        "avatarId": 2,
        "level": 5,
        "xp": 320,
        "botacoins": 820,
        "streak": 5,
        "unlockedBadges": ["astana_quiz", "almaty_memory", "math_genius"],
        "lastSynced": datetime.now().isoformat()
    },
    "demo_player_2": {
        "id": "demo_player_2",
        "name": "Данияр",
        "age": 9,
        "avatarId": 4,
        "level": 4,
        "xp": 120,
        "botacoins": 510,
        "streak": 3,
        "unlockedBadges": ["astana_quiz", "yurt_master"],
        "lastSynced": datetime.now().isoformat()
    }
}

prizes_db = [
    {
        "id": "bs-candy-1",
        "nameRu": "Набор конфет «Баян Сулу» 500г",
        "nameKz": "«Баян Сұлу» кәмпит жинағы 500г",
        "cost": 150,
        "image": "🎁",
        "descriptionRu": "Сладкий подарочный набор конфет от фабрики Баян Сулу.",
        "descriptionKz": "Баян Сұлу фабрикасының тәтті сыйлық жинағы.",
        "category": "sweet"
    },
    {
        "id": "bs-choc-gold",
        "nameRu": "Шоколад «Казахстанский»",
        "nameKz": "«Қазақстандық» шоколады",
        "cost": 80,
        "image": "🍫",
        "descriptionRu": "Настоящий классический молочный шоколад Баян Сулу.",
        "descriptionKz": "Баян Сұлу классикалық сүтті шоколады.",
        "category": "chocolate"
    },
    {
        "id": "bs-toy-camel",
        "nameRu": "Мягкая игрушка «Верблюжонок Камми»",
        "nameKz": "«Камми ботақаны» жұмсақ ойыншығы",
        "cost": 300,
        "image": "🐪",
        "descriptionRu": "Плюшевый талисман нашего приложения — верблюжонок Камми!",
        "descriptionKz": "Қосымшамыздың жұмсақ тұмары — Камми ботақаны!",
        "category": "toy"
    }
]

# --- Endpoints ---

@app.get("/")
def read_root():
    return {
        "status": "online",
        "message": "Welcome to the Bayan Sulu Kids backend API!",
        "docs_url": "/docs"
    }

@app.get("/api/prizes", response_model=List[PrizeProduct])
def get_prizes():
    """Get list of available candy prizes and rewards."""
    return prizes_db

@app.post("/api/player/sync", response_model=PlayerResponse)
def sync_player(player_data: PlayerSyncRequest, player_id: Optional[str] = None):
    """Sync or register player progress from localStorage."""
    if not player_id or player_id not in players_db:
        player_id = str(uuid.uuid4())
    
    players_db[player_id] = {
        "id": player_id,
        "name": player_data.name,
        "age": player_data.age,
        "avatarId": player_data.avatarId,
        "level": player_data.level,
        "xp": player_data.xp,
        "botacoins": player_data.botacoins,
        "streak": player_data.streak,
        "unlockedBadges": player_data.unlockedBadges,
        "lastSynced": datetime.now().isoformat()
    }
    
    return players_db[player_id]

@app.get("/api/leaderboard", response_model=List[LeaderboardEntry])
def get_leaderboard():
    """Retrieve the top player leaderboard based on level and coins."""
    sorted_players = sorted(
        players_db.values(),
        key=lambda p: (p["level"], p["botacoins"]),
        reverse=True
    )
    
    leaderboard = []
    for index, p in enumerate(sorted_players):
        leaderboard.append({
            "rank": index + 1,
            "name": p["name"],
            "avatarId": p["avatarId"],
            "level": p["level"],
            "botacoins": p["botacoins"]
        })
    return leaderboard

@app.post("/api/coupons/purchase", response_model=CouponResponse)
def purchase_coupon(request: PurchaseRequest):
    """Redeem Botacoins for a JSC 'Bayan Sulu' candy coupon barcode."""
    player = players_db.get(request.playerId)
    if not player:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Player not found"
        )
        
    prize = next((p for p in prizes_db if p["id"] == request.prizeId), None)
    if not prize:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Prize product not found"
        )
        
    if player["botacoins"] < prize["cost"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Insufficient Botacoins"
        )
        
    # Deduct coins from player
    player["botacoins"] -= prize["cost"]
    player["lastSynced"] = datetime.now().isoformat()
    
    # Generate unique coupon code
    coupon_code = f"BS-{uuid.uuid4().hex[:8].upper()}"
    
    return {
        "id": str(uuid.uuid4()),
        "prizeId": prize["id"],
        "code": coupon_code,
        "purchasedAt": datetime.now().isoformat(),
        "used": False
    }
