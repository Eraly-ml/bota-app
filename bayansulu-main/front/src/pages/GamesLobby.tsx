import { motion } from 'framer-motion'
import { useNavigate } from 'react-router-dom'
import {
  Brain, House, MathOperations, Trophy, Horse, ArrowRight, BookOpen,
} from '@phosphor-icons/react'
import HUDBar from '@/components/layout/HUDBar'
import BottomNav from '@/components/layout/BottomNav'
import { usePlayerStore } from '@/store/playerStore'
import { useGameStore } from '@/store/gameStore'
import { getTranslation } from '@/data/locale'
import { pageVariants, staggerContainer, staggerItem } from '@/hooks/useAnimation'

interface LobbyGame {
  id: string
  to: string
  Icon: React.FC<{ size?: number; weight?: string; color?: string }>
  accentColor: string
  bgFrom: string
  bgTo: string
  nameRu: string
  nameKk: string
  descRu: string
  descKk: string
  locRu: string
  locKk: string
}

const LOBBY_GAMES: LobbyGame[] = [
  {
    id: 'memory',
    to: '/games/memory',
    Icon: Brain as any,
    accentColor: '#F43F5E',
    bgFrom: '#4C0519',
    bgTo: '#881337',
    nameRu: 'Собери сладости',
    nameKk: 'Тәттілерді жина',
    descRu: 'Находи пары символов и сладостей на скорость',
    descKk: 'Жылдамдықпен белгілер мен тәттілердің жұбын тап',
    locRu: 'Алматы',
    locKk: 'Алматы',
  },
  {
    id: 'yurt',
    to: '/games/yurt',
    Icon: House as any,
    accentColor: '#10B981',
    bgFrom: '#022C22',
    bgTo: '#065F46',
    nameRu: 'Сборка Юрты',
    nameKk: 'Киіз үй құрау',
    descRu: 'Собери традиционную юрту и укрась её коврами',
    descKk: 'Дәстүрлі киіз үйді құрап, кілемдермен сәнде',
    locRu: 'Туркестан',
    locKk: 'Түркістан',
  },
  {
    id: 'math',
    to: '/games/math',
    Icon: MathOperations as any,
    accentColor: '#D97706',
    bgFrom: '#1C1200',
    bgTo: '#451A03',
    nameRu: 'Счёт с Ботой',
    nameKk: 'Ботамен санау',
    descRu: 'Реши примеры и победи сладких монстров',
    descKk: 'Есептер шығарып, тәтті құбыжықтарды жең',
    locRu: 'Великая Степь',
    locKk: 'Ұлы Дала',
  },
  {
    id: 'quiz',
    to: '/games/quiz',
    Icon: Trophy as any,
    accentColor: '#0EA5E9',
    bgFrom: '#082F49',
    bgTo: '#0C4A6E',
    nameRu: 'Викторина КамБота',
    nameKk: 'КамБот викторинасы',
    descRu: 'Вопросы о географии и традициях Казахстана',
    descKk: 'Қазақстанның географиясы мен дәстүрлері туралы',
    locRu: 'Астана',
    locKk: 'Астана',
  },
  {
    id: 'runner',
    to: '/games/runner',
    Icon: Horse as any,
    accentColor: '#EA580C',
    bgFrom: '#1C0700',
    bgTo: '#7C2D12',
    nameRu: 'Верблюд-Бегун',
    nameKk: 'Түйе жүгіруші',
    descRu: 'Беги по Чарыну, уворачивайся от кактусов',
    descKk: 'Шарынмен жүгіріп, кактустардан аул',
    locRu: 'Чарынский каньон',
    locKk: 'Шарын шатқалы',
  },
  {
    id: 'words',
    to: '/games/words',
    Icon: BookOpen as any,
    accentColor: '#8B5CF6',
    bgFrom: '#1E1B4B',
    bgTo: '#4C1D95',
    nameRu: 'Қазақша сөздер',
    nameKk: 'Қазақша сөздер',
    descRu: 'Учи казахские слова по картинкам',
    descKk: 'Суреттер арқылы қазақша сөздер үйрен',
    locRu: 'Атырау',
    locKk: 'Атырау',
  },
]

export default function GamesLobby() {
  const language   = usePlayerStore(s => s.language)
  const highScores = useGameStore(s => s.highScores)
  const navigate   = useNavigate()
  const t          = getTranslation(language)

  const titleStr = language === 'ru' ? 'Игротека' : 'Ойындар'
  const subStr   = language === 'ru' ? 'Выбери своё приключение' : 'Саяхатыңды тандап ал'

  return (
    <motion.div
      className="min-h-dvh flex flex-col"
      style={{ background: '#0D0404' }}
      variants={pageVariants} initial="initial" animate="animate" exit="exit"
    >
      <HUDBar />

      <div className="flex-1 overflow-y-auto px-4 pt-5 pb-4">

        {/* Header — left-aligned, no center bias */}
        <div className="mb-5">
          <h1
            className="font-brand text-cream leading-none tracking-tight"
            style={{ fontSize: 28 }}
          >
            {titleStr}
          </h1>
          <p className="text-sm font-bold mt-1" style={{ color: 'rgba(254,243,199,0.45)' }}>
            {subStr}
          </p>
        </div>

        {/* Game cards — staggered list */}
        <motion.div
          className="space-y-3"
          variants={staggerContainer}
          initial="initial"
          animate="animate"
        >
          {LOBBY_GAMES.map((game) => {
            const name = language === 'ru' ? game.nameRu : game.nameKk
            const desc = language === 'ru' ? game.descRu : game.descKk
            const loc  = language === 'ru' ? game.locRu  : game.locKk
            const hs   = highScores[game.id] ?? 0
            const { Icon } = game

            return (
              <motion.button
                key={game.id}
                variants={staggerItem}
                className="w-full text-left flex gap-0 rounded-3xl overflow-hidden relative"
                style={{
                  background: `linear-gradient(145deg, ${game.bgFrom}, ${game.bgTo})`,
                  border: `1px solid ${game.accentColor}22`,
                  boxShadow: `inset 0 1px 0 rgba(255,255,255,0.06), 0 4px 20px rgba(0,0,0,0.4)`,
                }}
                whileTap={{ scale: 0.975, y: 1 }}
                onClick={() => navigate(game.to)}
              >
                {/* Color slab on the left */}
                <div
                  className="w-14 shrink-0 flex items-center justify-center"
                  style={{ background: `${game.accentColor}22` }}
                >
                  <Icon size={26} weight="duotone" color={game.accentColor} />
                </div>

                {/* Content */}
                <div className="flex-1 px-3 py-3.5 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <div className="min-w-0 flex-1">
                      <p
                        className="font-black text-sm leading-tight truncate"
                        style={{ color: game.accentColor }}
                      >
                        {name}
                      </p>
                      <p
                        className="text-[11px] font-medium mt-0.5 leading-snug line-clamp-2"
                        style={{ color: 'rgba(254,243,199,0.55)' }}
                      >
                        {desc}
                      </p>
                    </div>
                    <ArrowRight
                      size={16}
                      weight="bold"
                      color={`${game.accentColor}88`}
                      className="shrink-0 mt-0.5"
                    />
                  </div>

                  {/* Footer row */}
                  <div className="flex items-center gap-2 mt-2">
                    <span
                      className="text-[9px] font-black tracking-widest uppercase px-2 py-0.5 rounded-full"
                      style={{
                        background: `${game.accentColor}15`,
                        color: `${game.accentColor}cc`,
                        border: `1px solid ${game.accentColor}25`,
                      }}
                    >
                      {loc}
                    </span>
                    {hs > 0 && (
                      <span
                        className="text-[9px] font-black tracking-wider uppercase px-2 py-0.5 rounded-full"
                        style={{
                          background: 'rgba(217,119,6,0.12)',
                          color: '#D97706',
                          border: '1px solid rgba(217,119,6,0.2)',
                        }}
                      >
                        {t.gameScore}: {hs}
                      </span>
                    )}
                  </div>
                </div>
              </motion.button>
            )
          })}
        </motion.div>

        {/* Bottom breathing room */}
        <div className="h-4" />
      </div>

      <BottomNav />
    </motion.div>
  )
}
