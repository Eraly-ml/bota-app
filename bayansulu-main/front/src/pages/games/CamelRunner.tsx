import { useEffect, useRef, useState, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import GameLayout from '@/components/layout/GameLayout'
import KamBot from '@/components/kambot/KamBot'
import Button from '@/components/ui/Button'
import Modal from '@/components/ui/Modal'
import { usePlayerStore } from '@/store/playerStore'
import { useGameStore } from '@/store/gameStore'
import { getTranslation } from '@/data/locale'

type ObstacleType = { id: number; x: number; icon: string; height: 'low' | 'high'; speed: number }
type CoinType     = { id: number; x: number; y: number }

const THEMES = [
  { bg: 'from-sky-blue/20 to-deep-navy', ground: '#3D2A7A', label: '🏙️ Astana' },
  { bg: 'from-mint-green/15 to-deep-navy', ground: '#1a3a2a', label: '⛰️ Mountains' },
  { bg: 'from-warm-orange/20 to-deep-navy', ground: '#4a2010', label: '🏜️ Charyn' },
  { bg: 'from-kazakh-gold/15 to-deep-navy', ground: '#3a2a0a', label: '🌾 Steppe' },
]
const OBSTACLES = [
  { icon: '🪨', height: 'low' as const },
  { icon: '🌵', height: 'low' as const },
  { icon: '🚧', height: 'high' as const },
  { icon: '🌾', height: 'low' as const },
]

let idCounter = 0

export default function CamelRunner() {
  const addCoins    = usePlayerStore(s => s.addCoins)
  const addXP       = usePlayerStore(s => s.addXP)
  const completeGame = usePlayerStore(s => s.completeGame)
  const unlockBadge = usePlayerStore(s => s.unlockBadge)
  const language    = usePlayerStore(s => s.language)
  const t           = getTranslation(language)
  const setHighScore = useGameStore(s => s.setHighScore)

  const [phase, setPhase]     = useState<'idle' | 'playing' | 'dead'>('idle')
  const [score, setScore]     = useState(0)
  const [coins, setCoins]     = useState(0)
  const [isJumping, setIsJumping] = useState(false)
  const [obstacles, setObstacles] = useState<ObstacleType[]>([])
  const [coinObjs, setCoinObjs]   = useState<CoinType[]>([])
  const [themeIdx, setThemeIdx]   = useState(0)
  const [lives, setLives]     = useState(3)

  const jumpRef   = useRef(false)
  const phaseRef  = useRef(phase)
  const scoreRef  = useRef(0)
  const livesRef  = useRef(3)
  const invincRef = useRef(false)  // brief invincibility after hit

  useEffect(() => { phaseRef.current = phase }, [phase])
  useEffect(() => { scoreRef.current = score }, [score])
  useEffect(() => { livesRef.current = lives }, [lives])

  const jump = useCallback(() => {
    if (jumpRef.current || phaseRef.current !== 'playing') return
    jumpRef.current = true
    setIsJumping(true)
    setTimeout(() => { jumpRef.current = false; setIsJumping(false) }, 600)
  }, [])

  // Keyboard
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.code === 'Space' || e.code === 'ArrowUp') { e.preventDefault(); jump() }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [jump])

  // Game loop
  useEffect(() => {
    if (phase !== 'playing') return

    // Obstacle spawner
    const spawnObs = setInterval(() => {
      const speed = 2.5 + scoreRef.current * 0.002
      const type  = OBSTACLES[Math.floor(Math.random() * OBSTACLES.length)]
      setObstacles(prev => [...prev, { id: ++idCounter, x: 105, icon: type.icon, height: type.height, speed }])
    }, Math.max(800, 2200 - scoreRef.current * 1.5))

    // Coin spawner
    const spawnCoin = setInterval(() => {
      setCoinObjs(prev => [...prev, { id: ++idCounter, x: 108, y: 35 + Math.random() * 25 }])
    }, 1800)

    // Theme cycle
    const themeTimer = setInterval(() => setThemeIdx(i => (i + 1) % THEMES.length), 8000)

    // Score ticker
    const scoreTick = setInterval(() => setScore(s => s + 1), 100)

    // Move obstacles
    const moveTick = setInterval(() => {
      if (phaseRef.current !== 'playing') return

      setObstacles(prev => {
        const updated = prev
          .map(o => ({ ...o, x: o.x - o.speed * 0.6 }))
          .filter(o => o.x > -10)

        // Collision: KamBot is at x=10–18%, y=low (75–90%) or jump (40–65%)
        const kambotY = jumpRef.current ? 42 : 72
        updated.forEach(o => {
          if (o.x > 8 && o.x < 20 && !invincRef.current) {
            const obsY = o.height === 'low' ? 72 : 55
            const hit  = Math.abs(kambotY - obsY) < 18
            if (hit) {
              invincRef.current = true
              setTimeout(() => { invincRef.current = false }, 1200)
              const newLives = livesRef.current - 1
              livesRef.current = newLives
              setLives(newLives)
              if (newLives <= 0) {
                setPhase('dead')
                setHighScore('runner', scoreRef.current)
                if (scoreRef.current >= 300) {
                  unlockBadge('speed-runner')
                  completeGame('runner')
                }
              }
            }
          }
        })
        return updated
      })

      // Move + collect coins
      setCoinObjs(prev => {
        const updated = prev
          .map(c => ({ ...c, x: c.x - 1.8 }))
          .filter(c => c.x > -5)

        updated.forEach(c => {
          if (c.x > 8 && c.x < 20) {
            const cy = c.y
            const ky = jumpRef.current ? 45 : 75
            if (Math.abs(cy - ky) < 20) {
              setCoins(n => n + 1)
              updated.splice(updated.indexOf(c), 1)
            }
          }
        })
        return updated
      })
    }, 30)

    return () => {
      clearInterval(spawnObs)
      clearInterval(spawnCoin)
      clearInterval(themeTimer)
      clearInterval(scoreTick)
      clearInterval(moveTick)
    }
  }, [phase, setHighScore, unlockBadge, completeGame])

  const start = () => {
    idCounter = 0
    setPhase('playing')
    setScore(0)
    setCoins(0)
    setLives(3)
    setObstacles([])
    setCoinObjs([])
    setThemeIdx(0)
    jumpRef.current = false
    invincRef.current = false
  }

  const theme = THEMES[themeIdx]

  return (
    <GameLayout title={t.gameTitleRunner} kambot={{ show: false }}>
      {/* Game viewport */}
      <div
        className={`relative mx-3 rounded-4xl overflow-hidden bg-gradient-to-b ${theme.bg} select-none`}
        style={{ height: 260, touchAction: 'none' }}
        onPointerDown={() => { if (phase === 'playing') jump(); if (phase === 'idle') start() }}
      >
        {/* Sky decoration */}
        <div className="absolute top-3 right-4 text-2xl opacity-60">
          {['☀️','🌤️','⛅','🌙'][themeIdx]}
        </div>
        <div className="absolute top-2 left-3 text-xs font-bold text-white/50">{theme.label}</div>

        {/* Ground */}
        <div
          className="absolute bottom-0 left-0 right-0 h-14 rounded-b-4xl"
          style={{ background: `linear-gradient(180deg, ${theme.ground}aa, ${theme.ground})` }}
        />
        {/* Ground line */}
        <div className="absolute left-0 right-0 border-t-2 border-kazakh-gold/20" style={{ bottom: 56 }} />

        {/* KamBot runner */}
        <motion.div
          className="absolute"
          style={{ left: '12%', bottom: isJumping ? '45%' : '14%' }}
          animate={{ bottom: isJumping ? '45%' : '14%' }}
          transition={{ type: 'spring', stiffness: 400, damping: 18 }}
        >
          <KamBot mood={phase === 'dead' ? 'sad' : isJumping ? 'celebrate' : 'happy'} size={52} />
        </motion.div>

        {/* Obstacles */}
        {obstacles.map(o => (
          <div
            key={o.id}
            className="absolute text-3xl"
            style={{
              left: `${o.x}%`,
              bottom: o.height === 'low' ? '14%' : '28%',
              transform: 'translateX(-50%)',
            }}
          >
            {o.icon}
          </div>
        ))}

        {/* Coins */}
        {coinObjs.map(c => (
          <motion.div
            key={c.id}
            className="absolute text-xl"
            style={{ left: `${c.x}%`, bottom: `${c.y}%` }}
            animate={{ y: [0, -4, 0] }}
            transition={{ duration: 0.8, repeat: Infinity }}
          >
            🪙
          </motion.div>
        ))}

        {/* HUD */}
        {phase === 'playing' && (
          <div className="absolute top-2 left-0 right-0 flex justify-center gap-4 text-sm font-black">
            <span className="text-white bg-black/30 rounded-full px-2 py-0.5">📏 {score}</span>
            <span className="text-kazakh-gold bg-black/30 rounded-full px-2 py-0.5">🪙 {coins}</span>
            <span className="text-candy-pink bg-black/30 rounded-full px-2 py-0.5">
              {'❤️'.repeat(lives)}{'🖤'.repeat(3 - lives)}
            </span>
          </div>
        )}

        {/* Idle overlay */}
        {phase === 'idle' && (
          <motion.div
            className="absolute inset-0 flex flex-col items-center justify-center gap-3"
            initial={{ opacity: 0 }} animate={{ opacity: 1 }}
          >
            <KamBot mood="happy" size={70} className="animate-float" />
            <div className="text-center">
              <p className="text-white font-black text-lg">{t.gameTitleRunner}</p>
              <p className="text-white/50 text-sm font-bold">{t.gameRunnerTapStart} 🏃</p>
            </div>
          </motion.div>
        )}
      </div>

      {/* Controls hint */}
      {phase === 'playing' && (
        <p className="text-center text-white/30 text-xs font-bold mt-2">{t.gameRunnerJumpHint}</p>
      )}

      {/* Score display */}
      {phase !== 'idle' && (
        <div className="flex justify-center gap-6 mt-3 px-4">
          <div className="glass rounded-3xl px-4 py-2 text-center">
            <p className="text-white/50 text-xs font-bold">{t.gameScore}</p>
            <p className="text-kazakh-gold font-black text-xl">{score}</p>
          </div>
          <div className="glass rounded-3xl px-4 py-2 text-center">
            <p className="text-white/50 text-xs font-bold">{t.gameCoins}</p>
            <p className="text-kazakh-gold font-black text-xl">{coins}</p>
          </div>
          <div className="glass rounded-3xl px-4 py-2 text-center">
            <p className="text-white/50 text-xs font-bold">{t.gameLives}</p>
            <p className="text-candy-pink font-black text-xl">{'❤️'.repeat(Math.max(0, lives))}</p>
          </div>
        </div>
      )}

      {/* Death modal */}
      <Modal open={phase === 'dead'}>
        <div className="text-center">
          <div className="mb-3"><KamBot mood="sad" size={90} /></div>
          <h2 className="text-white font-black text-2xl mb-1">{t.gameRunnerOops} 💨</h2>
          <p className="font-bold mb-1" style={{ color: 'rgba(254,243,199,0.6)' }}>{t.gameScore}: <span style={{ color: '#D97706' }}>{score}</span></p>
          <p className="text-white/60 mb-5 font-bold">{t.gameCoins}: <span className="text-kazakh-gold">+{coins} 🪙</span></p>
          <Button variant="primary" fullWidth onClick={() => {
            addCoins(coins)
            addXP(Math.floor(score / 5))
            start()
          }}>
            {t.gameRunnerRunAgain} 🏃
          </Button>
        </div>
      </Modal>
    </GameLayout>
  )
}
