import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { usePlayerStore } from '@/store/playerStore'
import { avatars } from '@/data/mockData'
import { getTranslation } from '@/data/locale'
import Button from '@/components/ui/Button'
import KamBot from '@/components/kambot/KamBot'
import Confetti from '@/components/effects/Confetti'
import { slideInFromRight } from '@/hooks/useAnimation'

const AGES = [7, 8, 9, 10, 11]

export default function Onboarding() {
  const navigate  = useNavigate()
  const language  = usePlayerStore(s => s.language)
  const t         = getTranslation(language)
  const { setName, setAge, setAvatar, completeOnboarding, unlockBadge, addCoins, addXP } = usePlayerStore()

  const [step, setStep]           = useState(1)
  const [localName, setLocalName] = useState('')
  const [localAge, setLocalAge]   = useState(8)
  const [localAvatar, setLocalAvatar] = useState(0)
  const [showConfetti, setShowConfetti] = useState(false)

  const goNext = () => setStep(s => s + 1)

  const finish = () => {
    const fallback = language === 'kk' ? 'Зерттеуші' : 'Исследователь'
    setName(localName || fallback)
    setAge(localAge)
    setAvatar(localAvatar)
    completeOnboarding()
    unlockBadge('first-steps')
    addCoins(50)
    addXP(30)
    setShowConfetti(true)
    setTimeout(() => navigate('/map'), 2200)
  }

  return (
    <div
      className="min-h-dvh flex flex-col relative overflow-hidden"
      style={{ background: '#0D0404' }}
    >
      <Confetti active={showConfetti} />

      {/* Progress dots */}
      <div className="flex justify-center gap-2 pt-8 pb-4">
        {[1, 2, 3, 4].map(s => (
          <motion.div
            key={s}
            className="rounded-full"
            animate={{
              width:      step === s ? 24 : 8,
              background: step >= s ? '#EA580C' : 'rgba(255,255,255,0.2)',
            }}
            style={{ height: 8 }}
            transition={{ type: 'spring', stiffness: 400, damping: 25 }}
          />
        ))}
      </div>

      <AnimatePresence mode="wait">
        {/* ── Step 1: Name ── */}
        {step === 1 && (
          <motion.div
            key="step1"
            className="flex-1 flex flex-col items-center justify-center px-6 gap-6"
            variants={slideInFromRight} initial="initial" animate="animate" exit="exit"
          >
            <KamBot mood="happy" size={110} className="animate-float" />
            <div className="text-center">
              <h2 className="font-black text-2xl mb-1" style={{ color: '#FEF3C7' }}>
                {t.onboardHey}
              </h2>
              <p className="font-bold text-sm" style={{ color: 'rgba(254,243,199,0.55)' }}>
                {t.onboardNameQuest}
              </p>
            </div>
            <input
              className="w-full text-center text-xl font-black rounded-3xl px-5 py-4 outline-none border-2 transition-colors"
              style={{
                background:   'rgba(255,255,255,0.06)',
                borderColor:  localName ? '#EA580C' : 'rgba(255,255,255,0.14)',
                color:        '#FEF3C7',
              }}
              placeholder={t.onboardTypePlaceholder}
              value={localName}
              onChange={e => setLocalName(e.target.value)}
              maxLength={20}
              autoFocus
            />
            <Button
              variant="primary" size="lg" fullWidth
              disabled={localName.trim().length < 2}
              onClick={goNext}
            >
              {t.onboardLetsGo}
            </Button>
          </motion.div>
        )}

        {/* ── Step 2: Age ── */}
        {step === 2 && (
          <motion.div
            key="step2"
            className="flex-1 flex flex-col items-center justify-center px-6 gap-6"
            variants={slideInFromRight} initial="initial" animate="animate" exit="exit"
          >
            <KamBot mood="thinking" size={110} className="animate-float" />
            <div className="text-center">
              <h2 className="font-black text-2xl mb-1" style={{ color: '#FEF3C7' }}>
                {t.onboardHowOld.replace('{name}', localName)}
              </h2>
              <p className="font-bold text-sm" style={{ color: 'rgba(254,243,199,0.55)' }}>
                {t.onboardPickAge}
              </p>
            </div>
            <div className="flex gap-3">
              {AGES.map(age => (
                <motion.button
                  key={age}
                  className="w-14 h-14 rounded-full font-black text-lg flex items-center justify-center"
                  style={{
                    background: localAge === age ? '#EA580C' : 'rgba(255,255,255,0.08)',
                    color:      localAge === age ? '#FEF3C7' : 'rgba(254,243,199,0.7)',
                    border:     localAge === age ? '2px solid #D97706' : '2px solid transparent',
                    boxShadow:  localAge === age ? '0 0 16px rgba(234,88,12,0.5)' : 'none',
                  }}
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                  onClick={() => setLocalAge(age)}
                >
                  {age}
                </motion.button>
              ))}
            </div>
            <Button variant="primary" size="lg" fullWidth onClick={goNext}>
              {t.onboardThatIsMe}
            </Button>
          </motion.div>
        )}

        {/* ── Step 3: Avatar ── */}
        {step === 3 && (
          <motion.div
            key="step3"
            className="flex-1 flex flex-col items-center justify-center px-6 gap-6"
            variants={slideInFromRight} initial="initial" animate="animate" exit="exit"
          >
            <KamBot mood="idle" size={110} className="animate-float" />
            <div className="text-center">
              <h2 className="font-black text-2xl mb-1" style={{ color: '#FEF3C7' }}>
                {t.onboardPickAvatar}
              </h2>
              <p className="font-bold text-sm" style={{ color: 'rgba(254,243,199,0.55)' }}>
                {t.onboardWhoWantBe}
              </p>
            </div>
            <div className="grid grid-cols-3 gap-4 w-full max-w-xs">
              {avatars.map(av => (
                <motion.button
                  key={av.id}
                  className="flex flex-col items-center gap-2"
                  whileHover={{ scale: 1.08 }}
                  whileTap={{ scale: 0.9 }}
                  onClick={() => setLocalAvatar(av.id)}
                >
                  <div
                    className={`w-16 h-16 rounded-3xl flex items-center justify-center text-3xl ${av.bg}`}
                    style={{
                      border:    localAvatar === av.id ? '3px solid #D97706' : '3px solid transparent',
                      boxShadow: localAvatar === av.id ? '0 0 20px rgba(217,119,6,0.6)' : 'none',
                    }}
                  >
                    {av.emoji}
                  </div>
                  <span className="text-xs font-bold" style={{ color: 'rgba(254,243,199,0.65)' }}>
                    {av.label}
                  </span>
                </motion.button>
              ))}
            </div>
            <Button variant="primary" size="lg" fullWidth onClick={goNext}>
              {t.onboardThisIsMe}
            </Button>
          </motion.div>
        )}

        {/* ── Step 4: Welcome ── */}
        {step === 4 && (
          <motion.div
            key="step4"
            className="flex-1 flex flex-col items-center justify-center px-6 gap-6 text-center"
            variants={slideInFromRight} initial="initial" animate="animate" exit="exit"
          >
            <motion.div
              animate={{ scale: [1, 1.1, 1], rotate: [-3, 3, -3, 3, 0] }}
              transition={{ duration: 1.2, repeat: 2 }}
            >
              <KamBot mood="celebrate" size={140} />
            </motion.div>
            <div>
              <h2 className="font-brand font-black text-3xl mb-2" style={{ color: '#D97706' }}>
                {t.onboardWelcome.replace('{name}', localName)}
              </h2>
              <p className="font-bold text-base leading-relaxed px-2" style={{ color: 'rgba(254,243,199,0.75)' }}>
                {t.onboardGuide}
                <br />
                <span style={{ color: '#D97706' }}>{t.onboardBonus}</span>
              </p>
            </div>
            <div
              className="rounded-3xl p-4 w-full"
              style={{
                background: 'rgba(107,26,26,0.4)',
                border:     '1px solid rgba(234,88,12,0.2)',
              }}
            >
              <div className="flex items-center gap-3">
                <div
                  className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl ${avatars[localAvatar]?.bg}`}
                >
                  {avatars[localAvatar]?.emoji}
                </div>
                <div className="text-left">
                  <p className="font-black" style={{ color: '#FEF3C7' }}>{localName}</p>
                  <p className="text-sm" style={{ color: 'rgba(254,243,199,0.45)' }}>
                    {t.onboardProfileAge.replace('{age}', String(localAge))}
                  </p>
                </div>
                <div className="ml-auto font-black" style={{ color: '#D97706' }}>50</div>
              </div>
            </div>
            <Button variant="primary" size="lg" fullWidth onClick={finish}>
              {t.onboardStartBtn}
            </Button>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
