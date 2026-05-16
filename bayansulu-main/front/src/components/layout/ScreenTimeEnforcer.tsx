import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import KamBot from '@/components/kambot/KamBot'
import Button from '@/components/ui/Button'
import { usePlayerStore } from '@/store/playerStore'
import { useGameStore } from '@/store/gameStore'
import { getTranslation } from '@/data/locale'

function getSecondsUntilMidnight(): number {
  const now = new Date()
  const midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)
  return Math.floor((midnight.getTime() - now.getTime()) / 1000)
}

function formatCountdown(totalSeconds: number): string {
  const h = Math.floor(totalSeconds / 3600)
  const m = Math.floor((totalSeconds % 3600) / 60)
  const s = totalSeconds % 60
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

export default function ScreenTimeEnforcer() {
  const language = usePlayerStore(s => s.language)
  const screenTimeLimit = usePlayerStore(s => s.screenTimeLimit)
  const sessionStartTime = useGameStore(s => s.sessionStartTime)
  const t = getTranslation(language)

  const [locked, setLocked] = useState(false)
  const [countdown, setCountdown] = useState(0)

  // Check on mount and every minute
  useEffect(() => {
    const check = () => {
      const elapsedMin = (Date.now() - sessionStartTime) / 1000 / 60
      if (elapsedMin >= screenTimeLimit) {
        setLocked(true)
        setCountdown(getSecondsUntilMidnight())
      }
    }

    check()
    const interval = setInterval(check, 60000)
    return () => clearInterval(interval)
  }, [sessionStartTime, screenTimeLimit])

  // Countdown tick
  useEffect(() => {
    if (!locked) return
    const tick = setInterval(() => {
      setCountdown(prev => {
        if (prev <= 1) {
          // Midnight reached — unlock and reset session
          setLocked(false)
          useGameStore.setState({ sessionStartTime: Date.now() })
          return 0
        }
        return prev - 1
      })
    }, 1000)
    return () => clearInterval(tick)
  }, [locked])

  const msg = language === 'kk'
    ? 'Ойын уақыты бітті! Ертең қайта кел!'
    : 'Время приключений закончилось! Приходи завтра!'

  const sub = language === 'kk'
    ? 'Жаңа ойын уақытына дейін:'
    : 'До новых приключений:'

  return (
    <AnimatePresence>
      {locked && (
        <motion.div
          className="fixed inset-0 z-[100] flex flex-col items-center justify-center gap-6 px-6"
          style={{ background: '#0D0404' }}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          <KamBot mood="sad" size={120} />
          <div className="text-center">
            <h2 className="text-kazakh-gold font-black text-2xl mb-2">
              {msg}
            </h2>
            <p className="text-white/50 text-sm font-bold mb-4">
              {sub}
            </p>
            <p className="text-white font-black text-4xl font-mono tracking-wider">
              {formatCountdown(countdown)}
            </p>
          </div>
          <Button
            variant="ghost"
            onClick={() => {
              // Parent override — go to parent mode
              window.location.href = '/parent'
            }}
          >
            {language === 'kk' ? '👤 Ата-ана режимі' : '👤 Родительский режим'}
          </Button>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
