import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { GameId } from '@/types'

interface GameState {
  currentGame: GameId | null
  highScores: Record<string, number>
  dailyRewardClaimed: boolean
  dailyRewardDate: string
  sessionStartTime: number

  setCurrentGame: (game: GameId | null) => void
  setHighScore: (game: string, score: number) => void
  claimDailyReward: () => void
  checkAndResetDailyReward: () => void
}

export const useGameStore = create<GameState>()(
  persist(
    (set, get) => ({
      currentGame: null,
      highScores: {},
      dailyRewardClaimed: false,
      dailyRewardDate: '',
      sessionStartTime: Date.now(),

      setCurrentGame: (game) => set({ currentGame: game }),

      setHighScore: (game, score) =>
        set(s => ({
          highScores: {
            ...s.highScores,
            [game]: Math.max(s.highScores[game] ?? 0, score),
          },
        })),

      claimDailyReward: () =>
        set({
          dailyRewardClaimed: true,
          dailyRewardDate: new Date().toISOString().split('T')[0],
        }),

      checkAndResetDailyReward: () => {
        const today = new Date().toISOString().split('T')[0]
        if (get().dailyRewardDate !== today) {
          set({ dailyRewardClaimed: false, dailyRewardDate: today })
        }
      },
    }),
    { name: 'bayan-sulu-game' }
  )
)
