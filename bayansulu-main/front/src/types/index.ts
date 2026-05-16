// ─── Core Types ────────────────────────────────────────────────────────────────

export interface Badge {
  id: string
  name: string
  description: string
  icon: string
  earned: boolean
  earnedAt?: string
}

export interface Avatar {
  id: number
  emoji: string
  bg: string        // tailwind bg-* class
  label: string
}

export interface MapLocation {
  id: string
  name: string
  nameKk: string
  icon: string
  x: number         // percentage within map SVG
  y: number
  game: string      // route path
  description: string
  descriptionKk?: string
  color: string
  unlocked: boolean
}

export interface QuizQuestion {
  id: string
  question: { ru: string; kk: string }
  answers: { ru: string[]; kk: string[] }
  correctIndex: number
  fact: { ru: string; kk: string }
  category: 'nature' | 'history' | 'food' | 'animals' | 'landmarks'
  sticker: string
}

export interface DailyReward {
  type: 'coins' | 'xp' | 'badge'
  amount?: number
  badgeId?: string
  label: string
  icon: string
}

export type GameId = 'memory' | 'runner' | 'yurt' | 'quiz' | 'math' | 'words'

export type KamBotMood = 'idle' | 'happy' | 'celebrate' | 'sad' | 'thinking' | 'salute'

export interface MemoryCard {
  id: number
  pairId: number
  icon: string
  label: string
  flipped: boolean
  matched: boolean
}

export interface YurtPiece {
  id: string
  label: string
  icon: string
  placed: boolean
  required: boolean
}

export interface MathProblem {
  question: string
  answer: number
  choices: number[]
}

export interface RunnerObstacle {
  id: number
  x: number
  type: 'rock' | 'cactus' | 'barrier'
  icon: string
  height: 'low' | 'high'
}

export interface Coupon {
  id: string
  prizeId: string
  code: string
  purchasedAt: string
  used: boolean
}

export interface PrizeProduct {
  id: string
  nameRu: string
  nameKk: string
  cost: number
  emoji: string
  descriptionRu: string
  descriptionKk: string
  discountTenge: number
}
