import { useState, useRef } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import GameLayout from '@/components/layout/GameLayout'
import KamBot from '@/components/kambot/KamBot'
import Button from '@/components/ui/Button'
import Modal from '@/components/ui/Modal'
import Confetti from '@/components/effects/Confetti'
import { yurtPieces, yurtDecorations } from '@/data/mockData'
import { usePlayerStore } from '@/store/playerStore'
import { getTranslation } from '@/data/locale'
import type { KamBotMood } from '@/types'

const LOCAL_TRANS: Record<string, { ru: string; kk: string }> = {
  decorateBtn: { ru: 'Украсить юрту! 🎨', kk: 'Киіз үйді безендіру! 🎨' },
  buildAgainBtn: { ru: 'Собрать заново! 🔄', kk: 'Қайта құру! 🔄' },
  yurtTitle: { ru: 'Юрта построена! 🏕️', kk: 'Киіз үй құрылды! 🏕️' },
  yurtSuccess: { ru: 'Твоя прекрасная юрта готова! Нажми кнопку ниже, чтобы начать украшать её!', kk: 'Сенің керемет киіз үйің дайын! Оны безендіру үшін төмендегі батырманы бас!' },
  decorTitle: { ru: '🎨 Укрась свою юрту!', kk: '🎨 Киіз үйді безендір!' },
  buildPiecesTitle: { ru: '🏗️ Перетащи детали на юрту (собирай по порядку)', kk: '🏗️ Киіз үй бөлшектерін сүйреп әкел (ретімен жина)' }
}

const KAMBOT_MSGS: Record<string, { ru: string; kk: string }> = {
  base:  { ru: 'Отличное основание!',        kk: 'Тамаша негіз!' },
  walls: { ru: 'Форма появляется!',          kk: 'Пішін пайда болуда!' },
  crown: { ru: 'Почти готово! Давай!',       kk: 'Аз қалды! Жалғастыр!' },
  felt:  { ru: 'Так тепло и уютно!',         kk: 'Қандай жылы и жайлы!' },
  door:  { ru: 'Юрта готова! Поздравляю!',  kk: 'Киіз үй дайын! Құттықтаймын!' },
}

export default function YurtBuilder() {
  const addCoins    = usePlayerStore(s => s.addCoins)
  const addXP       = usePlayerStore(s => s.addXP)
  const completeGame = usePlayerStore(s => s.completeGame)
  const unlockBadge = usePlayerStore(s => s.unlockBadge)
  const language    = usePlayerStore(s => s.language)
  const t           = getTranslation(language)

  const initMsg = language === 'kk' ? 'Киіз үй жасау үшін бөліктерді сүйрет!' : 'Перетаскивай детали, чтобы собрать юрту!'

  const [placed, setPlaced]         = useState<Set<string>>(new Set())
  const [decorations, setDecorations] = useState<Set<string>>(new Set())
  const [kamMsg, setKamMsg]         = useState(initMsg)
  const [kamMood, setKamMood]       = useState<KamBotMood>('idle')
  const [complete, setComplete]     = useState(false)
  const [confetti, setConfetti]     = useState(false)
  
  const [isDragging, setIsDragging] = useState(false)
  const yurtPreviewRef = useRef<HTMLDivElement | null>(null)

  const requiredOrder = yurtPieces.map(p => p.id)
  const nextRequired  = requiredOrder.find(id => !placed.has(id))

  const handlePieceDrop = (id: string) => {
    if (id !== nextRequired) return  // must place in order
    const newPlaced = new Set(placed)
    newPlaced.add(id)
    setPlaced(newPlaced)
    setKamMsg(KAMBOT_MSGS[id][language])
    setKamMood(id === 'door' ? 'celebrate' : 'happy')

    if (id === 'door') {
      setTimeout(() => {
        addCoins(50); addXP(80)
        completeGame('yurt'); unlockBadge('yurt-master')
        setConfetti(true)
        setComplete(true)
      }, 900)
    } else {
      setTimeout(() => setKamMood('idle'), 1500)
    }
  }

  const handleDragEnd = (id: string, event: any, info: any) => {
    if (!yurtPreviewRef.current) return
    const rect = yurtPreviewRef.current.getBoundingClientRect()
    const { x, y } = info.point
    const inside = x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom
    if (inside) {
      handlePieceDrop(id)
    }
  }

  const toggleDecor = (id: string) => {
    if (placed.size < 5) return
    const nd = new Set(decorations)
    if (nd.has(id)) nd.delete(id)
    else nd.add(id)
    setDecorations(nd)
  }

  const reset = () => {
    setPlaced(new Set()); setDecorations(new Set())
    setKamMsg(initMsg)
    setKamMood('idle'); setComplete(false); setConfetti(false)
  }

  return (
    <GameLayout title={t.gameTitleYurt} kambot={{ show: false }}>
      <Confetti active={confetti} />

      <div className="px-3 pb-3 flex flex-col gap-3">
        {/* KamBot guide */}
        <div className="flex items-end gap-2">
          <KamBot mood={kamMood} size={64} className={kamMood === 'celebrate' ? 'animate-wiggle' : ''} />
          <div className="glass rounded-3xl p-3 text-white text-sm font-bold flex-1">
            {kamMsg}
          </div>
        </div>

        {/* Yurt preview */}
        <div
          ref={yurtPreviewRef}
          className="glass rounded-4xl p-4 transition-all duration-300"
          style={{
            boxShadow: isDragging ? '0 0 20px rgba(245, 166, 35, 0.3)' : 'none',
            borderColor: isDragging ? 'rgba(245, 166, 35, 0.5)' : 'rgba(255, 255, 255, 0.08)',
            borderWidth: 2,
            borderStyle: isDragging ? 'dashed' : 'solid',
          }}
        >
          <p className="text-white/50 text-xs font-bold mb-3 text-center">Your Yurt</p>
          <div className="relative mx-auto animate-float" style={{ width: 180, height: 160 }}>
            {/* Base ring */}
            <AnimatePresence>
              {placed.has('base') && (
                <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }}
                  className="absolute bottom-0 left-1/2 -translate-x-1/2 rounded-full border-4 border-kazakh-gold"
                  style={{ width: 160, height: 30, background: '#3D2A10', zIndex: 1 }} />
              )}
            </AnimatePresence>

            {/* Walls */}
            <AnimatePresence>
              {placed.has('walls') && (
                <motion.div initial={{ scaleY: 0, originY: 1 }} animate={{ scaleY: 1 }}
                  className="absolute bottom-3 left-1/2 -translate-x-1/2 rounded-t-lg border-2 border-kazakh-gold/50"
                  style={{ width: 140, height: 70, background: 'linear-gradient(180deg, #5A3A1A, #3D2A10)', zIndex: 2 }}>
                  {/* lattice lines */}
                  {[0,1,2,3].map(i => <div key={i} className="absolute border-r border-kazakh-gold/30 h-full" style={{ left: `${(i+1)*20}%` }} />)}
                  {[0,1,2].map(i => <div key={i} className="absolute border-b border-kazakh-gold/30 w-full" style={{ top: `${(i+1)*25}%` }} />)}
                </motion.div>
              )}
            </AnimatePresence>

            {/* Crown wheel */}
            <AnimatePresence>
              {placed.has('crown') && (
                <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }}
                  className="absolute top-4 left-1/2 -translate-x-1/2 rounded-full border-2 border-kazakh-gold flex items-center justify-center"
                  style={{ width: 50, height: 50, background: '#2D1B69', zIndex: 4 }}>
                  <span className="text-xl">☸️</span>
                </motion.div>
              )}
            </AnimatePresence>

            {/* Felt cover */}
            <AnimatePresence>
              {placed.has('felt') && (
                <motion.div initial={{ scaleY: 0, originY: 1 }} animate={{ scaleY: 1 }}
                  className="absolute left-1/2 -translate-x-1/2"
                  style={{ bottom: 73, width: 150, height: 70,
                    background: 'linear-gradient(180deg, #E8D5A0, #C8A860)',
                    clipPath: 'polygon(50% 0%, 100% 100%, 0% 100%)', borderRadius: 4, zIndex: 3 }} />
              )}
            </AnimatePresence>

            {/* Door */}
            <AnimatePresence>
              {placed.has('door') && (
                <motion.div initial={{ scaleY: 0, originY: 1 }} animate={{ scaleY: 1 }}
                  className="absolute bottom-3 left-1/2 -translate-x-1/2 rounded-t-full border-2 border-kazakh-gold"
                  style={{ width: 32, height: 44, background: '#8B4513', zIndex: 5 }} />
              )}
            </AnimatePresence>

            {/* Decorations overlay (Render all 6 decorations as draggable sandbox sticker elements) */}
            {decorations.has('carpet') && (
              <motion.div
                drag
                dragConstraints={yurtPreviewRef}
                dragElastic={0.05}
                dragMomentum={false}
                className="absolute bottom-4 left-2 text-2xl select-none touch-none"
                style={{ zIndex: 20, cursor: 'grab' }}
                whileHover={{ scale: 1.25, filter: 'drop-shadow(0px 4px 8px rgba(245,166,35,0.5))' }}
                whileTap={{ cursor: 'grabbing' }}
                whileDrag={{ scale: 1.35, zIndex: 100 }}
              >
                🎨
              </motion.div>
            )}

            {decorations.has('dombra') && (
              <motion.div
                drag
                dragConstraints={yurtPreviewRef}
                dragElastic={0.05}
                dragMomentum={false}
                className="absolute bottom-4 right-2 text-2xl select-none touch-none"
                style={{ zIndex: 20, cursor: 'grab' }}
                whileHover={{ scale: 1.25, filter: 'drop-shadow(0px 4px 8px rgba(245,166,35,0.5))' }}
                whileTap={{ cursor: 'grabbing' }}
                whileDrag={{ scale: 1.35, zIndex: 100 }}
              >
                🎵
              </motion.div>
            )}

            {decorations.has('lantern') && (
              <motion.div
                drag
                dragConstraints={yurtPreviewRef}
                dragElastic={0.05}
                dragMomentum={false}
                className="absolute top-12 right-4 text-2xl select-none touch-none"
                style={{ zIndex: 20, cursor: 'grab' }}
                whileHover={{ scale: 1.25, filter: 'drop-shadow(0px 4px 8px rgba(245,166,35,0.5))' }}
                whileTap={{ cursor: 'grabbing' }}
                whileDrag={{ scale: 1.35, zIndex: 100 }}
              >
                🏮
              </motion.div>
            )}

            {decorations.has('chest') && (
              <motion.div
                drag
                dragConstraints={yurtPreviewRef}
                dragElastic={0.05}
                dragMomentum={false}
                className="absolute bottom-4 left-[34%] text-2xl select-none touch-none"
                style={{ zIndex: 20, cursor: 'grab' }}
                whileHover={{ scale: 1.25, filter: 'drop-shadow(0px 4px 8px rgba(245,166,35,0.5))' }}
                whileTap={{ cursor: 'grabbing' }}
                whileDrag={{ scale: 1.35, zIndex: 100 }}
              >
                🧰
              </motion.div>
            )}

            {decorations.has('cauldron') && (
              <motion.div
                drag
                dragConstraints={yurtPreviewRef}
                dragElastic={0.05}
                dragMomentum={false}
                className="absolute bottom-4 left-10 text-2xl select-none touch-none"
                style={{ zIndex: 20, cursor: 'grab' }}
                whileHover={{ scale: 1.25, filter: 'drop-shadow(0px 4px 8px rgba(245,166,35,0.5))' }}
                whileTap={{ cursor: 'grabbing' }}
                whileDrag={{ scale: 1.35, zIndex: 100 }}
              >
                🫕
              </motion.div>
            )}

            {decorations.has('flowers') && (
              <motion.div
                drag
                dragConstraints={yurtPreviewRef}
                dragElastic={0.05}
                dragMomentum={false}
                className="absolute bottom-4 right-10 text-2xl select-none touch-none"
                style={{ zIndex: 20, cursor: 'grab' }}
                whileHover={{ scale: 1.25, filter: 'drop-shadow(0px 4px 8px rgba(245,166,35,0.5))' }}
                whileTap={{ cursor: 'grabbing' }}
                whileDrag={{ scale: 1.35, zIndex: 100 }}
              >
                🌸
              </motion.div>
            )}
          </div>

          {/* Progress bar */}
          <div className="flex gap-1 mt-3 justify-center">
            {yurtPieces.map(p => (
              <div key={p.id}
                className="h-2 flex-1 rounded-full transition-all duration-500"
                style={{ background: placed.has(p.id) ? '#F5A623' : 'rgba(255,255,255,0.15)' }} />
            ))}
          </div>
        </div>

        {/* Pieces to place */}
        <div className="glass rounded-4xl p-3">
          <p className="text-white/50 text-xs font-bold mb-2">{LOCAL_TRANS.buildPiecesTitle[language]}</p>
          <div className="flex gap-2 justify-center pb-1">
            {yurtPieces.map((p, idx) => {
              const isNext = p.id === nextRequired
              const isDone = placed.has(p.id)
              return (
                <motion.div
                  key={p.id}
                  className="flex flex-col items-center gap-1 rounded-2xl p-2 shrink-0 min-w-[56px] select-none touch-none"
                  style={{
                    background: isDone ? 'rgba(0,229,160,0.15)' : isNext ? 'rgba(245,166,35,0.2)' : 'rgba(255,255,255,0.05)',
                    border: isDone ? '2px solid #00E5A0' : isNext ? '2px solid #F5A623' : '2px solid transparent',
                    opacity: !isDone && !isNext && idx > (placed.size) ? 0.4 : 1,
                    cursor: isNext ? 'grab' : 'default',
                    zIndex: isDragging && isNext ? 100 : 10,
                  }}
                  drag={isNext}
                  dragSnapToOrigin
                  onDragStart={() => isNext && setIsDragging(true)}
                  onDragEnd={(event, info) => {
                    setIsDragging(false)
                    if (isNext) handleDragEnd(p.id, event, info)
                  }}
                  whileHover={isNext ? { scale: 1.08 } : {}}
                  whileTap={isNext ? { scale: 0.92, cursor: 'grabbing' } : {}}
                  whileDrag={{ scale: 1.18, rotate: 3, boxShadow: '0 15px 30px rgba(0,0,0,0.4)', zIndex: 100 }}
                  onTap={() => isNext && handlePieceDrop(p.id)}
                >
                  <span className="text-2xl">{isDone ? '✅' : p.icon}</span>
                  <span className="text-[9px] font-bold text-white/60 text-center leading-tight">{p.label}</span>
                </motion.div>
              )
            })}
          </div>
        </div>

        {/* Decorations (unlocked after all pieces) */}
        {placed.size >= 5 && (
          <motion.div
            className="glass rounded-4xl p-3"
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
          >
            <div className="flex justify-between items-center mb-2">
              <p className="text-white/50 text-xs font-bold">{LOCAL_TRANS.decorTitle[language]}</p>
              <button 
                onClick={reset}
                className="text-[10px] bg-red-600/20 hover:bg-red-600/35 text-red-200 border border-red-500/30 px-2 py-1 rounded-full font-bold transition-colors"
              >
                {LOCAL_TRANS.buildAgainBtn[language]}
              </button>
            </div>
            <div className="flex flex-wrap gap-2">
              {yurtDecorations.map(d => (
                <motion.button
                  key={d.id}
                  className="flex flex-col items-center gap-1 rounded-2xl p-2"
                  style={{
                    background: decorations.has(d.id) ? 'rgba(0,180,216,0.2)' : 'rgba(255,255,255,0.06)',
                    border: decorations.has(d.id) ? '2px solid #00B4D8' : '2px solid transparent',
                  }}
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                  onClick={() => toggleDecor(d.id)}
                >
                  <span className="text-2xl">{d.icon}</span>
                  <span className="text-[9px] font-bold text-white/50">{d.label}</span>
                </motion.button>
              ))}
            </div>
          </motion.div>
        )}
      </div>

      {/* Complete modal */}
      <Modal open={complete} onClose={() => setComplete(false)}>
        <div className="text-center">
          <div className="mb-3"><KamBot mood="celebrate" size={100} /></div>
          <h2 className="text-kazakh-gold font-black text-2xl mb-1">{LOCAL_TRANS.yurtTitle[language]}</h2>
          <p className="text-white/70 font-bold text-sm mb-2">{LOCAL_TRANS.yurtSuccess[language]}</p>
          <p className="text-white/60 text-sm mb-5">
            <span className="text-kazakh-gold font-black">+50 🪙 +80 ⭐ XP</span> earned!
          </p>
          <div className="glass rounded-3xl p-3 mb-4 text-4xl text-center">
            🏕️ ✨ 🎨 ✨ 🏕️
          </div>
          <Button variant="primary" fullWidth onClick={() => setComplete(false)}>
            {LOCAL_TRANS.decorateBtn[language]}
          </Button>
        </div>
      </Modal>
    </GameLayout>
  )
}
