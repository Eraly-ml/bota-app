import { motion } from 'framer-motion'
import type { ReactNode } from 'react'

interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  onClick?: () => void
  disabled?: boolean
  children: ReactNode
  className?: string
  fullWidth?: boolean
}

export default function Button({
  variant = 'primary',
  size = 'md',
  onClick,
  disabled = false,
  children,
  className = '',
  fullWidth = false,
}: ButtonProps) {
  const base = `
    inline-flex items-center justify-center gap-2
    font-black rounded-3xl select-none cursor-pointer
    transition-all duration-150
    ${fullWidth ? 'w-full' : ''}
    ${disabled ? 'opacity-40 cursor-not-allowed' : ''}
  `

  const sizes = {
    sm: 'px-4 py-2 text-sm min-h-[40px]',
    md: 'px-6 py-3 text-base min-h-[52px]',
    lg: 'px-8 py-4 text-lg min-h-[60px]',
  }

  const variants = {
    primary: `
      text-noir font-black
      shadow-[0_4px_20px_rgba(217,119,6,0.4),inset_0_1px_0_rgba(255,255,255,0.25)]
    `,
    secondary: `
      text-[#0EA5E9] border-2 border-[#0EA5E9]/40
      hover:border-[#0EA5E9]/70
    `,
    ghost: `glass text-white border border-white/15 hover:border-white/30`,
    danger: `
      text-white
      shadow-[0_4px_16px_rgba(220,38,38,0.4),inset_0_1px_0_rgba(255,255,255,0.15)]
    `,
  }

  const variantStyles: Record<string, React.CSSProperties> = {
    primary:   { background: 'linear-gradient(160deg, #F59E0B 0%, #D97706 100%)' },
    secondary: { background: 'rgba(14,165,233,0.08)' },
    ghost:     {},
    danger:    { background: 'linear-gradient(160deg, #EF4444 0%, #B91C1C 100%)' },
  }

  return (
    <motion.button
      className={`${base} ${sizes[size]} ${variants[variant]} ${className}`}
      style={variantStyles[variant]}
      onClick={disabled ? undefined : onClick}
      whileHover={disabled ? {} : { scale: 1.03 }}
      whileTap={disabled ? {} : { scale: 0.96, y: 1 }}
      transition={{ type: 'spring', stiffness: 420, damping: 22 }}
    >
      {children}
    </motion.button>
  )
}
