import { motion } from 'framer-motion'
import {
  SpeakerHigh,
  SpeakerSlash,
  Globe,
  Flame,
  Coins,
} from '@phosphor-icons/react'
import { usePlayerStore } from '@/store/playerStore'
import { avatars } from '@/data/mockData'
import ProgressBar from '@/components/ui/ProgressBar'

export default function HUDBar() {
  const {
    name, avatarId, level, xp, xpToNext,
    botacoins, streak, language, setLanguage,
    soundMuted, setSoundMuted,
  } = usePlayerStore()

  const avatar = avatars[avatarId] ?? avatars[0]

  return (
    <div
      className="glass-dark sticky top-0 z-40 px-3 py-2 flex items-center gap-2.5"
      style={{ borderBottom: '1px solid rgba(234,88,12,0.12)' }}
    >
      {/* Avatar bubble */}
      <div
        className={`w-9 h-9 rounded-full flex items-center justify-center text-lg shrink-0 ${avatar.bg}`}
        style={{ boxShadow: '0 0 0 2px rgba(217,119,6,0.35)' }}
      >
        {avatar.emoji}
      </div>

      {/* Name + XP bar */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center justify-between mb-0.5">
          <span className="text-cream font-black text-sm tracking-tight truncate max-w-[88px]">
            {name || 'Explorer'}
          </span>
          <span
            className="text-[10px] font-black tracking-wider"
            style={{ color: 'rgba(217,119,6,0.7)' }}
          >
            LV.{level}
          </span>
        </div>
        <ProgressBar value={xp} max={xpToNext} height={5} color="#EA580C" />
      </div>

      {/* Controls cluster */}
      <div className="flex items-center gap-1 shrink-0">

        {/* Language toggle */}
        <motion.button
          className="flex items-center gap-1 px-1.5 py-0.5 rounded-full text-[10px] font-black tracking-wider select-none"
          style={{
            background: 'rgba(255,255,255,0.07)',
            border: '1px solid rgba(255,255,255,0.08)',
            color: 'rgba(255,255,255,0.7)',
          }}
          whileTap={{ scale: 0.88 }}
          onClick={() => setLanguage(language === 'ru' ? 'kk' : 'ru')}
        >
          <Globe size={10} weight="bold" />
          {language === 'ru' ? 'KK' : 'RU'}
        </motion.button>

        {/* Sound toggle */}
        <motion.button
          className="p-1.5 rounded-full select-none"
          style={{
            background: soundMuted ? 'rgba(220,38,38,0.15)' : 'rgba(255,255,255,0.06)',
            border: '1px solid rgba(255,255,255,0.07)',
            color: soundMuted ? '#DC2626' : 'rgba(255,255,255,0.5)',
          }}
          whileTap={{ scale: 0.85 }}
          onClick={() => setSoundMuted(!soundMuted)}
        >
          {soundMuted
            ? <SpeakerSlash size={13} weight="bold" />
            : <SpeakerHigh  size={13} weight="bold" />
          }
        </motion.button>
      </div>

      {/* Streak */}
      {streak > 0 && (
        <motion.div
          className="flex items-center gap-0.5 shrink-0"
          animate={{ scale: [1, 1.12, 1] }}
          transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
        >
          <Flame size={15} weight="fill" color="#EA580C" />
          <span className="text-xs font-black" style={{ color: '#EA580C' }}>{streak}</span>
        </motion.div>
      )}

      {/* Coins */}
      <div className="flex items-center gap-1 shrink-0">
        <Coins size={15} weight="fill" color="#D97706" />
        <motion.span
          key={botacoins}
          className="text-sm font-black"
          style={{ color: '#FCD34D' }}
          initial={{ scale: 1.35 }}
          animate={{ scale: 1 }}
          transition={{ duration: 0.22, type: 'spring', stiffness: 500 }}
        >
          {botacoins}
        </motion.span>
      </div>
    </div>
  )
}
