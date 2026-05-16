import { motion } from 'framer-motion'
import HUDBar from '@/components/layout/HUDBar'
import BottomNav from '@/components/layout/BottomNav'
import KazakhstanMap from '@/components/map/KazakhstanMap'
import CloudLayer from '@/components/map/CloudLayer'
import KamBot from '@/components/kambot/KamBot'
import KamBotBubble from '@/components/kambot/KamBotBubble'
import Particles from '@/components/effects/Particles'
import { usePlayerStore } from '@/store/playerStore'
import { pageVariants } from '@/hooks/useAnimation'
import { kamBotTips } from '@/data/mockData'
import { getTranslation } from '@/data/locale'
import { useEffect, useState } from 'react'
import { MapPin } from '@phosphor-icons/react'

export default function WorldMap() {
  const name     = usePlayerStore(s => s.name)
  const language = usePlayerStore(s => s.language)
  const t        = getTranslation(language)
  const tips     = kamBotTips.map[language]

  const [tipIdx, setTipIdx] = useState(0)

  // Rotate tips every 6 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      setTipIdx(i => (i + 1) % tips.length)
    }, 6000)
    return () => clearInterval(interval)
  }, [tips.length])

  return (
    <motion.div
      className="min-h-dvh flex flex-col relative overflow-hidden"
      style={{ background: '#0D0404' }}
      variants={pageVariants}
      initial="initial"
      animate="animate"
      exit="exit"
    >
      <HUDBar />

      {/* Ambient background */}
      <div className="absolute inset-0 pointer-events-none z-0">
        <div
          className="absolute top-0 left-0 right-0 h-1/2"
          style={{ background: 'radial-gradient(ellipse at 60% 0%, rgba(153,27,27,0.18) 0%, transparent 70%)' }}
        />
        <div
          className="absolute bottom-0 left-0 right-0 h-1/3"
          style={{ background: 'radial-gradient(ellipse at 40% 100%, rgba(217,119,6,0.08) 0%, transparent 65%)' }}
        />
        <Particles count={14} />
      </div>

      {/* Title */}
      <motion.div
        className="relative z-10 pt-3 pb-1 px-5"
        initial={{ opacity: 0, y: -15 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
      >
        <div className="flex items-center gap-2">
          <MapPin size={18} weight="fill" color="#EA580C" />
          <h1
            className="font-brand leading-none tracking-tight"
            style={{ fontSize: 20, color: '#FEF3C7' }}
          >
            {t.mapTitle}
          </h1>
        </div>
        <p className="text-xs font-bold mt-0.5 pl-6" style={{ color: 'rgba(254,243,199,0.4)' }}>
          {t.mapSubtitle}
        </p>
      </motion.div>

      {/* Map */}
      <motion.div
        className="relative z-10 flex-1 px-2"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
      >
        <CloudLayer />
        <KazakhstanMap language={language} />
      </motion.div>

      {/* KamBot + bubble */}
      <motion.div
        className="fixed bottom-20 right-3 z-30"
        initial={{ opacity: 0, x: 60 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ delay: 0.6, type: 'spring', stiffness: 300 }}
      >
        <div className="relative">
          <KamBotBubble
            message={tips[tipIdx]}
            visible={true}
            side="right"
          />
          <KamBot mood="idle" size={88} />
        </div>
      </motion.div>

      {/* Welcome banner */}
      <motion.div
        className="relative z-10 mx-3 mb-2"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
      >
        <div
          className="rounded-3xl px-4 py-2.5 flex items-center gap-3"
          style={{
            background: 'rgba(107,26,26,0.35)',
            border:     '1px solid rgba(234,88,12,0.2)',
            boxShadow:  'inset 0 1px 0 rgba(255,255,255,0.06)',
          }}
        >
          <div
            className="w-8 h-8 rounded-full shrink-0 flex items-center justify-center"
            style={{ background: 'rgba(234,88,12,0.2)', border: '1px solid rgba(234,88,12,0.35)' }}
          >
            <span style={{ fontSize: 16 }}>🌟</span>
          </div>
          <div>
            <p className="font-black text-sm" style={{ color: '#FEF3C7' }}>
              {name ? (
                <>{t.mapWelcome} <span style={{ color: '#D97706' }}>{name}</span>!</>
              ) : (
                t.mapWelcomeFallback
              )}
            </p>
            <p className="text-xs font-medium mt-0.5" style={{ color: 'rgba(254,243,199,0.45)' }}>
              {t.mapExplore}
            </p>
          </div>
        </div>
      </motion.div>

      <BottomNav />
    </motion.div>
  )
}
