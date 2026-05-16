import type { Badge, Avatar, DailyReward, PrizeProduct } from '@/types'

// ─── Badges ────────────────────────────────────────────────────────────────────
export const badgeDefinitions: Badge[] = [
  { id: 'first-steps',    name: 'First Steps',    icon: '👣', description: 'Complete onboarding',             earned: false },
  { id: 'memory-master',  name: 'Memory Master',  icon: '🧠', description: 'Match all cards in Memory Rush',  earned: false },
  { id: 'speed-runner',   name: 'Speed Runner',   icon: '⚡', description: 'Score 300+ in Camel Runner',      earned: false },
  { id: 'yurt-master',    name: 'Yurt Master',    icon: '🏕️', description: 'Build a complete yurt',           earned: false },
  { id: 'quiz-champion',  name: 'Quiz Champion',  icon: '🏆', description: 'Answer 10 quiz questions',        earned: false },
  { id: 'math-wizard',    name: 'Math Wizard',    icon: '🔢', description: 'Reach level 3 in Math Battle',    earned: false },
  { id: 'explorer',       name: 'Explorer',       icon: '🗺️', description: 'Visit all 5 map locations',       earned: false },
  { id: 'coin-collector', name: 'Coin Collector', icon: '🪙', description: 'Collect 500 Botacoins',           earned: false },
  { id: 'streak-3',       name: 'On Fire!',       icon: '🔥', description: '3-day streak',                    earned: false },
  { id: 'combo-king',     name: 'Combo King',     icon: '💥', description: '5× combo in Math Battle',         earned: false },
  { id: 'perfect-quiz',   name: 'Perfect Score',  icon: '⭐', description: '10/10 in Quiz Adventure',         earned: false },
  { id: 'daily-player',   name: 'Daily Player',   icon: '📅', description: 'Claim 7 daily rewards',           earned: false },
  { id: 'word-master',    name: 'Word Master',    icon: '📖', description: 'Complete Kazakh Word Match',      earned: false },
  { id: 'perfect-words',  name: 'Perfect Words',  icon: '💯', description: '8/8 in Kazakh Word Match',        earned: false },
]

// ─── Avatars ───────────────────────────────────────────────────────────────────
export const avatars: Avatar[] = [
  { id: 0, emoji: '🦅', bg: 'bg-sky-blue',      label: 'Eagle' },
  { id: 1, emoji: '🐪', bg: 'bg-kazakh-gold',   label: 'Camel' },
  { id: 2, emoji: '⭐', bg: 'bg-surface-purple', label: 'Star' },
  { id: 3, emoji: '🌸', bg: 'bg-candy-pink',    label: 'Flower' },
  { id: 4, emoji: '🏔️', bg: 'bg-mint-green',    label: 'Mountain' },
  { id: 5, emoji: '🌙', bg: 'bg-warm-orange',   label: 'Moon' },
]

// ─── Memory Cards ─────────────────────────────────────────────────────────────
export const memoryCardTypes = [
  { pairId: 0,  icon: '🦅', label: 'Eagle' },
  { pairId: 1,  icon: '🐪', label: 'Camel' },
  { pairId: 2,  icon: '🏕️', label: 'Yurt' },
  { pairId: 3,  icon: '🎵', label: 'Dombra' },
  { pairId: 4,  icon: '🥘', label: 'Beshbarmak' },
  { pairId: 5,  icon: '🌸', label: 'Flower' },
  { pairId: 6,  icon: '⛰️', label: 'Mountain' },
  { pairId: 7,  icon: '🌙', label: 'Moon' },
  { pairId: 8,  icon: '🏛️', label: 'Mosque' },
  { pairId: 9,  icon: '🦁', label: 'Snow Leopard' },
  { pairId: 10, icon: '🐟', label: 'Sturgeon' },
  { pairId: 11, icon: '🌾', label: 'Wheat' },
  { pairId: 12, icon: '🍎', label: 'Apple' },
  { pairId: 13, icon: '🌊', label: 'Sea' },
  { pairId: 14, icon: '🎨', label: 'Shyrdak' },
  { pairId: 15, icon: '🐴', label: 'Horse' },
]

// ─── Daily Rewards Pool ────────────────────────────────────────────────────────
export const dailyRewardsPool: DailyReward[] = [
  { type: 'coins', amount: 50,  label: '50 Botacoins!',  icon: '🪙' },
  { type: 'coins', amount: 100, label: '100 Botacoins!', icon: '🪙' },
  { type: 'xp',   amount: 40,  label: '40 XP Boost!',   icon: '⭐' },
  { type: 'xp',   amount: 80,  label: '80 XP Boost!',   icon: '⭐' },
  { type: 'coins', amount: 150, label: 'JACKPOT! 150 Coins!', icon: '💰' },
]

export const getRandomDailyReward = (): DailyReward =>
  dailyRewardsPool[Math.floor(Math.random() * dailyRewardsPool.length)]

// ─── Yurt Pieces ─────────────────────────────────────────────────────────────
export const yurtPieces = [
  { id: 'base',   label: 'Base Ring',     icon: '⭕', required: true },
  { id: 'walls',  label: 'Lattice Walls', icon: '🪟', required: true },
  { id: 'crown',  label: 'Crown Wheel',   icon: '☸️',  required: true },
  { id: 'felt',   label: 'Felt Cover',    icon: '🏔️', required: true },
  { id: 'door',   label: 'Door',          icon: '🚪', required: true },
]

export const yurtDecorations = [
  { id: 'carpet',  label: 'Carpet',   icon: '🎨' },
  { id: 'dombra',  label: 'Dombra',   icon: '🎵' },
  { id: 'chest',   label: 'Chest',    icon: '🧰' },
  { id: 'lantern', label: 'Lantern',  icon: '🏮' },
  { id: 'cauldron',label: 'Cauldron', icon: '🫕' },
  { id: 'flowers', label: 'Flowers',  icon: '🌸' },
]

// ─── KamBot tips per screen (bilingual) ──────────────────────────────────────
export const kamBotTips: Record<string, { ru: string[]; kk: string[] }> = {
  map: {
    ru: [
      'Нажми на светящийся город, чтобы начать приключение!',
      'Собирай Ботакоины, чтобы открыть новые значки!',
      'Возвращайся каждый день за подарочным сундуком!',
    ],
    kk: [
      'Жарқыраған қалаға басып, шытырманды бастаңыз!',
      'Жаңа белгілерді ашу үшін Ботакоиндер жина!',
      'Сыйлық сандығы үшін күн сайын қайт!',
    ],
  },
  memory: {
    ru: [
      'Запоминай, где находятся пары!',
      'Комбо удваивает монеты!',
      'Ты справишься — быстро и умно!',
    ],
    kk: [
      'Жұптардың қайда екенін есте сақта!',
      'Комбо монеталарды екі есе арттырады!',
      'Жылдам және ақылды ойна, сенемін саған!',
    ],
  },
  runner: {
    ru: [
      'Нажимай, чтобы прыгать через препятствия!',
      'Собирай золотые монеты на бегу!',
      'Чем быстрее, тем больше очков!',
    ],
    kk: [
      'Кедергілерден секіру үшін басыңыз!',
      'Жүгіру кезінде алтын монеталарды жина!',
      'Неғұрлым жылдам болсаң, соғұрлым ұпай көп!',
    ],
  },
  quiz: {
    ru: [
      'Казахстан — удивительная страна!',
      'Каждый верный ответ открывает стикер!',
      'Не бойся ошибаться — учись и пробуй снова!',
    ],
    kk: [
      'Қазақстан — таңғажайып ел!',
      'Дұрыс жауап берген сайын жаңа стикер ашылады!',
      'Қателесуден қорықпа — үйрен де, қайтадан байқа!',
    ],
  },
  math: {
    ru: [
      'Отвечай быстро, чтобы победить конфетных врагов!',
      'Три правильных ответа подряд — КОМБО!',
      'Математика — твоя суперсила!',
    ],
    kk: [
      'Тәтті жаулықтарды жеңу үшін жылдам жауап бер!',
      'Қатарынан үш дұрыс жауап — КОМБО!',
      'Математика — сенің суперкүшің!',
    ],
  },
  yurt: {
    ru: [
      'Перетаскивай детали, чтобы собрать юрту!',
      'Укрась её, чтобы сделать уникальной!',
      'Казахи строят юрты уже 3000 лет!',
    ],
    kk: [
      'Киіз үй жасау үшін бөліктерді сүйрет!',
      'Оны бірегей ету үшін безендір!',
      'Қазақтар киіз үй тігіп, 3000 жыл болды!',
    ],
  },
}

// ─── Prize Store Products ──────────────────────────────────────────────────────
export const prizeStoreProducts: PrizeProduct[] = [
  {
    id: 'bota-pack-mini',
    nameRu: 'Набор конфет «Бота» (Мини)',
    nameKk: '«Бота» тәттілер жинағы (Мини)',
    cost: 500,
    emoji: '🐫',
    descriptionRu: 'Купон на скидку 300 ₸ при покупке набора молочных суфле «Бота» в фирменном магазине!',
    descriptionKk: 'Фирмалық дүкеннен «Бота» сүтті суфле жинағын сатып алғанда 300 ₸ жеңілдік купоны!',
    discountTenge: 300,
  },
  {
    id: 'bota-pack-classic',
    nameRu: 'Плитка шоколада «Баян Сулу»',
    nameKk: '«Баян Сұлу» шоколад плиткасы',
    cost: 1000,
    emoji: '🍫',
    descriptionRu: 'Купон на бесплатную плитку фирменного молочного шоколада «Баян Сулу» в любом официальном магазине!',
    descriptionKk: 'Кез келген ресми дүкенде «Баян Сұлу» сүтті шоколадын тегін алуға арналған купон!',
    discountTenge: 500,
  },
  {
    id: 'bota-pack-premium',
    nameRu: 'Семейный набор «КамБот»',
    nameKk: 'Отбасылық жинақ «КамБот»',
    cost: 2000,
    emoji: '🎁',
    descriptionRu: 'Купон на скидку 1000 ₸ на весь праздничный ассортимент детских сладостей от «Баян Сулу»!',
    descriptionKk: '«Баян Сұлу» балалар тәттілерінің барлық мерекелік ассортиментіне 1000 ₸ жеңілдік купоны!',
    discountTenge: 1000,
  },
]
