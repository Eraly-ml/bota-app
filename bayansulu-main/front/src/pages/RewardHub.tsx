import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import HUDBar from '@/components/layout/HUDBar'
import BottomNav from '@/components/layout/BottomNav'
import KamBot from '@/components/kambot/KamBot'
import BadgeCard from '@/components/ui/Badge'
import ProgressBar from '@/components/ui/ProgressBar'
import Button from '@/components/ui/Button'
import Confetti from '@/components/effects/Confetti'
import Modal from '@/components/ui/Modal'
import { usePlayerStore } from '@/store/playerStore'
import { useGameStore } from '@/store/gameStore'
import { getRandomDailyReward, prizeStoreProducts } from '@/data/mockData'
import { getTranslation } from '@/data/locale'
import { pageVariants } from '@/hooks/useAnimation'
import type { Coupon } from '@/types'

export default function RewardHub() {
  const {
    botacoins,
    xp,
    xpToNext,
    level,
    streak,
    badges,
    addCoins,
    addXP,
    language,
    purchasedCoupons,
    buyPrize,
    incrementStreak
  } = usePlayerStore()
  const { dailyRewardClaimed, claimDailyReward } = useGameStore()

  const t = getTranslation(language)

  const [activeTab, setActiveTab] = useState<'rewards' | 'shop' | 'coupons'>('rewards')
  const [chestOpen, setChestOpen] = useState(false)
  const [reward, setReward]       = useState<{ label: string; icon: string } | null>(null)
  const [confetti, setConfetti]   = useState(false)

  // Shop purchase modal state
  const [buySuccessOpen, setBuySuccessOpen] = useState(false)
  const [latestCoupon, setLatestCoupon]     = useState<Coupon | null>(null)

  const openChest = () => {
    if (dailyRewardClaimed) return
    const r = getRandomDailyReward()
    claimDailyReward()
    incrementStreak()
    if (r.type === 'coins' && r.amount) addCoins(r.amount)
    if (r.type === 'xp' && r.amount) addXP(r.amount)
    setReward({ label: r.label, icon: r.icon })
    setChestOpen(true)
    setConfetti(true)
    setTimeout(() => setConfetti(false), 3000)
  }

  const handleBuyPrize = (prizeId: string, cost: number) => {
    const success = buyPrize(prizeId, cost)
    if (success) {
      // Find the coupon we just bought (the last one added to list)
      const storeState = usePlayerStore.getState()
      const coupons = storeState.purchasedCoupons
      const last = coupons[coupons.length - 1]
      setLatestCoupon(last || null)
      setConfetti(true)
      setBuySuccessOpen(true)
      setTimeout(() => setConfetti(false), 3000)
    }
  }

  const streakDays = Array.from({ length: 7 }, (_, i) => i < streak)

  return (
    <motion.div
      className="min-h-dvh flex flex-col bg-deep-navy"
      variants={pageVariants} initial="initial" animate="animate" exit="exit"
    >
      <HUDBar />
      <Confetti active={confetti} />

      <div className="flex-1 overflow-y-auto px-3 py-3 space-y-4">

        {/* Header */}
        <div className="text-center">
          <h1 className="text-white font-black text-2xl">
            🏆 <span className="text-gradient-gold">{t.rewardsTitle}</span>
          </h1>
          <p className="text-white/40 text-xs font-bold">{t.rewardsDesc}</p>
        </div>

        {/* Segmented control tabs */}
        <div className="flex p-1 bg-black/20 rounded-3xl border border-white/5 gap-1">
          {[
            { id: 'rewards', label: language === 'ru' ? '🏅 Достижения' : '🏅 Жетістіктер' },
            { id: 'shop',    label: language === 'ru' ? '🛍️ Магазин' : '🛍️ Дүкен' },
            { id: 'coupons', label: language === 'ru' ? '🎟️ Купоны' : '🎟️ Купондар' },
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`flex-1 text-center py-2 text-xs font-black rounded-2xl transition-all duration-200 cursor-pointer ${
                activeTab === tab.id
                  ? 'bg-kazakh-gold text-deep-navy shadow-md'
                  : 'text-white/50 hover:text-white/80 hover:bg-white/5'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* TAB 1: Rewards, Chests, Achievements */}
        <AnimatePresence mode="wait">
          {activeTab === 'rewards' && (
            <motion.div
              key="rewards"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="space-y-4"
            >
              {/* Stats row */}
              <div className="grid grid-cols-3 gap-2">
                {[
                  { label: t.coins, val: botacoins, icon: '🪙', color: '#F5A623' },
                  { label: t.level,     val: level,     icon: '⭐', color: '#00B4D8' },
                  { label: t.parentStreakDays.replace('{days} ', ''), val: streak, icon: '🔥', color: '#FF6B35' },
                ].map(s => (
                  <div key={s.label} className="glass rounded-4xl p-3 text-center">
                    <div className="text-2xl mb-1">{s.icon}</div>
                    <p className="font-black text-xl" style={{ color: s.color }}>{s.val}</p>
                    <p className="text-white/40 text-[9px] font-black">{s.label}</p>
                  </div>
                ))}
              </div>

              {/* XP Bar */}
              <div className="glass rounded-4xl p-4">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-white font-black text-sm">⭐ {t.level} {level}</span>
                  <span className="text-white/50 text-xs font-bold">{xp} / {xpToNext} XP</span>
                </div>
                <ProgressBar value={xp} max={xpToNext} color="#00B4D8" height={12} glow />
                <p className="text-white/30 text-xs font-bold mt-2 text-center">
                  {t.rewardsXPUntil.replace('{xp}', String(xpToNext - xp)).replace('{next}', String(level + 1))}
                </p>
              </div>

              {/* Daily Chest */}
              <div className="glass rounded-4xl p-4 text-center">
                <h3 className="text-white font-black mb-1">🎁 {t.rewardsDaily}</h3>
                <p className="text-white/40 text-xs font-bold mb-3">
                  {dailyRewardClaimed ? t.rewardsDailyClaimed : t.rewardsDailyUnclaimed}
                </p>
                <motion.div
                  className="text-7xl mx-auto mb-3 cursor-pointer inline-block"
                  animate={dailyRewardClaimed ? {} : { y: [0, -6, 0] }}
                  transition={{ duration: 2, repeat: Infinity }}
                  whileHover={!dailyRewardClaimed ? { scale: 1.12 } : {}}
                  whileTap={!dailyRewardClaimed ? { scale: 0.9 } : {}}
                  onClick={openChest}
                >
                  {dailyRewardClaimed ? '🔒' : '🎁'}
                </motion.div>
                {!dailyRewardClaimed && (
                  <Button variant="primary" onClick={openChest}>{t.rewardsOpenBtn}</Button>
                )}
              </div>

              {/* 7-day streak */}
              <div className="glass rounded-4xl p-4">
                <h3 className="text-white font-black mb-3">🔥 {t.rewardsWeekly}</h3>
                <div className="flex gap-2 justify-between">
                  {['M','T','W','T','F','S','S'].map((d, i) => (
                    <div key={i} className="flex flex-col items-center gap-1">
                      <div
                        className="w-9 h-9 rounded-full flex items-center justify-center font-black text-sm"
                        style={{
                          background: streakDays[i]
                            ? 'linear-gradient(135deg, #F5A623, #FF6B35)'
                            : 'rgba(255,255,255,0.08)',
                          boxShadow: streakDays[i] ? '0 0 12px rgba(245,166,35,0.5)' : 'none',
                        }}
                      >
                        {streakDays[i] ? '✅' : <span className="text-white/30">{d}</span>}
                      </div>
                      <span className="text-[9px] font-bold text-white/30">{d}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Badges */}
              <div className="glass rounded-4xl p-4">
                <h3 className="text-white font-black mb-3">🏅 {t.rewardsBadges}</h3>
                <div className="grid grid-cols-4 gap-3">
                  {badges.map(b => (
                    <BadgeCard key={b.id} badge={b} size="sm" />
                  ))}
                </div>
              </div>
            </motion.div>
          )}

          {/* TAB 2: Prize Store (Магазин Купонов) */}
          {activeTab === 'shop' && (
            <motion.div
              key="shop"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="space-y-4"
            >
              <div className="glass rounded-4xl p-4 text-center">
                <h3 className="text-white font-black text-sm mb-1">{t.shopTitle}</h3>
                <p className="text-white/40 text-xs font-bold">{t.shopDesc}</p>
              </div>

              {/* Candy Cards */}
              <div className="space-y-3">
                {prizeStoreProducts.map(p => {
                  const hasEnough = botacoins >= p.cost
                  const nameStr = language === 'ru' ? p.nameRu : p.nameKk
                  const descStr = language === 'ru' ? p.descriptionRu : p.descriptionKk

                  return (
                    <div key={p.id} className="glass rounded-4xl p-4 flex gap-3 items-center relative overflow-hidden">
                      {/* Highlight glow */}
                      <div className="absolute top-0 right-0 w-16 h-16 bg-kazakh-gold/5 rounded-full blur-xl pointer-events-none" />

                      {/* Icon */}
                      <div className="w-14 h-14 rounded-3xl bg-white/5 flex items-center justify-center text-3xl shrink-0">
                        {p.emoji}
                      </div>

                      {/* Description */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between gap-1 mb-1">
                          <h4 className="text-white font-black text-sm truncate">{nameStr}</h4>
                          <span className="text-kazakh-gold text-xs font-black shrink-0 bg-kazakh-gold/10 px-2 py-0.5 rounded-full">
                            {p.cost} 🪙
                          </span>
                        </div>
                        <p className="text-white/50 text-[10px] font-medium leading-relaxed mb-2">
                          {descStr}
                        </p>
                        
                        <Button
                          variant={hasEnough ? 'primary' : 'ghost'}
                          size="sm"
                          fullWidth
                          disabled={!hasEnough}
                          onClick={() => handleBuyPrize(p.id, p.cost)}
                          className="h-8 py-0 rounded-2xl text-[11px] font-black"
                        >
                          {hasEnough ? t.shopBtnBuy.replace('{cost}', String(p.cost)) : t.shopBtnNoCoins}
                        </Button>
                      </div>
                    </div>
                  )
                })}
              </div>
            </motion.div>
          )}

          {/* TAB 3: Active Coupons (Мои Купоны) */}
          {activeTab === 'coupons' && (
            <motion.div
              key="coupons"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="space-y-4"
            >
              <div className="glass rounded-4xl p-4 text-center">
                <h3 className="text-white font-black text-sm mb-1">{t.shopActiveCoupons}</h3>
                <p className="text-white/40 text-xs font-bold">
                  {language === 'ru' ? 'Купоны на кассе магазина' : 'Дүкен кассасындағы купондар'}
                </p>
              </div>

              {purchasedCoupons.length === 0 ? (
                <div className="text-center py-8 px-4 space-y-4">
                  <div className="text-6xl">🎟️</div>
                  <p className="text-white/40 text-xs font-bold leading-relaxed max-w-[280px] mx-auto">
                    {t.shopNoCoupons}
                  </p>
                  <KamBot mood="thinking" size={80} className="mx-auto animate-float" />
                </div>
              ) : (
                <div className="space-y-3">
                  {purchasedCoupons.map(c => {
                    const product = prizeStoreProducts.find(p => p.id === c.prizeId)
                    if (!product) return null
                    const nameStr = language === 'ru' ? product.nameRu : product.nameKk

                    return (
                      <div
                        key={c.id}
                        className="glass rounded-4xl p-4 border border-kazakh-gold/20 relative overflow-hidden cursor-pointer hover:border-kazakh-gold/40 transition-all duration-200"
                        onClick={() => {
                          setLatestCoupon(c)
                          setBuySuccessOpen(true)
                        }}
                      >
                        {/* Decorative ticket cutouts */}
                        <div className="absolute -left-3 top-1/2 -translate-y-1/2 w-6 h-6 rounded-full bg-deep-navy border-r border-white/5" />
                        <div className="absolute -right-3 top-1/2 -translate-y-1/2 w-6 h-6 rounded-full bg-deep-navy border-l border-white/5" />

                        <div className="flex gap-3 items-center px-2">
                          <div className="text-3xl shrink-0">{product.emoji}</div>
                          <div className="flex-1 min-w-0">
                            <h4 className="text-white font-black text-xs truncate">{nameStr}</h4>
                            <p className="text-kazakh-gold text-[10px] font-black font-mono tracking-wider mt-1">
                              {c.code}
                            </p>
                            <p className="text-white/30 text-[8px] font-bold mt-0.5">
                              {new Date(c.purchasedAt).toLocaleDateString()}
                            </p>
                          </div>
                          <div className="text-right shrink-0">
                            <span className="text-[10px] font-black text-emerald-green bg-emerald-green/10 px-2 py-0.5 rounded-full">
                              ACTIVE
                            </span>
                          </div>
                        </div>
                      </div>
                    )
                  })}
                </div>
              )}
            </motion.div>
          )}
        </AnimatePresence>

        {/* KamBot footer dialogue */}
        <div className="flex flex-col items-center py-2 shrink-0">
          <KamBot mood={activeTab === 'shop' ? 'happy' : 'idle'} size={80} className="animate-float" />
          <p className="text-white/30 text-xs font-bold mt-1 text-center max-w-[260px]">
            {t.rewardsKeepPlaying}
          </p>
        </div>
      </div>

      <BottomNav />

      {/* Reward Chest revealed modal */}
      <Modal open={chestOpen} onClose={() => setChestOpen(false)}>
        <div className="text-center">
          <motion.div
            className="text-7xl mb-3 block"
            animate={{ rotate: [0, -10, 10, -10, 0], scale: [1, 1.3, 1] }}
            transition={{ duration: 0.8 }}
          >
            {reward?.icon}
          </motion.div>
          <h2 className="text-kazakh-gold font-black text-2xl mb-2">
            {reward?.label}
          </h2>
          <p className="text-white/60 font-bold mb-4">{t.rewardsAdded}</p>
          <Button variant="primary" fullWidth onClick={() => setChestOpen(false)}>
            {t.rewardsAwesome}
          </Button>
        </div>
      </Modal>

      {/* Prize Shop Purchase / Barcode Modal */}
      <Modal open={buySuccessOpen} onClose={() => setBuySuccessOpen(false)} className="max-w-[340px]">
        <div className="text-center space-y-4">
          <div className="text-5xl mt-1">🎁</div>
          <div>
            <h2 className="text-kazakh-gold font-black text-lg">
              {t.shopCongrats}
            </h2>
            <p className="text-white/50 text-xs font-bold mt-1">
              {t.shopBoughtDesc}
            </p>
          </div>

          {/* Barcode representation in CSS */}
          <div className="bg-white rounded-3xl p-4 flex flex-col items-center shadow-inner">
            {/* Horizontal barcode stripes */}
            <div className="flex items-center gap-[1px] h-14 w-full justify-center px-4 overflow-hidden">
              {[
                1.5, 3, 1, 1, 4, 1.5, 1, 3, 1.5, 1, 1, 4, 1.5, 2, 1, 3, 1, 4, 1.5, 3, 1, 1.5, 3, 1, 1, 4, 1.5
              ].map((w, i) => (
                <div
                  key={i}
                  className="bg-black h-full shrink-0"
                  style={{ width: `${w}px` }}
                />
              ))}
            </div>
            
            {/* Alphanumeric coupon key */}
            <span className="text-black font-black font-mono tracking-[4px] text-xs mt-3 select-all">
              {latestCoupon?.code}
            </span>
          </div>

          <p className="text-white/40 text-[9px] font-medium leading-relaxed max-w-[240px] mx-auto">
            {t.shopBarcodeHint}
          </p>

          <Button variant="primary" fullWidth onClick={() => setBuySuccessOpen(false)}>
            {t.rewardsAwesome}
          </Button>
        </div>
      </Modal>
    </motion.div>
  )
}
