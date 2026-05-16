import { NavLink } from 'react-router-dom'
import { motion } from 'framer-motion'
import { MapTrifold, GameController, Trophy, UserCircle } from '@phosphor-icons/react'

const TABS = [
  { to: '/map',     Icon: MapTrifold,     label: 'Карта' },
  { to: '/games',   Icon: GameController, label: 'Игры' },
  { to: '/rewards', Icon: Trophy,         label: 'Награды' },
  { to: '/parent',  Icon: UserCircle,     label: 'Родитель' },
]

export default function BottomNav() {
  return (
    <nav
      className="glass-dark sticky bottom-0 z-40 flex items-stretch"
      style={{
        borderTop: '1px solid rgba(234,88,12,0.12)',
        paddingBottom: 'env(safe-area-inset-bottom, 0px)',
      }}
    >
      {TABS.map(({ to, Icon, label }) => (
        <NavLink key={to} to={to} className="flex-1">
          {({ isActive }) => (
            <motion.div
              className="flex flex-col items-center justify-center py-2.5 gap-0.5 relative"
              whileTap={{ scale: 0.85 }}
            >
              {/* Active indicator bar */}
              {isActive && (
                <motion.div
                  className="absolute top-0 left-1/2 -translate-x-1/2 h-0.5 rounded-full"
                  style={{ width: '28px', background: '#EA580C' }}
                  layoutId="nav-indicator"
                  transition={{ type: 'spring', stiffness: 500, damping: 32 }}
                />
              )}

              <motion.div
                animate={{ scale: isActive ? 1.2 : 1 }}
                transition={{ type: 'spring', stiffness: 400, damping: 22 }}
              >
                <Icon
                  size={22}
                  weight={isActive ? 'fill' : 'regular'}
                  color={isActive ? '#EA580C' : 'rgba(255,255,255,0.38)'}
                />
              </motion.div>

              <span
                className="text-[9px] font-black tracking-wide"
                style={{ color: isActive ? '#D97706' : 'rgba(255,255,255,0.35)' }}
              >
                {label}
              </span>
            </motion.div>
          )}
        </NavLink>
      ))}
    </nav>
  )
}
