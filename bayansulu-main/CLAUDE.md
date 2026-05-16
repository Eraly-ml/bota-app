# CLAUDE.md — Bayan Sulu Kids Development Guidelines

This file serves as a reference for commands, architectures, and styling constraints used in the Bayan Sulu Kids mobile web application.

## 🚀 Key Commands

### Frontend Development (`front/`)
* **Install dependencies:** `npm install --prefix front`
* **Start local development server (Port 5173):** `npm run dev --prefix front`
* **Build production bundles:** `npm run build --prefix front` (Vite output compiles to `front/dist/`)
* **Run linting checks:** `npm run lint --prefix front`

---

## 🛠️ Tech Stack & Architecture

* **Framework:** React 19 + TypeScript + Vite 8
* **Styling:** Tailwind CSS (Vanilla responsive utility styles) + custom keyframe animations in [globals.css](file:///home/eraly/Downloads/bayansulu-main/front/src/styles/globals.css)
* **Animations:** Framer Motion (page transitions, coin fly particle effects, wiggles)
* **State Management:** Zustand with local persistence in `localStorage`:
  * [playerStore.ts](file:///home/eraly/Downloads/bayansulu-main/front/src/store/playerStore.ts) handles username, age, levels, botacoins balance, streak, unlocked badges, and active discount coupons.
  * [gameStore.ts](file:///home/eraly/Downloads/bayansulu-main/front/src/store/gameStore.ts) handles daily claim timers and highscores.
* **Audio System:** Browser HTML5 Audio (`useSound.ts`) + browser-native Web Speech Synthesis API (`useSpeech.ts`).

---

## 🎨 Styling & UX Principles

1. **Mobile-First Constraints:** 
   The layout is locked to a max-width of `430px` inside [globals.css](file:///home/eraly/Downloads/bayansulu-main/front/src/styles/globals.css) on `#root`. Do not design wide screen components. Always center the phone shell on desktop viewports.
2. **Kid-Friendly Interaction:** 
   Use large rounded buttons (`rounded-3xl` or `rounded-4xl`), vibrant harmonious warm-gold gradients, and soft physics micro-animations (`animate-float`, `hover:scale-104`).
3. **No Database Dependencies:** 
   All state remains offline-first and persists automatically in `localStorage`. Do not add remote API wrappers unless implementing POS server synchronizations (marked as out of scope).
4. **Bilingual Text Node Principle:**
   Always load translations using `getTranslation(language)` from `front/src/data/locale.ts`. Avoid hardcoding Russian or Kazakh labels directly in JSX.
