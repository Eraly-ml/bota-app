import { useNavigate } from 'react-router-dom'
import { locations } from '@/data/locations'
import LocationPin from './LocationPin'
import { useState } from 'react'
import Modal from '@/components/ui/Modal'
import Button from '@/components/ui/Button'
import type { MapLocation } from '@/types'
import type { Language } from '@/data/locale'
import { getTranslation } from '@/data/locale'

interface KazakhstanMapProps {
  language?: Language
}

// Simplified Kazakhstan border path (SVG coords scaled to 600×400 viewBox)
const KZ_PATH = `
  M 75,148 L 68,162 L 58,175 L 50,196 L 46,220 L 48,248
  L 58,268 L 72,284 L 90,294 L 108,300 L 118,310 L 124,328
  L 138,342 L 162,350 L 188,354 L 212,356 L 238,352
  L 258,358 L 284,362 L 308,358 L 330,352 L 352,358
  L 374,368 L 398,374 L 420,368 L 445,362 L 468,356
  L 488,348 L 506,336 L 518,318 L 522,298 L 514,278
  L 504,262 L 508,244 L 520,228 L 528,208 L 524,188
  L 514,173 L 498,158 L 478,148 L 458,143 L 438,138
  L 416,128 L 396,118 L 372,113 L 348,116 L 322,113
  L 298,110 L 272,113 L 246,118 L 222,124 L 198,130
  L 172,132 L 148,136 L 122,140 Z
`

// Connecting path between all 5 locations (percentage-based → scaled ×6 x, ×4 y)
const CONNECT_PATH = locations
  .map((l, i) => `${i === 0 ? 'M' : 'L'} ${l.x * 6} ${l.y * 4}`)
  .join(' ')

export default function KazakhstanMap({ language = 'ru' }: KazakhstanMapProps) {
  const navigate = useNavigate()
  const [selected, setSelected] = useState<MapLocation | null>(null)
  const t = getTranslation(language)

  return (
    <div className="relative w-full" style={{ aspectRatio: '6/4' }}>
      <svg
        viewBox="0 0 600 400"
        className="w-full h-full"
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* Stars background */}
        {Array.from({ length: 28 }, (_, i) => (
          <circle
            key={i}
            cx={Math.sin(i * 137.5) * 280 + 300}
            cy={Math.cos(i * 97.3) * 180 + 200}
            r={0.8 + (i % 3) * 0.6}
            fill="white"
            opacity={0.2 + (i % 5) * 0.08}
          />
        ))}

        {/* Kazakhstan territory */}
        <path
          d={KZ_PATH}
          fill="url(#kzFill)"
          stroke="#EA580C"
          strokeWidth="1.5"
          strokeLinejoin="round"
        />

        {/* Territory gradient */}
        <defs>
          <radialGradient id="kzFill" cx="50%" cy="50%" r="60%">
            <stop offset="0%"   stopColor="#3D0C0C" stopOpacity="0.95" />
            <stop offset="100%" stopColor="#1A0505" stopOpacity="0.9" />
          </radialGradient>
          <filter id="pinGlow">
            <feGaussianBlur stdDeviation="2" result="blur" />
            <feMerge><feMergeNode in="blur" /><feMergeNode in="SourceGraphic" /></feMerge>
          </filter>
        </defs>

        {/* Decorative inner glow edge */}
        <path
          d={KZ_PATH}
          fill="none"
          stroke="#D97706"
          strokeWidth="0.5"
          opacity="0.3"
          strokeDasharray="3 6"
        />

        {/* Dotted connection path */}
        <path
          d={CONNECT_PATH}
          stroke="#D97706"
          strokeWidth="1.5"
          strokeDasharray="5 5"
          fill="none"
          opacity="0.4"
        />

        {/* Location pins */}
        {locations.map(loc => (
          <LocationPin
            key={loc.id}
            location={loc}
            onClick={() => setSelected(loc)}
          />
        ))}
      </svg>

      {/* Location preview modal */}
      <Modal open={!!selected} onClose={() => setSelected(null)}>
        {selected && (
          <div className="text-center">
            <div className="text-5xl mb-3">{selected.icon}</div>
            <h2
              className="font-black text-2xl mb-1"
              style={{ color: '#FEF3C7' }}
            >
              {language === 'kk' ? selected.nameKk : selected.name}
            </h2>
            {language === 'ru' && (
              <p className="text-sm font-bold mb-1" style={{ color: 'rgba(254,243,199,0.45)' }}>
                {selected.nameKk}
              </p>
            )}
            <p className="text-sm mb-5" style={{ color: 'rgba(254,243,199,0.65)' }}>
              {language === 'kk'
                ? (selected.descriptionKk ?? selected.description)
                : selected.description}
            </p>
            <Button
              variant="primary"
              fullWidth
              onClick={() => { setSelected(null); navigate(selected.game) }}
            >
              {t.mapPlayBtn}
            </Button>
            <button
              className="mt-3 text-sm font-bold w-full"
              style={{ color: 'rgba(254,243,199,0.35)' }}
              onClick={() => setSelected(null)}
            >
              {t.mapLater}
            </button>
          </div>
        )}
      </Modal>
    </div>
  )
}
