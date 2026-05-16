import { motion } from 'framer-motion'
import type { ReactNode } from 'react'

interface CardProps {
  children: ReactNode
  className?: string
  onClick?: () => void
  glow?: string   // color hex e.g. '#F5A623'
  padding?: string
}

export default function Card({ children, className = '', onClick, glow, padding = 'p-4' }: CardProps) {
  return (
    <motion.div
      className={`glass rounded-4xl ${padding} shadow-card ${className} ${onClick ? 'cursor-pointer' : ''}`}
      style={glow ? { boxShadow: `0 0 20px 4px ${glow}40, 0 8px 32px rgba(0,0,0,0.4)` } : {}}
      onClick={onClick}
      whileHover={onClick ? { scale: 1.03, y: -2 } : {}}
      whileTap={onClick ? { scale: 0.97 } : {}}
      transition={{ type: 'spring', stiffness: 400, damping: 25 }}
    >
      {children}
    </motion.div>
  )
}
