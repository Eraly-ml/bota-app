import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useNavigate } from 'react-router-dom'
import HUDBar from '@/components/layout/HUDBar'
import BottomNav from '@/components/layout/BottomNav'
import KamBot from '@/components/kambot/KamBot'
import ProgressBar from '@/components/ui/ProgressBar'
import Button from '@/components/ui/Button'
import { usePlayerStore } from '@/store/playerStore'
import { useGameStore } from '@/store/gameStore'
import { getTranslation } from '@/data/locale'
import { pageVariants } from '@/hooks/useAnimation'
import { avatars } from '@/data/mockData'

const CORRECT_PIN = '1234'

const GAME_LABELS_RU: Record<string, string> = {
  memory: 'Собери сладости',
  runner: 'Верблюд-Бегун',
  yurt:   'Сборка Юрты',
  quiz:   'Викторина КамБота',
  math:   'Счёт с Ботой',
  words:  'Қазақша сөздер',
}

const GAME_LABELS_KK: Record<string, string> = {
  memory: 'Тәттілерді жина',
  runner: 'Түйе жүгіруші',
  yurt:   'Киіз үй құрау',
  quiz:   'КамБот викторинасы',
  math:   'Ботамен санау',
  words:  'Қазақша сөздер',
}

export default function ParentMode() {
  const navigate  = useNavigate()
  const language  = usePlayerStore(s => s.language)
  const t         = getTranslation(language)
  const gameLabels = language === 'kk' ? GAME_LABELS_KK : GAME_LABELS_RU
  const { name, level, xp, xpToNext, botacoins, streak, badges, completedGames, reset, avatarId, screenTimeLimit, setScreenTimeLimit } = usePlayerStore()
  const { highScores } = useGameStore()

  const [pin, setPin]       = useState('')
  const [unlocked, setUnlocked] = useState(false)
  const [pinError, setPinError] = useState(false)
  const [screenTime, setScreenTime] = useState(screenTimeLimit)

  const handleDigit = (d: string) => {
    if (pin.length >= 4) return
    const newPin = pin + d
    setPin(newPin)
    if (newPin.length === 4) {
      if (newPin === CORRECT_PIN) {
        setUnlocked(true)
        setPinError(false)
      } else {
        setPinError(true)
        setTimeout(() => { setPin(''); setPinError(false) }, 800)
      }
    }
  }

  const earnedBadges = badges.filter(b => b.earned).length

  return (
    <motion.div
      className="min-h-dvh flex flex-col"
      style={{ background: '#0D0404' }}
      variants={pageVariants} initial="initial" animate="animate" exit="exit"
    >
      <HUDBar />

      <div className="flex-1 overflow-y-auto px-3 py-3">

        {!unlocked ? (
          /* PIN Screen */
          <div className="flex flex-col items-center justify-center min-h-[70vh] gap-6">
            <KamBot mood="salute" size={100} />
            <div className="text-center">
              <h2 className="font-black text-2xl mb-1" style={{ color: '#FEF3C7' }}>{t.parentModeTitle}</h2>
              <p className="font-bold text-sm" style={{ color: 'rgba(254,243,199,0.4)' }}>{t.parentPinRequired}</p>
            </div>

            {/* PIN display */}
            <motion.div
              className="flex gap-3"
              animate={pinError ? { x: [-8, 8, -8, 8, 0] } : {}}
              transition={{ duration: 0.35 }}
            >
              {[0, 1, 2, 3].map(i => (
                <div
                  key={i}
                  className="w-12 h-12 rounded-full flex items-center justify-center text-2xl font-black"
                  style={{
                    background: pin.length > i ? '#F5A623' : 'rgba(255,255,255,0.1)',
                    border: pinError ? '2px solid #FF4D9E' : pin.length > i ? '2px solid #FFD700' : '2px solid rgba(255,255,255,0.2)',
                    boxShadow: pin.length > i ? '0 0 12px rgba(245,166,35,0.5)' : 'none',
                  }}
                >
                  {pin.length > i ? '●' : ''}
                </div>
              ))}
            </motion.div>

            {pinError && (
              <motion.p className="font-bold text-sm" style={{ color: '#F87171' }}
                initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                {t.parentWrongPin}
              </motion.p>
            )}

            {/* Number pad */}
            <div className="grid grid-cols-3 gap-3 w-64">
              {['1','2','3','4','5','6','7','8','9','','0','⌫'].map((d, i) => (
                <motion.button
                  key={i}
                  className="h-14 rounded-3xl font-black text-xl text-white flex items-center justify-center"
                  style={{ background: d ? 'rgba(255,255,255,0.1)' : 'transparent' }}
                  whileHover={d ? { scale: 1.08 } : {}}
                  whileTap={d ? { scale: 0.9 } : {}}
                  onClick={() => {
                    if (d === '⌫') setPin(p => p.slice(0, -1))
                    else if (d) handleDigit(d)
                  }}
                >
                  {d}
                </motion.button>
              ))}
            </div>
            <p className="text-white/20 text-xs font-bold">Hint: 1234</p>
          </div>
        ) : (
          /* Dashboard */
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="font-black text-xl" style={{ color: '#FEF3C7' }}>{t.parentDashboard}</h2>
              <motion.div whileHover={{ scale: 1.05 }}>
                <KamBot mood="salute" size={56} />
              </motion.div>
            </div>

            {/* Child summary */}
            <div className="glass rounded-4xl p-4">
              <h3 className="text-xs font-bold mb-3 uppercase tracking-wide" style={{ color: 'rgba(254,243,199,0.45)' }}>{t.parentChildProfile}</h3>
              <div className="flex items-center gap-3 mb-3">
                <div className="w-12 h-12 rounded-full flex items-center justify-center text-2xl"
                  style={{ background: 'rgba(217,119,6,0.18)', border: '1px solid rgba(217,119,6,0.3)' }}>
                  {avatars.find(a => a.id === avatarId)?.emoji ?? '🦅'}
                </div>
                <div>
                  <p className="font-black" style={{ color: '#FEF3C7' }}>{name || (language === 'kk' ? 'Зерттеуші' : 'Исследователь')}</p>
                  <p className="text-sm" style={{ color: 'rgba(254,243,199,0.45)' }}>
                    {t.parentLevelLabel.replace('{level}', String(level))} · {t.parentBadgesEarned.replace('{count}', String(earnedBadges))}
                  </p>
                </div>
                <div className="ml-auto text-right">
                  <p className="font-black" style={{ color: '#D97706' }}>{botacoins}</p>
                  <p className="text-sm font-bold" style={{ color: '#EA580C' }}>{t.parentStreakDays.replace('{days}', String(streak))}</p>
                </div>
              </div>
              <ProgressBar value={xp} max={xpToNext} label={t.rewardsXPTitle} showLabel color="#EA580C" height={10} />
            </div>

            {/* Game progress */}
            <div className="glass rounded-4xl p-4">
              <h3 className="text-xs font-bold mb-3 uppercase tracking-wide" style={{ color: 'rgba(254,243,199,0.45)' }}>{t.parentGameProg}</h3>
              <div className="space-y-2">
                {Object.entries(gameLabels).map(([id, label]) => {
                  const done = completedGames.includes(id)
                  const hs   = highScores[id] ?? 0
                  return (
                    <div key={id} className="flex items-center gap-2">
                      <span className="text-sm font-bold flex-1" style={{ color: 'rgba(254,243,199,0.7)' }}>{label}</span>
                      <span className="text-xs font-bold" style={{ color: done ? '#10B981' : 'rgba(255,255,255,0.3)' }}>
                        {done ? t.parentDone : t.parentNotYet}
                      </span>
                      {hs > 0 && <span className="text-xs font-bold" style={{ color: '#D97706' }}>{hs}</span>}
                    </div>
                  )
                })}
              </div>
            </div>

            {/* Screen time */}
            <div className="glass rounded-4xl p-4">
              <h3 className="text-xs font-bold mb-2 uppercase tracking-wide" style={{ color: 'rgba(254,243,199,0.45)' }}>{t.parentScreenLimit}</h3>
              <div className="flex items-center gap-3">
                <span className="font-black text-2xl" style={{ color: '#FEF3C7' }}>{t.parentScreenMin.replace('{min}', String(screenTime))}</span>
                <input
                  type="range" min={15} max={180} step={15}
                  value={screenTime}
                  onChange={e => {
                    const val = Number(e.target.value)
                    setScreenTime(val)
                    setScreenTimeLimit(val)
                  }}
                  className="flex-1"
                  style={{ accentColor: '#EA580C' }}
                />
              </div>
              <p className="text-xs mt-1" style={{ color: 'rgba(254,243,199,0.28)' }}>{t.parentScreenHint}</p>
            </div>

            {/* Educational stats */}
            <div className="glass rounded-4xl p-4">
              <h3 className="text-xs font-bold mb-3 uppercase tracking-wide" style={{ color: 'rgba(254,243,199,0.45)' }}>{t.parentLearnStats}</h3>
              <div className="grid grid-cols-2 gap-3">
                {[
                  { label: t.parentStatMath,  val: '48+', icon: '🔢', color: '#0EA5E9' },
                  { label: t.parentStatQuiz,  val: '30+', icon: '🗺️', color: '#D97706' },
                  { label: t.parentStatPairs, val: '24+', icon: '🧠', color: '#10B981' },
                  { label: t.parentStatYurts, val: completedGames.includes('yurt') ? '1' : '0', icon: '🏕️', color: '#EA580C' },
                ].map(s => (
                  <div key={s.label} className="rounded-3xl p-3 text-center" style={{ background: 'rgba(107,26,26,0.3)', border: '1px solid rgba(234,88,12,0.15)' }}>
                    <span className="text-2xl">{s.icon}</span>
                    <p className="font-black text-xl mt-1" style={{ color: s.color }}>{s.val}</p>
                    <p className="text-[10px] font-bold" style={{ color: 'rgba(254,243,199,0.4)' }}>{s.label}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Reset button */}
            <Button variant="ghost" fullWidth onClick={() => {
              if (confirm(t.parentResetConfirm)) {
                reset(); setUnlocked(false); navigate('/splash')
              }
            }}>
              {t.parentResetBtn}
            </Button>

            <div className="h-4" />
          </div>
        )}
      </div>

      <BottomNav />
    </motion.div>
  )
}
