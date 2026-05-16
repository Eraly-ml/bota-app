import { motion } from 'framer-motion'
import { useRef, useEffect } from 'react'

interface CoinDisplayProps {
  amount: number
  size?: 'sm' | 'md' | 'lg'
  className?: string
}

export default function CoinDisplay({ amount, size = 'md', className = '' }: CoinDisplayProps) {
  const prevRef = useRef(amount)
  const isIncreasing = amount > prevRef.current

  useEffect(() => {
    prevRef.current = amount
  }, [amount])

  const textSize = size === 'sm' ? 'text-sm' : size === 'lg' ? 'text-2xl' : 'text-base'
  const iconSize = size === 'sm' ? 'text-sm' : size === 'lg' ? 'text-2xl' : 'text-lg'

  return (
    <motion.div
      className={`flex items-center gap-1 ${className}`}
      animate={isIncreasing ? { scale: [1, 1.2, 1] } : {}}
      transition={{ duration: 0.3 }}
    >
      <span className={iconSize}>🪙</span>
      <motion.span
        key={amount}
        className={`${textSize} font-black text-kazakh-gold`}
        initial={{ scale: 1.3, color: '#FFD700' }}
        animate={{ scale: 1, color: '#F5A623' }}
        transition={{ duration: 0.3 }}
      >
        {amount.toLocaleString()}
      </motion.span>
    </motion.div>
  )
}

// Floating "+N coins" animation
export function FloatingCoinGain({ amount, onDone }: { amount: number; onDone?: () => void }) {
  return (
    <motion.div
      className="pointer-events-none absolute font-black text-kazakh-gold text-xl"
      style={{ left: '50%', bottom: '60%', transform: 'translateX(-50%)' }}
      initial={{ opacity: 1, y: 0, scale: 1 }}
      animate={{ opacity: 0, y: -70, scale: 1.3 }}
      transition={{ duration: 0.9, ease: 'easeOut' }}
      onAnimationComplete={onDone}
    >
      +{amount} 🪙
    </motion.div>
  )
}
