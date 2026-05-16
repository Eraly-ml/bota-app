import { motion } from 'framer-motion'
import { useEffect, useState } from 'react'

const COLORS = ['#F5A623', '#00B4D8', '#FF6B35', '#FF4D9E', '#00E5A0', '#FFD700']

interface Piece {
  id: number
  x: number
  color: string
  size: number
  delay: number
  duration: number
  rotation: number
  shape: 'square' | 'circle' | 'strip'
}

interface ConfettiProps {
  active: boolean
  count?: number
}

export default function Confetti({ active, count = 48 }: ConfettiProps) {
  const [pieces, setPieces] = useState<Piece[]>([])

  useEffect(() => {
    if (!active) { setPieces([]); return }
    const newPieces: Piece[] = Array.from({ length: count }, (_, i) => ({
      id: i,
      x: Math.random() * 100,
      color: COLORS[Math.floor(Math.random() * COLORS.length)],
      size: 6 + Math.random() * 8,
      delay: Math.random() * 0.4,
      duration: 1.2 + Math.random() * 1,
      rotation: Math.random() * 720 - 360,
      shape: (['square', 'circle', 'strip'] as const)[Math.floor(Math.random() * 3)],
    }))
    setPieces(newPieces)
    const t = setTimeout(() => setPieces([]), (count * 0.4 + 2.5) * 1000)
    return () => clearTimeout(t)
  }, [active, count])

  if (!pieces.length) return null

  return (
    <div className="pointer-events-none fixed inset-0 z-[100] overflow-hidden">
      {pieces.map(p => (
        <motion.div
          key={p.id}
          className="absolute top-0"
          style={{
            left: `${p.x}%`,
            width: p.shape === 'strip' ? p.size / 2 : p.size,
            height: p.shape === 'strip' ? p.size * 3 : p.size,
            borderRadius: p.shape === 'circle' ? '50%' : p.shape === 'strip' ? '2px' : '2px',
            background: p.color,
          }}
          initial={{ y: -20, rotate: 0, opacity: 1 }}
          animate={{
            y: '110vh',
            rotate: p.rotation,
            opacity: [1, 1, 0.8, 0],
          }}
          transition={{ duration: p.duration, delay: p.delay, ease: 'easeIn' }}
        />
      ))}
    </div>
  )
}
