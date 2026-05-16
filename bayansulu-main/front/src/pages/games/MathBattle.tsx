import { useState, useEffect, useCallback, useRef } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import GameLayout from '@/components/layout/GameLayout'
import KamBot from '@/components/kambot/KamBot'
import Button from '@/components/ui/Button'
import Modal from '@/components/ui/Modal'
import Confetti from '@/components/effects/Confetti'
import { usePlayerStore } from '@/store/playerStore'
import { getTranslation } from '@/data/locale'
import type { MathProblem, KamBotMood } from '@/types'

// ── Math generation ──────────────────────────────────────────────────────────
function shuffle<T>(arr: T[]): T[] {
  return [...arr].sort(() => Math.random() - 0.5)
}

function genProblem(level: number): MathProblem {
  if (level <= 5) {
    const a = Math.floor(Math.random() * 10) + 1
    const b = Math.floor(Math.random() * 10) + 1
    const add = Math.random() > 0.4
    const answer = add ? a + b : Math.abs(a - b)
    const question = add ? `${a} + ${b}` : `${Math.max(a,b)} − ${Math.min(a,b)}`
    const wrongs = [answer + 1, answer - 1, answer + 2].filter(n => n !== answer && n >= 0)
    return { question, answer, choices: shuffle([answer, ...wrongs.slice(0, 3)]) }
  }
  if (level <= 10) {
    const a = Math.floor(Math.random() * 5) + 2
    const b = Math.floor(Math.random() * 5) + 2
    const mul = Math.random() > 0.5
    const answer = mul ? a * b : a + b * 2
    const question = mul ? `${a} × ${b}` : `${a} + ${b} × 2`
    const wrongs = [answer + 2, answer - 2, answer + 4].filter(n => n !== answer && n >= 0)
    return { question, answer, choices: shuffle([answer, ...wrongs.slice(0, 3)]) }
  }
  const a = Math.floor(Math.random() * 15) + 5
  const b = Math.floor(Math.random() * 12) + 3
  const answer = a + b
  const wrongs = [answer + 3, answer - 3, answer + 6].filter(n => n !== answer)
  return { question: `${a} + ${b}`, answer, choices: shuffle([answer, ...wrongs.slice(0, 3)]) }
}

const ENEMIES = ['🍭', '🍬', '🍫', '🧁', '🍡', '🍦']
const BOSS    = '🎃'

export default function MathBattle() {
  const addCoins    = usePlayerStore(s => s.addCoins)
  const addXP       = usePlayerStore(s => s.addXP)
  const completeGame = usePlayerStore(s => s.completeGame)
  const unlockBadge = usePlayerStore(s => s.unlockBadge)
  const language    = usePlayerStore(s => s.language)
  const t           = getTranslation(language)

  const [phase, setPhase]     = useState<'idle' | 'playing' | 'dead'>('idle')
  const [problem, setProblem] = useState<MathProblem>(genProblem(1))
  const [level, setLevel]     = useState(1)
  const [score, setScore]     = useState(0)
  const [combo, setCombo]     = useState(0)
  const [lives, setLives]     = useState(3)
  const [correct, setCorrect] = useState<number | null>(null) // index
  const [wrong, setWrong]     = useState<number | null>(null)
  const [enemy, setEnemy]     = useState(ENEMIES[0])
  const [enemyHp, setEnemyHp] = useState(1)
  const [explosion, setExplosion] = useState(false)
  const [confetti, setConfetti]   = useState(false)
  const [timeLeft, setTimeLeft]   = useState(8)
  const [maxTime, setMaxTime]     = useState(8)
  const [kamMood, setKamMood]     = useState<KamBotMood>('idle')
  const locked = useRef(false)

  // Countdown timer
  useEffect(() => {
    if (phase !== 'playing') return
    setTimeLeft(maxTime)
    const t = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          // Time ran out = wrong
          clearInterval(t)
          handleWrong()
          return maxTime
        }
        return prev - 1
      })
    }, 1000)
    return () => clearInterval(t)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [problem, phase])

  const nextProblem = useCallback((newLevel: number) => {
    locked.current = false
    setCorrect(null)
    setWrong(null)
    const newMaxTime = Math.max(3, 8 - Math.floor(newLevel / 5) * 0.5)
    setMaxTime(newMaxTime)
    setProblem(genProblem(newLevel))
    setEnemy(newLevel % 10 === 0 ? BOSS : ENEMIES[Math.floor(Math.random() * ENEMIES.length)])
  }, [])

  const handleWrong = () => {
    locked.current = true
    setCombo(0)
    setKamMood('sad')
    const newLives = lives - 1
    setLives(newLives)
    if (newLives <= 0) {
      setPhase('dead')
      addCoins(score)
      addXP(Math.floor(score / 2))
    } else {
      setTimeout(() => { setKamMood('idle'); nextProblem(level) }, 900)
    }
  }

  const handleAnswer = (idx: number, val: number) => {
    if (locked.current || phase !== 'playing') return
    locked.current = true

    if (val === problem.answer) {
      setCorrect(idx)
      const newCombo = combo + 1
      const gain = 10 * (newCombo >= 5 ? 3 : newCombo >= 3 ? 2 : 1)
      setCombo(newCombo)
      setScore(s => s + gain)

      if (newCombo >= 5) { unlockBadge('combo-king') }

      const isBoss = enemy === BOSS
      if (isBoss) {
        const newHp = enemyHp - 1
        if (newHp <= 0) {
          setExplosion(true)
          setConfetti(true)
          setTimeout(() => { setExplosion(false); setConfetti(false) }, 1200)
          setEnemyHp(1)
          setLevel(l => {
            const nl = l + 1
            completeGame('math')
            if (nl >= 3) unlockBadge('math-wizard')
            nextProblem(nl)
            return nl
          })
        } else {
          setEnemyHp(newHp)
          setTimeout(() => nextProblem(level), 600)
        }
      } else {
        setExplosion(true)
        setTimeout(() => setExplosion(false), 600)
        setKamMood(newCombo >= 3 ? 'celebrate' : 'happy')
        setLevel(l => {
          const nl = l + 1
          nextProblem(nl)
          return nl
        })
        setTimeout(() => setKamMood('idle'), 800)
      }
    } else {
      setWrong(idx)
      handleWrong()
    }
  }

  const start = () => {
    setPhase('playing'); setScore(0); setCombo(0); setLives(3); setLevel(1)
    setEnemy(ENEMIES[0]); setEnemyHp(1); setMaxTime(8)
    setProblem(genProblem(1)); locked.current = false
    setKamMood('idle')
  }

  return (
    <GameLayout title={t.gameTitleMath} kambot={{ show: false }}>
      <Confetti active={confetti} />

      <div className="px-3 pb-3 flex flex-col gap-3">

        {phase !== 'idle' && (
          <>
            {/* Top HUD */}
            <div className="flex justify-between items-center">
              <div className="flex gap-1">{[1,2,3].map(i => (
                <span key={i} className="text-xl">{i <= lives ? '❤️' : '🖤'}</span>
              ))}</div>
              <div className="flex items-center gap-1">
                {combo >= 3 && (
                  <motion.span
                    className="text-warm-orange font-black text-sm"
                    animate={{ scale: [1, 1.3, 1] }} transition={{ duration: 0.4, repeat: Infinity }}
                  >
                    🔥 {combo}× COMBO!
                  </motion.span>
                )}
              </div>
              <span className="text-kazakh-gold font-black">🪙 {score}</span>
            </div>

            {/* Enemy area */}
            <div className="glass rounded-4xl p-4 flex flex-col items-center gap-3 relative overflow-hidden"
              style={{ minHeight: 140 }}>
              {/* Background pattern */}
              <div className="absolute inset-0 opacity-5 text-6xl flex items-center justify-center pointer-events-none">
                🍬🍭🍫🧁
              </div>

              <AnimatePresence>
                {!explosion ? (
                  <motion.div
                    key="enemy"
                    className="text-center"
                    initial={{ scale: 0 }} animate={{ scale: 1 }}
                    exit={{ scale: 0, rotate: 180 }}
                  >
                    <div className="text-6xl mb-2 animate-float">{enemy}</div>
                    {enemy === BOSS && (
                      <div className="flex gap-1 justify-center mb-1">
                        {Array.from({ length: Math.max(0, enemyHp) }).map((_, i) => (
                          <div key={i} className="w-5 h-2 rounded-full bg-candy-pink" />
                        ))}
                      </div>
                    )}
                    {/* Speech bubble with problem */}
                    <div className="glass rounded-3xl px-5 py-2 text-white font-black text-2xl">
                      {problem.question} = ?
                    </div>
                  </motion.div>
                ) : (
                  <motion.div
                    key="explosion"
                    className="text-5xl"
                    initial={{ scale: 0.5 }} animate={{ scale: [1, 2, 0] }}
                    transition={{ duration: 0.5 }}
                  >
                    💥
                  </motion.div>
                )}
              </AnimatePresence>

              {/* Timer bar */}
              {phase === 'playing' && (
                <div className="w-full h-2 rounded-full overflow-hidden" style={{ background: 'rgba(255,255,255,0.15)' }}>
                  <motion.div
                    className="h-full rounded-full"
                    style={{ background: timeLeft > maxTime * 0.5 ? '#00E5A0' : timeLeft > maxTime * 0.25 ? '#F5A623' : '#FF4D9E' }}
                    animate={{ width: `${(timeLeft / maxTime) * 100}%` }}
                    transition={{ duration: 0.5 }}
                  />
                </div>
              )}
            </div>

            {/* KamBot + answer buttons */}
            <div className="flex items-center gap-2">
              <KamBot mood={kamMood} size={56} />
              <div className="grid grid-cols-2 gap-2 flex-1">
                {problem.choices.map((choice, i) => {
                  const isCorrectAns = correct === i
                  const isWrongAns   = wrong === i

                  return (
                    <motion.button
                      key={`${problem.question}-${i}`}
                      className="rounded-3xl py-3 font-black text-xl text-white"
                      style={{
                        background: isCorrectAns ? 'rgba(0,229,160,0.35)'
                          : isWrongAns ? 'rgba(255,77,158,0.35)'
                          : 'rgba(255,255,255,0.1)',
                        border: isCorrectAns ? '2px solid #00E5A0'
                          : isWrongAns ? '2px solid #FF4D9E'
                          : '2px solid rgba(255,255,255,0.15)',
                      }}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.92 }}
                      onClick={() => handleAnswer(i, choice)}
                    >
                      {choice}
                      {isCorrectAns && ' ✅'}
                      {isWrongAns   && ' ❌'}
                    </motion.button>
                  )
                })}
              </div>
            </div>

            {/* Level badge */}
            <div className="flex justify-center">
              <span className="glass rounded-full px-3 py-1 text-white/60 text-xs font-bold">
                {t.level} {level} · {score} {t.gameScore}
              </span>
            </div>
          </>
        )}

        {/* Idle state */}
        {phase === 'idle' && (
          <motion.div
            className="flex flex-col items-center gap-5 py-6"
            initial={{ opacity: 0 }} animate={{ opacity: 1 }}
          >
            <KamBot mood="happy" size={120} className="animate-float" />
            <div className="text-center">
              <h2 className="text-white font-black text-2xl mb-1">{t.gameTitleMath} 🍭</h2>
              <p className="text-white/60 font-bold text-sm">{t.gameMathBattleDesc}</p>
            </div>
            <div className="glass rounded-4xl p-4 w-full text-center">
              <p className="text-white/50 text-xs font-bold mb-2">{t.gameMathHowToPlay}</p>
              <p className="text-white text-sm font-bold leading-relaxed">
                {t.gameMathHowToPlay1}<br />
                {t.gameMathHowToPlay2}<br />
                {t.gameMathHowToPlay3}
              </p>
            </div>
            <Button variant="primary" size="lg" fullWidth onClick={start}>
              {t.gameMathStartBtn}
            </Button>
          </motion.div>
        )}
      </div>

      {/* Game over modal */}
      <Modal open={phase === 'dead'}>
        <div className="text-center">
          <div className="mb-3"><KamBot mood="sad" size={90} /></div>
          <h2 className="text-white font-black text-2xl mb-1">{t.gameMathGameOver} 💀</h2>
          <p className="font-bold mb-1" style={{ color: 'rgba(254,243,199,0.6)' }}>{t.gameScore}: <span style={{ color: '#D97706' }}>{score}</span></p>
          <p className="text-white/60 mb-1 font-bold">{t.level}: <span className="text-sky-blue">{level}</span></p>
          <p className="text-kazakh-gold font-black mb-5">+{score} 🪙 {t.gameMathAdded}</p>
          <Button variant="primary" fullWidth onClick={start}>{t.gameTryAgain} 💪</Button>
        </div>
      </Modal>
    </GameLayout>
  )
}
