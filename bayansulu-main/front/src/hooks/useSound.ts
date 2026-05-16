// Sound hook — plays audio if files exist in /public/sounds/
// Add: click.mp3, reward.mp3, correct.mp3, wrong.mp3, levelup.mp3, coin.mp3

type SoundId = 'click' | 'reward' | 'correct' | 'wrong' | 'levelup' | 'coin' | 'whoosh'

export function useSound() {
  const playSound = (id: SoundId) => {
    try {
      const audio = new Audio(`/sounds/${id}.mp3`)
      audio.volume = 0.4
      audio.play().catch(() => {}) // silent fail if file missing
    } catch {
      // no-op
    }
  }
  return { playSound }
}
