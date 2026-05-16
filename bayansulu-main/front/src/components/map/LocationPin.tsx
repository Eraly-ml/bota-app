import { motion } from 'framer-motion'
import { useState } from 'react'
import type { MapLocation } from '@/types'

interface LocationPinProps {
  location: MapLocation
  onClick: () => void
}

export default function LocationPin({ location, onClick }: LocationPinProps) {
  const [hovered, setHovered] = useState(false)

  return (
    <g
      style={{ cursor: 'pointer' }}
      onClick={onClick}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
      {/* Pulse ring */}
      <circle
        cx={location.x * 6}
        cy={location.y * 4}
        r="18"
        fill="none"
        stroke={location.color}
        strokeWidth="2"
        opacity="0.5"
      >
        <animate attributeName="r" values="14;22;14" dur="2s" repeatCount="indefinite" />
        <animate attributeName="opacity" values="0.6;0;0.6" dur="2s" repeatCount="indefinite" />
      </circle>

      {/* Main circle */}
      <circle
        cx={location.x * 6}
        cy={location.y * 4}
        r="14"
        fill={location.color}
        opacity={hovered ? 1 : 0.92}
        style={{ filter: `drop-shadow(0 0 8px ${location.color})` }}
      />

      {/* Inner white circle */}
      <circle
        cx={location.x * 6}
        cy={location.y * 4}
        r="10"
        fill="rgba(255,255,255,0.18)"
      />

      {/* Icon text */}
      <text
        x={location.x * 6}
        y={location.y * 4 + 5}
        textAnchor="middle"
        fontSize="12"
        dominantBaseline="middle"
        style={{ userSelect: 'none' }}
      >
        {location.icon}
      </text>

      {/* Label */}
      <text
        x={location.x * 6}
        y={location.y * 4 + 24}
        textAnchor="middle"
        fontSize="9"
        fill="white"
        fontFamily="Nunito, sans-serif"
        fontWeight="800"
        style={{ userSelect: 'none', textShadow: '0 1px 4px rgba(0,0,0,0.8)' }}
      >
        {location.name}
      </text>

      {/* Hover tooltip */}
      {hovered && (
        <>
          <rect
            x={location.x * 6 - 50}
            y={location.y * 4 - 44}
            width="100"
            height="22"
            rx="8"
            fill="rgba(26,10,46,0.92)"
            stroke={location.color}
            strokeWidth="1"
          />
          <text
            x={location.x * 6}
            y={location.y * 4 - 30}
            textAnchor="middle"
            fontSize="8"
            fill="white"
            fontFamily="Nunito, sans-serif"
            fontWeight="700"
          >
            Tap to play! 🎮
          </text>
        </>
      )}
    </g>
  )
}
