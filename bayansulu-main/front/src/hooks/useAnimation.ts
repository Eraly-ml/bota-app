import type { Variants } from 'framer-motion'

// ─── Page transition variants ────────────────────────────────────────────────
export const pageVariants: Variants = {
  initial: { opacity: 0, y: 24 },
  animate: {
    opacity: 1, y: 0,
    transition: { duration: 0.35, ease: [0.25, 0.46, 0.45, 0.94] },
  },
  exit: {
    opacity: 0, y: -24,
    transition: { duration: 0.25 },
  },
}

export const splashVariants: Variants = {
  initial: { opacity: 0, scale: 1.08 },
  animate: { opacity: 1, scale: 1, transition: { duration: 0.5 } },
  exit:    { opacity: 0, scale: 0.94, transition: { duration: 0.3 } },
}

export const slideInFromRight: Variants = {
  initial: { opacity: 0, x: 60 },
  animate: { opacity: 1, x: 0, transition: { duration: 0.35, ease: 'easeOut' } },
  exit:    { opacity: 0, x: -60, transition: { duration: 0.25 } },
}

// ─── Stagger children ────────────────────────────────────────────────────────
export const staggerContainer: Variants = {
  animate: {
    transition: { staggerChildren: 0.07, delayChildren: 0.1 },
  },
}

export const staggerItem: Variants = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0, transition: { duration: 0.3 } },
}

// ─── Pop / bounce ────────────────────────────────────────────────────────────
export const popIn: Variants = {
  initial: { scale: 0, opacity: 0 },
  animate: {
    scale: 1, opacity: 1,
    transition: { type: 'spring', stiffness: 400, damping: 20 },
  },
}

export const rewardPop: Variants = {
  initial: { scale: 0, rotate: -10, opacity: 0 },
  animate: {
    scale: 1, rotate: 0, opacity: 1,
    transition: { type: 'spring', stiffness: 500, damping: 18 },
  },
  exit: { scale: 0, opacity: 0, transition: { duration: 0.2 } },
}

// ─── KamBot mood variants ────────────────────────────────────────────────────
export const kamBotMoodVariants = {
  idle: {
    y: [0, -8, 0],
    transition: { duration: 2.5, repeat: Infinity, ease: 'easeInOut' as const },
  },
  happy: {
    rotate: [-4, 4, -4],
    y: [0, -5, 0],
    transition: { duration: 0.6, repeat: Infinity },
  },
  celebrate: {
    scale: [1, 1.18, 1, 1.18, 1],
    rotate: [-6, 6, -6, 6, 0],
    transition: { duration: 0.8, repeat: 2 },
  },
  sad: {
    y: [0, 5, 0],
    rotate: [-2, 2, -2],
    transition: { duration: 1.8, repeat: Infinity },
  },
  thinking: {
    rotate: [0, 6, 0],
    transition: { duration: 2, repeat: Infinity },
  },
  salute: {
    rotate: [0, -3, 3, -3, 0],
    transition: { duration: 1, repeat: 1 },
  },
}
