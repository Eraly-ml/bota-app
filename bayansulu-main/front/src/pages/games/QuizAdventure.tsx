import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import GameLayout from '@/components/layout/GameLayout'
import KamBot from '@/components/kambot/KamBot'
import Button from '@/components/ui/Button'
import Modal from '@/components/ui/Modal'
import Confetti from '@/components/effects/Confetti'
import { getRandomQuestions } from '@/data/quizQuestions'
import { usePlayerStore } from '@/store/playerStore'
import { getTranslation } from '@/data/locale'
import type { QuizQuestion, KamBotMood } from '@/types'

type Phase = 'dialogue' | 'question' | 'result' | 'complete'

export default function QuizAdventure() {
  const addCoins    = usePlayerStore(s => s.addCoins)
  const addXP       = usePlayerStore(s => s.addXP)
  const completeGame = usePlayerStore(s => s.completeGame)
  const unlockBadge = usePlayerStore(s => s.unlockBadge)
  const language    = usePlayerStore(s => s.language)
  const t           = getTranslation(language)

  const [questions]   = useState<QuizQuestion[]>(getRandomQuestions(10))
  const [qIdx, setQIdx]   = useState(0)
  const [phase, setPhase] = useState<Phase>('dialogue')
  const [selected, setSelected] = useState<number | null>(null)
  const [correct, setCorrect] = useState<boolean | null>(null)
  const [score, setScore] = useState(0)
  const [stickers, setStickers] = useState<string[]>([])
  const [confetti, setConfetti] = useState(false)
  const [kamMood, setKamMood] = useState<KamBotMood>('happy')

  const q = questions[qIdx]

  // Auto-advance from dialogue
  useEffect(() => {
    if (phase !== 'dialogue') return
    const t = setTimeout(() => setPhase('question'), 2000)
    return () => clearTimeout(t)
  }, [phase, qIdx])

  const answer = (idx: number) => {
    if (phase !== 'question' || selected !== null) return
    const isCorrect = idx === q.correctIndex
    setSelected(idx)
    setCorrect(isCorrect)

    if (isCorrect) {
      setScore(s => s + 10)
      setStickers(st => [...st, q.sticker])
      setKamMood('celebrate')
      setConfetti(true)
      setTimeout(() => setConfetti(false), 1500)
    } else {
      setKamMood('sad')
    }

    setTimeout(() => {
      setPhase('result')
    }, 900)
  }

  const next = () => {
    if (qIdx + 1 >= questions.length) {
      // Complete!
      const totalCoins = score * 2
      addCoins(totalCoins)
      addXP(score + 20)
      completeGame('quiz')
      if (score === 100) unlockBadge('perfect-quiz')
      unlockBadge('quiz-champion')
      setPhase('complete')
    } else {
      setQIdx(i => i + 1)
      setPhase('dialogue')
      setSelected(null)
      setCorrect(null)
      setKamMood('happy')
    }
  }

  const restart = () => {
    setQIdx(0); setPhase('dialogue'); setSelected(null); setCorrect(null)
    setScore(0); setStickers([]); setConfetti(false); setKamMood('happy')
  }

  return (
    <GameLayout title={t.gameTitleQuiz} kambot={{ show: false }}>
      <Confetti active={confetti} />

      <div className="px-3 pb-3 flex flex-col gap-3">
        {/* Progress */}
        <div className="flex items-center gap-2">
          <div className="flex-1 flex gap-1">
            {questions.map((_, i) => (
              <div key={i} className="h-1.5 flex-1 rounded-full transition-all duration-500"
                style={{ background: i < qIdx ? '#00E5A0' : i === qIdx ? '#F5A623' : 'rgba(255,255,255,0.15)' }} />
            ))}
          </div>
          <span className="text-white/50 text-xs font-bold">{qIdx + 1}/10</span>
        </div>

        {/* KamBot + dialogue */}
        <div className="flex items-end gap-2">
          <KamBot mood={kamMood} size={72} className={kamMood === 'celebrate' ? 'animate-wiggle' : ''} />
          <AnimatePresence mode="wait">
            <motion.div
              key={`${qIdx}-dialogue`}
              className="glass rounded-3xl p-3 flex-1 text-white text-sm font-bold"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
            >
              {phase === 'dialogue' && `${['🌟', '🤔', '🎯', '💡', '🚀'][qIdx % 5]} ${t.gameQuizKnow}`}
              {phase === 'question' && `${t.gameQuizQuestion} ${qIdx + 1}: ${q.category.toUpperCase()} 📚`}
              {phase === 'result' && correct && `✅ ${t.gameQuizCorrect} ${q.fact[language]}`}
              {phase === 'result' && !correct && `❌ ${t.gameQuizNotQuite} ${q.fact[language]}`}
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Question card */}
        {phase !== 'dialogue' && (
          <AnimatePresence mode="wait">
            <motion.div
              key={qIdx}
              className="glass rounded-4xl p-4"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
            >
              <p className="text-white font-black text-base text-center mb-4 leading-snug">
                {q.question[language]}
              </p>

              <div className="grid grid-cols-2 gap-2">
                {q.answers[language].map((ans, i) => {
                  const isSelected = selected === i
                  const isRight    = i === q.correctIndex
                  const showResult = selected !== null

                  let bg = 'rgba(255,255,255,0.08)'
                  let border = 'transparent'
                  if (showResult && isRight)    { bg = 'rgba(0,229,160,0.25)'; border = '#00E5A0' }
                  if (showResult && isSelected && !isRight) { bg = 'rgba(255,77,158,0.25)'; border = '#FF4D9E' }

                  return (
                    <motion.button
                      key={i}
                      className="rounded-3xl p-3 text-white font-bold text-sm text-left leading-snug"
                      style={{ background: bg, border: `2px solid ${border}` }}
                      whileHover={selected === null ? { scale: 1.03 } : {}}
                      whileTap={selected === null ? { scale: 0.95 } : {}}
                      animate={showResult && isRight ? { scale: [1, 1.05, 1] } : {}}
                      onClick={() => answer(i)}
                    >
                      <span className="mr-1">{['🅐', '🅑', '🅒', '🅓'][i]}</span>
                      {ans}
                      {showResult && isRight && ' ✅'}
                      {showResult && isSelected && !isRight && ' ❌'}
                    </motion.button>
                  )
                })}
              </div>

              {phase === 'result' && (
                <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="mt-3">
                  <Button variant="primary" fullWidth onClick={next}>
                    {qIdx + 1 >= questions.length ? `🏁 ${t.gameQuizSeeResults}` : `${t.gameQuizNextQuestion} →`}
                  </Button>
                </motion.div>
              )}
            </motion.div>
          </AnimatePresence>
        )}

        {/* Sticker collection */}
        {stickers.length > 0 && (
          <div className="glass rounded-3xl p-3">
            <p className="text-white/50 text-xs font-bold mb-2">🎴 {t.gameQuizStickers}</p>
            <div className="flex flex-wrap gap-2">
              {stickers.map((s, i) => (
                <motion.span key={i} className="text-2xl" initial={{ scale: 0 }} animate={{ scale: 1 }}
                  transition={{ type: 'spring', stiffness: 400, delay: i * 0.05 }}>
                  {s}
                </motion.span>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Complete modal */}
      <Modal open={phase === 'complete'}>
        <div className="text-center">
          <div className="mb-3"><KamBot mood="celebrate" size={100} /></div>
          <h2 className="text-kazakh-gold font-black text-2xl mb-1">{t.gameQuizComplete} 🏆</h2>
          <p className="text-white font-black text-3xl mb-2">{score} / 100</p>
          <p className="text-white/60 text-sm mb-2">
            <span className="text-kazakh-gold font-black">+{score * 2} 🪙 +{score + 20} ⭐ XP</span>
          </p>
          <div className="glass rounded-3xl p-3 mb-4">
            <p className="text-white/50 text-xs font-bold mb-1">{t.gameQuizStickersEarned}</p>
            <div className="flex flex-wrap gap-1 justify-center text-2xl">
              {stickers.map((s, i) => <span key={i}>{s}</span>)}
            </div>
          </div>
          <Button variant="primary" fullWidth onClick={restart}>{t.gamePlayAgain} 🔄</Button>
        </div>
      </Modal>
    </GameLayout>
  )
}
