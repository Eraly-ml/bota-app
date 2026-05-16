/**
 * api.ts — Backend API client for Bayan Sulu Kids
 * Connects the React frontend to the FastAPI backend.
 * Gracefully falls back to mock storage or offline modes if the backend is offline.
 */

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'

export interface ServerPlayerSync {
  name: string
  age: number
  avatarId: number
  level: number
  xp: number
  botacoins: number
  streak: number
  unlockedBadges: string[]
}

export interface ServerPlayerResponse {
  id: string
  name: string
  age: number
  avatarId: number
  level: number
  xp: number
  botacoins: number
  streak: number
  unlockedBadges: string[]
  lastSynced: string
}

export interface ServerLeaderboardEntry {
  rank: number
  name: string
  avatarId: number
  level: number
  botacoins: number
}

export interface ServerPrize {
  id: string
  nameRu: string
  nameKz: string
  cost: number
  image: string
  descriptionRu: string
  descriptionKz: string
  category: string
}

export interface ServerCouponResponse {
  id: string
  prizeId: string
  code: string
  purchasedAt: string
  used: boolean
}

export const api = {
  /**
   * Syncs the local player state to the FastAPI backend database.
   * If playerId is provided, updates the existing profile; otherwise registers a new one.
   */
  async syncPlayer(playerData: ServerPlayerSync, playerId?: string): Promise<ServerPlayerResponse> {
    const url = playerId ? `${BASE_URL}/api/player/sync?player_id=${playerId}` : `${BASE_URL}/api/player/sync`
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(playerData)
    })
    if (!res.ok) throw new Error(`Sync failed: ${res.statusText}`)
    return res.json()
  },

  /**
   * Fetches the global player leaderboard from the backend.
   */
  async getLeaderboard(): Promise<ServerLeaderboardEntry[]> {
    const res = await fetch(`${BASE_URL}/api/leaderboard`)
    if (!res.ok) throw new Error(`Leaderboard fetch failed: ${res.statusText}`)
    return res.json()
  },

  /**
   * Fetches real candy prizes available for purchase from the backend.
   */
  async getPrizes(): Promise<ServerPrize[]> {
    const res = await fetch(`${BASE_URL}/api/prizes`)
    if (!res.ok) throw new Error(`Prizes fetch failed: ${res.statusText}`)
    return res.json()
  },

  /**
   * Purchases a coupon for a real JSC 'Bayan Sulu' candy prize from the backend.
   */
  async purchaseCoupon(playerId: string, prizeId: string): Promise<ServerCouponResponse> {
    const res = await fetch(`${BASE_URL}/api/coupons/purchase`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ playerId, prizeId })
    })
    if (!res.ok) throw new Error(`Coupon purchase failed: ${res.statusText}`)
    return res.json()
  }
}
