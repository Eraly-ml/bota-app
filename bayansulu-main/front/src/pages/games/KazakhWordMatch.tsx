import { useState, useCallback } from 'react'
import { motion } from 'framer-motion'
import GameLayout from '@/components/layout/GameLayout'
import KamBot from '@/components/kambot/KamBot'
import Button from '@/components/ui/Button'
import Confetti from '@/components/effects/Confetti'
import { usePlayerStore } from '@/store/playerStore'
import { getTranslation } from '@/data/locale'

interface WordItem {
  id: string
  emoji: string
  wordKk: string
  wordRu: string
}

const WORD_POOL: WordItem[] = [
  { id: 'w1',  emoji: '🐪', wordKk: 'Түйе',    wordRu: 'Верблюд' },
  { id: 'w2',  emoji: '🦅', wordKk: 'Бүркіт',  wordRu: 'Беркут' },
  { id: 'w3',  emoji: '🏔️', wordKk: 'Тау',     wordRu: 'Гора' },
  { id: 'w4',  emoji: '🍎', wordKk: 'Алма',    wordRu: 'Яблоко' },
  { id: 'w5',  emoji: '🌙', wordKk: 'Ай',      wordRu: 'Луна' },
  { id: 'w6',  emoji: '🐴', wordKk: 'Жылқы',   wordRu: 'Лошадь' },
  { id: 'w7',  emoji: '🌸', wordKk: 'Гүл',     wordRu: 'Цветок' },
  { id: 'w8',  emoji: '🌊', wordKk: 'Теңіз',   wordRu: 'Море' },
  { id: 'w9',  emoji: '⭐',  wordKk: 'Жұлдыз',  wordRu: 'Звезда' },
  { id: 'w10', emoji: '🐆', wordKk: 'Ақбарс',  wordRu: 'Снежный барс' },
  { id: 'w11', emoji: '🥛', wordKk: 'Қымыз',   wordRu: 'Кумыс' },
  { id: 'w12', emoji: '🎵', wordKk: 'Домбыра', wordRu: 'Домбра' },
]

function shuffle<T>(arr: T[]): T[] {
  return [...arr].sort(() => Math.random() - 0.5)
}

function buildRounds(): WordItem[][] {
  const shuffled = shuffle(WORD_POOL)
  const rounds: WordItem[][] = []
  for (let i = 0; i < Math.min(8, shuffled.length); i++) {
    const correct = shuffled[i]
    const distractors = shuffle(WORD_POOL.filter(w => w.id !== correct.id)).slice(0, 2)
    rounds.push(shuffle([correct, ...distractors]))
  }
  return rounds
}

export default function KazakhWordMatch() {
  const addCoins    = usePlayerStore(s => s.addCoins)
  const addXP       = usePlayerStore(s => s.addXP)
  const completeGame = usePlayerStore(s => s.completeGame)
  const unlockBadge = usePlayerStore(s => s.unlockBadge)
  const language    = usePlayerStore(s => s.language)
  const t           = getTranslation(language)

  const [rounds]      = useState(buildRounds)
  const [rIdx, setRIdx] = useState(0)
  const [selected, setSelected] = useState<string | null>(null)
  const [correct, setCorrect] = useState<boolean | null>(null)
  const [score, setScore] = useState(0)
  const [confetti, setConfetti] = useState(false)
  const [phase, setPhase] = useState<'playing' | 'complete'>('playing')

  const currentRound = rounds[rIdx]
  const correctWord = rounds[rIdx]?.find(w => WORD_POOL[rIdx]?.id === w.id) ?? rounds[rIdx]?.[0]

  const handlePick = useCallback((id: string) => {
    if (selected !== null) return
    const isCorrect = id === correctWord?.id
    setSelected(id)
    setCorrect(isCorrect)
    if (isCorrect) {
      setScore(s => s + 10)
      setConfetti(true)
      setTimeout(() => setConfetti(false), 1200)
    }

    setTimeout(() => {
      if (rIdx + 1 >= rounds.length) {
        const totalCoins = score + (isCorrect ? 10 : 0)
        addCoins(totalCoins)
        addXP(totalCoins + 20)
        completeGame('words')
        if (isCorrect && score + 10 === rounds.length * 10) unlockBadge('perfect-words')
        unlockBadge('word-master')
        setPhase('complete')
      } else {
        setRIdx(i => i + 1)
        setSelected(null)
        setCorrect(null)
      }
    }, 1200)
  }, [selected, correctWord, rIdx, rounds.length, score, addCoins, addXP, completeGame, unlockBadge])

  const restart = () => {
    setRIdx(0)
    setSelected(null)
    setCorrect(null)
    setScore(0)
    setPhase('playing')
    setConfetti(false)
  }

  if (phase === 'complete') {
    return (
      <GameLayout title={t.gameTitleWords} kambot={{ show: false }}>
        <Confetti active={confetti} />
        <div className="flex-1 flex flex-col items-center justify-center gap-6 px-4">
          <KamBot mood="celebrate" size={120} />
          <div className="text-center">
            <h2 className="text-kazakh-gold font-black text-2xl mb-1">{t.gameComplete} 🎉</h2>
            <p className="text-white font-black text-3xl mb-2">{score} / {rounds.length * 10}</p>
            <p className="text-white/60 text-sm">
              <span className="text-kazakh-gold font-black">+{score} 🪙 +{score + 20} ⭐ XP</span>
            </p>
          </div>
          <Button variant="primary" fullWidth onClick={restart}>{t.gamePlayAgain} 🔄</Button>
        </div>
      </GameLayout>
    )
  }

  return (
    <GameLayout title={t.gameTitleWords} kambot={{ mood: correct === false ? 'sad' : 'happy', show: false }}>
      <Confetti active={confetti} />
      <div className="px-3 pb-3 flex flex-col gap-4">
        {/* Progress */}
        <div className="flex items-center gap-2">
          <div className="flex-1 flex gap-1">
            {rounds.map((_, i) => (
              <div key={i} className="h-1.5 flex-1 rounded-full transition-all duration-500"
                style={{ background: i < rIdx ? '#00E5A0' : i === rIdx ? '#F5A623' : 'rgba(255,255,255,0.15)' }} />
            ))}
          </div>
          <span className="text-white/50 text-xs font-bold">{rIdx + 1}/{rounds.length}</span>
        </div>

        {/* KamBot */}
        <div className="flex items-end gap-2">
          <KamBot mood={correct === false ? 'sad' : correct === true ? 'celebrate' : 'happy'} size={72} />
          <motion.div
            className="glass rounded-3xl p-3 flex-1 text-white text-sm font-bold"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
          >
            {correct === null && (language === 'kk' ? 'Бұл сурет не? Қазақстанша сөзді тап!' : 'Что на картинке? Найди казахское слово!')}
            {correct === true && (language === 'kk' ? 'Дұрыс! Жарайсың!' : 'Правильно! Молодец!')}
            {correct === false && `${language === 'kk' ? 'Дәл емес! Дұрыс жауап:' : 'Не совсем! Правильный ответ:'} ${correctWord?.wordKk}`}
          </motion.div>
        </div>

        {/* Big picture */}
        <motion.div
          className="glass rounded-4xl p-8 flex items-center justify-center"
          initial={{ scale: 0.8 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', stiffness: 300 }}
        >
          <span className="text-8xl">{correctWord?.emoji}</span>
        </motion.div>

        {/* Word options */}
        <div className="grid grid-cols-1 gap-2">
          {currentRound?.map(item => {
            const isSelected = selected === item.id
            const isRight = item.id === correctWord?.id
            const showResult = selected !== null

            let bg = 'rgba(255,255,255,0.08)'
            let border = 'transparent'
            if (showResult && isRight) { bg = 'rgba(0,229,160,0.25)'; border = '#00E5A0' }
            if (showResult && isSelected && !isRight) { bg = 'rgba(255,77,158,0.25)'; border = '#FF4D9E' }

            return (
              <motion.button
                key={item.id}
                className="rounded-3xl p-4 text-white font-black text-xl text-center"
                style={{ background: bg, border: `2px solid ${border}` }}
                whileHover={selected === null ? { scale: 1.03 } : {}}
                whileTap={selected === null ? { scale: 0.95 } : {}}
                animate={showResult && isRight ? { scale: [1, 1.05, 1] } : {}}
                onClick={() => handlePick(item.id)}
              >
                {item.wordKk}
                {showResult && isRight && ' ✅'}
                {showResult && isSelected && !isRight && ' ❌'}
              </motion.button>
            )
          })}
        </div>

        {/* Russian hint (subtle) */}
        <p className="text-center text-white/20 text-xs font-bold">
          {language === 'kk' ? 'Қазақша сөзді тап' : 'Найди слово на казахском'}
        </p>
      </div>
    </GameLayout>
  )
}
