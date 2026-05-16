import { motion } from 'framer-motion'

interface ProgressBarProps {
  value: number        // 0–100
  max?: number
  color?: string
  height?: number
  showLabel?: boolean
  label?: string
  className?: string
  glow?: boolean
}

export default function ProgressBar({
  value,
  max = 100,
  color = '#F5A623',
  height = 10,
  showLabel = false,
  label,
  className = '',
  glow = true,
}: ProgressBarProps) {
  const pct = Math.min(100, Math.max(0, (value / max) * 100))

  return (
    <div className={`w-full ${className}`}>
      {(showLabel || label) && (
        <div className="flex justify-between mb-1 text-xs font-bold text-white/60">
          <span>{label ?? 'XP'}</span>
          <span>{Math.round(pct)}%</span>
        </div>
      )}
      <div
        className="w-full rounded-full overflow-hidden"
        style={{ height, background: 'rgba(255,255,255,0.12)' }}
      >
        <motion.div
          className="h-full rounded-full"
          style={{
            background: color,
            boxShadow: glow ? `0 0 8px 2px ${color}60` : 'none',
          }}
          initial={{ width: 0 }}
          animate={{ width: `${pct}%` }}
          transition={{ duration: 0.7, ease: 'easeOut' }}
        />
      </div>
    </div>
  )
}
