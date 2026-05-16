import { motion } from 'framer-motion'
import type { Badge as BadgeType } from '@/types'

interface BadgeProps {
  badge: BadgeType
  size?: 'sm' | 'md' | 'lg'
  onClick?: () => void
}

export default function BadgeCard({ badge, size = 'md', onClick }: BadgeProps) {
  const dim = size === 'sm' ? 56 : size === 'lg' ? 96 : 72
  const iconSize = size === 'sm' ? 'text-xl' : size === 'lg' ? 'text-4xl' : 'text-3xl'
  const labelSize = size === 'sm' ? 'text-[9px]' : 'text-[11px]'

  return (
    <motion.div
      className="flex flex-col items-center gap-1 cursor-pointer select-none"
      whileHover={{ scale: 1.1 }}
      whileTap={{ scale: 0.92 }}
      onClick={onClick}
    >
      <div
        className="rounded-3xl flex items-center justify-center relative overflow-hidden"
        style={{
          width: dim, height: dim,
          background: badge.earned
            ? 'linear-gradient(135deg, #F5A623, #FF6B35)'
            : 'rgba(255,255,255,0.06)',
          boxShadow: badge.earned ? '0 0 16px 4px rgba(245,166,35,0.45)' : 'none',
          filter: badge.earned ? 'none' : 'grayscale(0.8) opacity(0.45)',
        }}
      >
        <span className={iconSize}>{badge.icon}</span>
        {badge.earned && (
          <motion.div
            className="absolute inset-0 rounded-3xl pointer-events-none"
            style={{
              background: 'linear-gradient(135deg, rgba(255,255,255,0.3) 0%, transparent 60%)',
            }}
          />
        )}
      </div>
      <span
        className={`${labelSize} font-bold text-center leading-tight max-w-[72px]`}
        style={{ color: badge.earned ? '#F5A623' : 'rgba(255,255,255,0.4)' }}
      >
        {badge.name}
      </span>
    </motion.div>
  )
}
