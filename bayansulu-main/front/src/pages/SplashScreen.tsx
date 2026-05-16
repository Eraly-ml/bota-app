import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import KamBot from '@/components/kambot/KamBot'
import Particles from '@/components/effects/Particles'
import { splashVariants } from '@/hooks/useAnimation'
import { usePlayerStore } from '@/store/playerStore'

export default function SplashScreen() {
  const navigate = useNavigate()
  const onboardingComplete = usePlayerStore(s => s.onboardingComplete)

  useEffect(() => {
    const t = setTimeout(() => {
      navigate(onboardingComplete ? '/map' : '/onboarding')
    }, 3200)
    return () => clearTimeout(t)
  }, [navigate, onboardingComplete])

  return (
    <motion.div
      className="min-h-dvh flex flex-col relative overflow-hidden"
      style={{ background: '#0D0404' }}
      variants={splashVariants}
      initial="initial"
      animate="animate"
      exit="exit"
      onClick={() => navigate(onboardingComplete ? '/map' : '/onboarding')}
    >
      {/* Radial heat haze in the upper half */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            'radial-gradient(ellipse 70% 50% at 60% 30%, rgba(153,27,27,0.22) 0%, transparent 70%),' +
            'radial-gradient(ellipse 40% 40% at 30% 70%, rgba(217,119,6,0.10) 0%, transparent 65%)',
        }}
      />

      <Particles count={18} />

      {/* Asymmetric two-zone layout */}
      <div className="flex flex-col flex-1 justify-between px-6 pt-14 pb-10 z-10">

        {/* Top: KamBot + brand text side by side */}
        <div className="flex items-center gap-5">
          <motion.div
            className="animate-float shrink-0"
            initial={{ opacity: 0, x: -30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.15, type: 'spring', stiffness: 220, damping: 20 }}
          >
            <KamBot mood="happy" size={110} />
          </motion.div>

          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3, type: 'spring', stiffness: 220, damping: 20 }}
          >
            <p
              className="text-[10px] font-black tracking-[0.35em] uppercase mb-1"
              style={{ color: 'rgba(217,119,6,0.6)' }}
            >
              Kazakhstan
            </p>
            <h1
              className="font-brand leading-none"
              style={{
                fontSize: 38,
                color: '#FEF3C7',
                letterSpacing: '-0.02em',
                lineHeight: 0.95,
              }}
            >
              BAYAN<br />
              <span style={{ color: '#EA580C' }}>SULU</span>
            </h1>
            <p
              className="text-xs font-bold mt-2 leading-relaxed"
              style={{ color: 'rgba(254,243,199,0.45)' }}
            >
              Исследуй Казахстан через<br />
              игры и приключения
            </p>
          </motion.div>
        </div>

        {/* Middle spacer */}
        <div />

        {/* Bottom: loading dots + tap hint */}
        <motion.div
          className="flex flex-col items-start gap-4"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 }}
        >
          {/* Three staggered loading bars instead of dots */}
          <div className="flex gap-1.5 items-end h-4">
            {[0, 1, 2, 3].map(i => (
              <motion.div
                key={i}
                className="rounded-full"
                style={{ width: 4, background: '#EA580C' }}
                animate={{ height: [8, 16, 8] }}
                transition={{
                  duration: 0.9,
                  delay: i * 0.15,
                  repeat: Infinity,
                  ease: 'easeInOut',
                }}
              />
            ))}
          </div>

          <p
            className="text-[10px] font-bold tracking-widest uppercase"
            style={{ color: 'rgba(254,243,199,0.28)' }}
          >
            Нажми чтобы начать
          </p>
        </motion.div>
      </div>

      {/* Bottom-right: KZ flag accent strip */}
      <div
        className="absolute bottom-0 right-0 w-24 h-1.5 rounded-tl-full"
        style={{ background: 'linear-gradient(90deg, transparent, #DC2626, #EA580C)' }}
      />
    </motion.div>
  )
}
