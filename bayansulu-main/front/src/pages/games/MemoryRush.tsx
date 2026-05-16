import { useState, useEffect, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import GameLayout from '@/components/layout/GameLayout'
import KamBot from '@/components/kambot/KamBot'
import Modal from '@/components/ui/Modal'
import Button from '@/components/ui/Button'
import Confetti from '@/components/effects/Confetti'
import FloatingCoins from '@/components/effects/FloatingCoins'
import { memoryCardTypes } from '@/data/mockData'
import { usePlayerStore } from '@/store/playerStore'
import { getTranslation } from '@/data/locale'
import { useGameStore } from '@/store/gameStore'
import type { MemoryCard } from '@/types'

const GAME_TIME = 70

function buildDeck(): MemoryCard[] {
  const types = [...memoryCardTypes].sort(() => Math.random() - 0.5).slice(0, 8)
  const cards: MemoryCard[] = []
  types.forEach(t => {
    cards.push({ id: cards.length,     pairId: t.pairId, icon: t.icon, label: t.label, flipped: false, matched: false })
    cards.push({ id: cards.length,     pairId: t.pairId, icon: t.icon, label: t.label, flipped: false, matched: false })
  })
  return cards.sort(() => Math.random() - 0.5)
}

export default function MemoryRush() {
  const addCoins    = usePlayerStore(s => s.addCoins)
  const addXP       = usePlayerStore(s => s.addXP)
  const completeGame = usePlayerStore(s => s.completeGame)
  const unlockBadge = usePlayerStore(s => s.unlockBadge)
  const language    = usePlayerStore(s => s.language)
  const t           = getTranslation(language)
  const setHighScore = useGameStore(s => s.setHighScore)

  const [cards, setCards] = useState<MemoryCard[]>(buildDeck)
  const [selected, setSelected] = useState<number[]>([])
  const [locked, setLocked] = useState(false)
  const [timeLeft, setTimeLeft] = useState(GAME_TIME)
  const [combo, setCombo] = useState(0)
  const [score, setScore] = useState(0)
  const [phase, setPhase] = useState<'playing' | 'won' | 'lost'>('playing')
  const [showCoins, setShowCoins] = useState(false)
  const [confetti, setConfetti] = useState(false)
  const [matchedPair, setMatchedPair] = useState<number | null>(null)

  // Timer
  useEffect(() => {
    if (phase !== 'playing') return
    if (timeLeft <= 0) { setPhase('lost'); return }
    const t = setInterval(() => setTimeLeft(s => s - 1), 1000)
    return () => clearInterval(t)
  }, [phase, timeLeft])

  const handleCardClick = useCallback((id: number) => {
    if (locked || phase !== 'playing') return
    const card = cards.find(c => c.id === id)
    if (!card) return
    if (card.flipped || card.matched) return
    if (selected.length === 1 && selected[0] === id) return

    const newSelected = [...selected, id]
    setCards(prev => prev.map(c => c.id === id ? { ...c, flipped: true } : c))

    if (newSelected.length === 2) {
      setLocked(true)
      const [idA, idB] = newSelected
      const cA = cards.find(c => c.id === idA)
      const cB = cards.find(c => c.id === idB)

      if (!cA || !cB) {
        setLocked(false)
        setSelected([])
        return
      }

      setTimeout(() => {
        if (cA.pairId === cB.pairId) {
          // Match!
          const newCombo = combo + 1
          const gain = 10 * (newCombo >= 3 ? 2 : 1)
          setCombo(newCombo)
          setScore(s => s + gain)
          setShowCoins(true)
          setMatchedPair(cA.pairId)
          setTimeout(() => setMatchedPair(null), 800)

          setCards(prev => {
            const nextCards = prev.map(c =>
              c.pairId === cA.pairId ? { ...c, matched: true } : c
            )
            // Check win
            const allMatched = nextCards.every(c => c.matched)
            if (allMatched) {
              const finalScore = score + gain + timeLeft * 2
              setScore(finalScore)
              addCoins(finalScore)
              addXP(60)
              completeGame('memory')
              unlockBadge('memory-master')
              setHighScore('memory', finalScore)
              setConfetti(true)
              setPhase('won')
            }
            return nextCards
          })
        } else {
          // No match
          setCombo(0)
          setCards(prev => prev.map(c =>
            (c.id === idA || c.id === idB) && !c.matched ? { ...c, flipped: false } : c
          ))
        }
        setSelected([])
        setLocked(false)
      }, 900)
    } else {
      setSelected(newSelected)
    }
  }, [cards, selected, locked, phase, combo, score, timeLeft, addCoins, addXP, completeGame, unlockBadge, setHighScore])

  const restart = () => {
    setCards(buildDeck())
    setSelected([])
    setLocked(false)
    setTimeLeft(GAME_TIME)
    setCombo(0)
    setScore(0)
    setPhase('playing')
    setConfetti(false)
  }

  const timerPct = (timeLeft / GAME_TIME) * 100
  const timerColor = timerPct > 50 ? '#00E5A0' : timerPct > 25 ? '#F5A623' : '#FF4D9E'

  return (
    <GameLayout title={t.gameTitleMemory} kambot={{ mood: combo >= 3 ? 'celebrate' : 'happy', show: false }}>
      <Confetti active={confetti} />

      <div className="px-3 pb-3">
        {/* Stats bar */}
        <div className="flex items-center gap-3 mb-3">
          <div className="flex-1 h-3 rounded-full overflow-hidden" style={{ background: 'rgba(255,255,255,0.12)' }}>
            <motion.div
              className="h-full rounded-full"
              style={{ background: timerColor }}
              animate={{ width: `${timerPct}%` }}
              transition={{ duration: 0.5 }}
            />
          </div>
          <span className="text-white font-black text-sm w-7 text-center">{timeLeft}</span>
          {combo >= 2 && (
            <motion.div
              className="text-warm-orange font-black text-sm flex items-center gap-1"
              animate={{ scale: [1, 1.3, 1] }}
              transition={{ duration: 0.4, repeat: Infinity }}
            >
              🔥 {combo}×
            </motion.div>
          )}
          <span className="text-kazakh-gold font-black text-sm">🪙 {score}</span>
        </div>

        {/* Card grid */}
        <div className="grid grid-cols-4 gap-2">
          {cards.map(card => (
            <motion.div
              key={card.id}
              className="aspect-square perspective-1000 cursor-pointer"
              onClick={() => handleCardClick(card.id)}
              whileTap={{ scale: 0.92 }}
            >
              <motion.div
                className="w-full h-full relative preserve-3d"
                animate={{ rotateY: card.flipped || card.matched ? 180 : 0 }}
                transition={{ duration: 0.35, type: 'spring', stiffness: 300 }}
              >
                {/* Back */}
                <div className="absolute inset-0 backface-hidden rounded-2xl flex items-center justify-center"
                  style={{ background: 'linear-gradient(135deg, #2D1B69, #1A0A2E)', border: '2px solid rgba(245,166,35,0.3)' }}>
                  <span className="text-2xl opacity-70">🇰🇿</span>
                </div>
                {/* Front */}
                <div
                  className="absolute inset-0 backface-hidden rotate-y-180 rounded-2xl flex items-center justify-center"
                  style={{
                    background: card.matched
                      ? 'linear-gradient(135deg, #00E5A0, #00B4D8)'
                      : 'linear-gradient(135deg, #3D2A7A, #2D1B69)',
                    border: card.matched
                      ? '2px solid #00E5A0'
                      : matchedPair === card.pairId
                      ? '2px solid #F5A623'
                      : '2px solid rgba(255,255,255,0.2)',
                    boxShadow: card.matched ? '0 0 12px rgba(0,229,160,0.5)' : 'none',
                  }}
                >
                  <span className="text-2xl">{card.icon}</span>
                </div>
              </motion.div>
            </motion.div>
          ))}
        </div>

        {showCoins && <FloatingCoins count={4} onDone={() => setShowCoins(false)} />}
      </div>

      {/* Win modal */}
      <Modal open={phase === 'won'} onClose={restart}>
        <div className="text-center">
          <div className="mb-4"><KamBot mood="celebrate" size={100} /></div>
          <h2 className="text-kazakh-gold font-black text-2xl mb-1">{t.gameWon} 🎉</h2>
          <p className="font-bold mb-4" style={{ color: 'rgba(254,243,199,0.6)' }}>{t.gameScore}: <span style={{ color: '#D97706' }}>{score}</span></p>
          <p className="text-white font-bold text-sm mb-5">+{score} 🪙 +60 ⭐ {language === 'kk' ? 'сенің шотыңа қосылды!' : 'добавлено на твой счёт!'}</p>
          <Button variant="primary" fullWidth onClick={restart}>{t.gamePlayAgain} 🔄</Button>
        </div>
      </Modal>

      {/* Lost modal */}
      <Modal open={phase === 'lost'} onClose={restart}>
        <div className="text-center">
          <div className="mb-4"><KamBot mood="sad" size={100} /></div>
          <h2 className="text-white font-black text-2xl mb-1">{t.gameTimesUp} ⏰</h2>
          <p className="text-white/60 font-bold mb-5">
            {cards.filter(c => c.matched).length / 2} / 8 {t.gameMemoryPairsFound}
          </p>
          <Button variant="primary" fullWidth onClick={restart}>{t.gameTryAgain} 💪</Button>
        </div>
      </Modal>
    </GameLayout>
  )
}
