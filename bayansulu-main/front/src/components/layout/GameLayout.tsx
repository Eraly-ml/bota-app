import type { ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import HUDBar from './HUDBar'
import KamBot from '@/components/kambot/KamBot'
import KamBotBubble from '@/components/kambot/KamBotBubble'
import type { KamBotMood } from '@/types'
import { pageVariants } from '@/hooks/useAnimation'

interface GameLayoutProps {
  children: ReactNode
  title?: string
  showHUD?: boolean
  showBack?: boolean
  kambot?: {
    mood?: KamBotMood
    tip?: string
    show?: boolean
  }
  bgClassName?: string
}

export default function GameLayout({
  children,
  title,
  showHUD = true,
  showBack = true,
  kambot = { mood: 'idle', show: true },
  bgClassName = 'bg-gradient-kazakh',
}: GameLayoutProps) {
  const navigate = useNavigate()

  return (
    <motion.div
      className={`min-h-dvh flex flex-col ${bgClassName} relative overflow-hidden`}
      variants={pageVariants}
      initial="initial"
      animate="animate"
      exit="exit"
    >
      {showHUD && <HUDBar />}

      {(showBack || title) && (
        <div className="flex items-center gap-3 px-4 pt-3 pb-1">
          {showBack && (
            <button
              className="w-10 h-10 rounded-full glass flex items-center justify-center text-white text-lg font-bold"
              onClick={() => navigate(-1)}
            >
              ←
            </button>
          )}
          {title && (
            <h1 className="text-white font-black text-xl">{title}</h1>
          )}
        </div>
      )}

      <div className="flex-1 relative">
        {children}
      </div>

      {/* KamBot floating corner */}
      {kambot.show !== false && (
        <div className="fixed bottom-20 right-3 z-30">
          <div className="relative">
            {kambot.tip && (
              <KamBotBubble message={kambot.tip} visible={true} side="right" />
            )}
            <KamBot mood={kambot.mood ?? 'idle'} size={72} />
          </div>
        </div>
      )}
    </motion.div>
  )
}
