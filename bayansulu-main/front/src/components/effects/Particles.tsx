import { useEffect, useState } from 'react'

interface Particle {
  id: number
  x: number
  size: number
  delay: number
  duration: number
  opacity: number
  color: string
}

const COLORS = ['#F5A623', '#00B4D8', '#FF6B35', '#FF4D9E', '#00E5A0']

export default function Particles({ count = 18 }: { count?: number }) {
  const [particles] = useState<Particle[]>(() =>
    Array.from({ length: count }, (_, i) => ({
      id: i,
      x: Math.random() * 100,
      size: 3 + Math.random() * 6,
      delay: Math.random() * 4,
      duration: 4 + Math.random() * 5,
      opacity: 0.15 + Math.random() * 0.45,
      color: COLORS[Math.floor(Math.random() * COLORS.length)],
    }))
  )

  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden">
      {particles.map(p => (
        <div
          key={p.id}
          className="absolute rounded-full animate-particle"
          style={{
            left: `${p.x}%`,
            bottom: '-10px',
            width: p.size,
            height: p.size,
            background: p.color,
            opacity: p.opacity,
            animationDelay: `${p.delay}s`,
            animationDuration: `${p.duration}s`,
          }}
        />
      ))}
    </div>
  )
}
