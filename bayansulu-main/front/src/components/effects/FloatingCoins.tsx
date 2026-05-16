import { motion } from 'framer-motion'

interface FloatingCoinsProps {
  count?: number
  onDone?: () => void
}

export default function FloatingCoins({ count = 6, onDone }: FloatingCoinsProps) {
  const coins = Array.from({ length: count }, (_, i) => ({
    id: i,
    x: (Math.random() - 0.5) * 120,
    delay: i * 0.08,
  }))

  return (
    <div className="pointer-events-none absolute inset-0 overflow-visible">
      {coins.map((c, idx) => (
        <motion.div
          key={c.id}
          className="absolute text-2xl"
          style={{ left: '50%', bottom: '40%' }}
          initial={{ opacity: 1, y: 0, x: c.x / 2, scale: 1 }}
          animate={{ opacity: 0, y: -90, x: c.x, scale: 0.5 }}
          transition={{ duration: 0.9, delay: c.delay, ease: 'easeOut' }}
          onAnimationComplete={idx === 0 ? onDone : undefined}
        >
          🪙
        </motion.div>
      ))}
    </div>
  )
}
