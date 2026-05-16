import { useEffect } from 'react'
import { BrowserRouter, Routes, Route, Navigate, useLocation } from 'react-router-dom'
import { AnimatePresence } from 'framer-motion'
import { usePlayerStore } from '@/store/playerStore'
import { useGameStore } from '@/store/gameStore'

// Pages
import SplashScreen  from '@/pages/SplashScreen'
import Onboarding    from '@/pages/Onboarding'
import WorldMap      from '@/pages/WorldMap'
import RewardHub     from '@/pages/RewardHub'
import ParentMode    from '@/pages/ParentMode'
import GamesLobby    from '@/pages/GamesLobby'
import MemoryRush    from '@/pages/games/MemoryRush'
import CamelRunner   from '@/pages/games/CamelRunner'
import YurtBuilder   from '@/pages/games/YurtBuilder'
import QuizAdventure from '@/pages/games/QuizAdventure'
import MathBattle    from '@/pages/games/MathBattle'
import KazakhWordMatch from '@/pages/games/KazakhWordMatch'
import ScreenTimeEnforcer from '@/components/layout/ScreenTimeEnforcer'

function AnimatedRoutes() {
  const location = useLocation()
  const onboardingComplete = usePlayerStore(s => s.onboardingComplete)

  return (
    <AnimatePresence mode="wait">
      <Routes location={location} key={location.pathname}>
        <Route path="/splash"       element={<SplashScreen />} />
        <Route path="/onboarding"   element={<Onboarding />} />
        <Route path="/map"          element={onboardingComplete ? <WorldMap /> : <Navigate to="/onboarding" />} />
        <Route path="/rewards"      element={<RewardHub />} />
        <Route path="/parent"       element={<ParentMode />} />
        <Route path="/games"        element={<GamesLobby />} />
        <Route path="/games/memory" element={<MemoryRush />} />
        <Route path="/games/runner" element={<CamelRunner />} />
        <Route path="/games/yurt"   element={<YurtBuilder />} />
        <Route path="/games/quiz"   element={<QuizAdventure />} />
        <Route path="/games/math"   element={<MathBattle />} />
        <Route path="/games/words"  element={<KazakhWordMatch />} />
        <Route path="*"             element={<Navigate to="/splash" replace />} />
      </Routes>
    </AnimatePresence>
  )
}

export default function App() {
  const checkReset = useGameStore(s => s.checkAndResetDailyReward)

  useEffect(() => {
    checkReset()
  }, [checkReset])

  return (
    <BrowserRouter>
      <ScreenTimeEnforcer />
      <AnimatedRoutes />
    </BrowserRouter>
  )
}
