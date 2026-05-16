import { motion } from 'framer-motion'

interface StarBurstProps {
  active: boolean
  x?: number
  y?: number
}

const STARS = ['✨', '⭐', '🌟', '💫', '✨', '⭐']

export default function StarBurst({ active, x = 50, y = 50 }: StarBurstProps) {
  if (!active) return null

  return (
    <div
      className="pointer-events-none absolute z-20"
      style={{ left: `${x}%`, top: `${y}%`, transform: 'translate(-50%,-50%)' }}
    >
      {STARS.map((star, i) => {
        const angle = (360 / STARS.length) * i
        const dist = 50 + Math.random() * 30
        const rad = (angle * Math.PI) / 180
        return (
          <motion.div
            key={i}
            className="absolute text-xl"
            style={{ left: 0, top: 0 }}
            initial={{ opacity: 1, x: 0, y: 0, scale: 0 }}
            animate={{
              opacity: 0,
              x: Math.cos(rad) * dist,
              y: Math.sin(rad) * dist,
              scale: 1.5,
            }}
            transition={{ duration: 0.6, delay: i * 0.05, ease: 'easeOut' }}
          >
            {star}
          </motion.div>
        )
      })}
    </div>
  )
}
