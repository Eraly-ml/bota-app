import { useState } from 'react'
import { motion } from 'framer-motion'
import type { KamBotMood } from '@/types'

interface KamBotProps {
  mood?: KamBotMood
  size?: number
  className?: string
}

const moodVariants: Record<KamBotMood, any> = {
  idle: {
    y:          [0, -10, 0],
    transition: { duration: 2.8, repeat: Infinity, ease: 'easeInOut' },
  },
  happy: {
    rotate:     [-3, 3, -3],
    y:          [0, -6, 0],
    transition: { duration: 0.7, repeat: Infinity },
  },
  celebrate: {
    scale:      [1, 1.14, 1, 1.14, 1],
    rotate:     [-5, 5, -5, 5, 0],
    transition: { duration: 0.7, repeat: 3 },
  },
  sad: {
    rotate:     -8,
    y:          6,
    transition: { duration: 0.5 },
  },
  thinking: {
    rotate:     [0, 5, 0],
    transition: { duration: 2.2, repeat: Infinity },
  },
  salute: {
    rotate:     [0, -4, 4, -4, 0],
    transition: { duration: 1, repeat: 1 },
  },
}

function imgSrc(mood: KamBotMood, size: number): string {
  if (mood === 'sad')  return '/kambot/back.png'
  if (size <= 56)      return '/kambot/face.png'
  return '/kambot/front.png'
}

export default function KamBot({ mood = 'idle', size = 120, className = '' }: KamBotProps) {
  const [imgError, setImgError] = useState(false)
  const height = Math.round(size * 1.35)
  const src    = imgSrc(mood, size)

  return (
    <motion.div
      className={`inline-block select-none relative ${className}`}
      animate={moodVariants[mood]}
      style={{ width: size, height }}
    >
      {imgError ? (
        /* ── Fallback SVG camel silhouette when PNG not yet placed ── */
        <FallbackCamel size={size} mood={mood} />
      ) : (
        <img
          src={src}
          alt="KamBot"
          draggable={false}
          onError={() => setImgError(true)}
          style={{
            width:          size,
            height,
            objectFit:      'contain',
            objectPosition: 'center bottom',
            filter: mood === 'celebrate'
              ? 'brightness(1.08) saturate(1.15) drop-shadow(0 0 12px rgba(217,119,6,0.5))'
              : mood === 'sad'
              ? 'saturate(0.5) brightness(0.8)'
              : 'drop-shadow(0 4px 12px rgba(0,0,0,0.6))',
          }}
        />
      )}
    </motion.div>
  )
}

/* ── Simple camel silhouette shown until real PNGs are placed ── */
function FallbackCamel({ size, mood }: { size: number; mood: KamBotMood }) {
  const h      = Math.round(size * 1.35)
  const body   = mood === 'celebrate' ? '#D97706' : mood === 'sad' ? '#92400E' : '#EA580C'
  const eyeCol = '#0D0404'

  return (
    <svg viewBox="0 0 100 140" width={size} height={h} style={{ overflow: 'visible' }}>
      {/* ears */}
      <ellipse cx="20" cy="22" rx="11" ry="16" fill={body} />
      <ellipse cx="80" cy="22" rx="11" ry="16" fill={body} />
      {/* head */}
      <rect x="18" y="12" width="64" height="52" rx="22" fill={body} />
      {/* eyes */}
      <circle cx="35" cy="32" r="6" fill={eyeCol} />
      <circle cx="65" cy="32" r="6" fill={eyeCol} />
      <circle cx="33" cy="30" r="2" fill="white" />
      <circle cx="63" cy="30" r="2" fill="white" />
      {/* mouth */}
      <path d="M 35 50 Q 50 60 65 50" stroke="white" strokeWidth="2.5" fill="none" strokeLinecap="round" />
      {/* vest */}
      <rect x="14" y="63" width="72" height="52" rx="18" fill="#0E7490" stroke="#F59E0B" strokeWidth="2" />
      {/* kazakh pattern on vest */}
      <path d="M 28 75 Q 50 68 72 75" stroke="#F59E0B" strokeWidth="1.5" fill="none" />
      <path d="M 28 89 Q 50 82 72 89" stroke="#F59E0B" strokeWidth="1.5" fill="none" />
      {/* arms */}
      <rect x="3"  y="66" width="13" height="36" rx="6" fill={body} />
      <rect x="84" y="66" width="13" height="36" rx="6" fill={body} />
      {/* legs */}
      <rect x="22" y="114" width="18" height="22" rx="7" fill={body} />
      <rect x="60" y="114" width="18" height="22" rx="7" fill={body} />
      {/* feet */}
      <ellipse cx="31" cy="136" rx="14" ry="6" fill="#92400E" />
      <ellipse cx="69" cy="136" rx="14" ry="6" fill="#92400E" />
    </svg>
  )
}
