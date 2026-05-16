import { motion, AnimatePresence } from 'framer-motion'
import { useEffect, useRef } from 'react'
import { SpeakerHigh } from '@phosphor-icons/react'
import { useSpeech } from '@/hooks/useSpeech'

interface KamBotBubbleProps {
  message: string
  visible: boolean
  side?: 'left' | 'right'
}

export default function KamBotBubble({ message, visible, side = 'right' }: KamBotBubbleProps) {
  const { speak, stop } = useSpeech()
  const lastSpokenRef = useRef<string>('')

  // Auto-speak when bubble becomes visible
  useEffect(() => {
    if (visible) {
      if (message && message !== lastSpokenRef.current) {
        speak(message)
        lastSpokenRef.current = message
      }
    } else {
      // Clear last spoken ref and stop audio when the bubble goes invisible
      lastSpokenRef.current = ''
      stop()
    }

    // Stop audio on cleanup to prevent overlapping sounds
    return () => {
      stop()
    }
  }, [message, visible, speak, stop])

  return (
    <AnimatePresence>
      {visible && (
        <motion.div
          className={`absolute z-10 max-w-[190px] ${side === 'right' ? 'right-0' : 'left-0'}`}
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0, opacity: 0 }}
          style={{ bottom: '105%', transformOrigin: side === 'right' ? 'bottom right' : 'bottom left' }}
          transition={{ type: 'spring', stiffness: 420, damping: 22 }}
        >
          <div
            className="glass rounded-3xl px-3 py-2.5 text-cream text-xs font-bold leading-snug relative cursor-pointer select-none"
            style={{
              background: 'rgba(34, 13, 13, 0.88)',
              border:     '1px solid rgba(234,88,12,0.22)',
              boxShadow:  'inset 0 1px 0 rgba(255,255,255,0.07), 0 4px 16px rgba(0,0,0,0.5)',
            }}
            onClick={() => speak(message)}
          >
            <div className="flex items-start gap-1.5">
              <span className="flex-1 leading-relaxed" style={{ color: '#FEF3C7' }}>
                {message}
              </span>
              <SpeakerHigh
                size={12}
                weight="fill"
                color="rgba(217,119,6,0.7)"
                className="shrink-0 mt-0.5"
              />
            </div>

            {/* Bubble tail */}
            <div
              className="absolute"
              style={{
                bottom:      -7,
                [side === 'right' ? 'right' : 'left']: 16,
                width:        0,
                height:       0,
                borderLeft:   '7px solid transparent',
                borderRight:  '7px solid transparent',
                borderTop:    '8px solid rgba(34,13,13,0.88)',
              }}
            />
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
