/**
 * useElevenLabs — ElevenLabs TTS hook
 * Voice: Charlotte (XB0fDUnXU5powFXDhCwa) — authoritative female, multilingual v2
 * Supports Russian (ru-RU) and Kazakh (kk-KZ) natively.
 */

import { useCallback, useRef } from 'react'
import { usePlayerStore } from '@/store/playerStore'

const ELEVENLABS_API_KEY = import.meta.env.VITE_ELEVENLABS_API_KEY || ''
const VOICE_ID           = 'EXAVITQu4vr4xnSDxMaL'  // Bella — free-tier female, works with multilingual v2
const MODEL_ID           = 'eleven_multilingual_v2'
const API_URL            = `https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}`

/**
 * Strip ONLY emoji/symbol characters — preserve Cyrillic, Kazakh, Latin, digits.
 * Previous version used a range [ -⁯] which accidentally covered Cyrillic (U+0400–U+04FF).
 */
function cleanText(text: string): string {
  return text
    // Emoji presentation characters (covers most modern emoji)
    .replace(/\p{Emoji_Presentation}/gu, '')
    // Supplementary Multilingual Plane emoji blocks
    .replace(/[\u{1F000}-\u{1FFFF}]/gu, '')
    // Miscellaneous symbols (☀ ➿ etc.)
    .replace(/[\u{2600}-\u{27BF}]/gu, '')
    // Enclosed alphanumerics, dingbats
    .replace(/[\u{2700}-\u{27FF}]/gu, '')
    // Strip variation selectors (U+FE00–U+FE0F) that slip through as invisible chars
    .replace(/[︀-️]/g, '')
    // Collapse multiple spaces
    .replace(/\s+/g, ' ')
    .trim()
}

export function useElevenLabs() {
  const { soundMuted } = usePlayerStore()
  const audioRef    = useRef<HTMLAudioElement | null>(null)
  const pendingRef  = useRef(false)
  const lastTextRef = useRef<string>('')   // deduplicate identical rapid calls

  const speak = useCallback(async (text: string) => {
    if (soundMuted) return
    if (!ELEVENLABS_API_KEY) {
      console.warn('[ElevenLabs] No API key configured. Skipping TTS.')
      return
    }

    const clean = cleanText(text)
    if (!clean) return

    // Skip if this exact text was just requested (StrictMode double-invoke guard)
    if (clean === lastTextRef.current && audioRef.current) return
    lastTextRef.current = clean

    // Stop any currently playing audio
    if (audioRef.current) {
      audioRef.current.pause()
      URL.revokeObjectURL(audioRef.current.src)
      audioRef.current = null
    }

    // Deduplicate concurrent calls
    if (pendingRef.current) return
    pendingRef.current = true

    console.log('[ElevenLabs] speaking:', clean.slice(0, 60))

    try {
      const res = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'xi-api-key':   ELEVENLABS_API_KEY,
          'Content-Type': 'application/json',
          Accept:         'audio/mpeg',
        },
        body: JSON.stringify({
          text:     clean,
          model_id: MODEL_ID,
          voice_settings: {
            stability:         0.78,   // firm & consistent = authoritative
            similarity_boost:  0.88,
            style:             0.28,   // low style = clean delivery
            use_speaker_boost: true,
          },
        }),
      })

      if (!res.ok) {
        const errText = await res.text().catch(() => res.statusText)
        console.warn('[ElevenLabs] API error', res.status, errText)
        return
      }

      const blob  = await res.blob()

      // Cancellation guard: if stop was called or a different speak request took over during fetch
      if (clean !== lastTextRef.current) {
        console.log('[ElevenLabs] speech request cancelled during fetch for:', clean.slice(0, 30))
        return
      }

      const url   = URL.createObjectURL(blob)
      const audio = new Audio(url)
      audioRef.current = audio

      audio.onended = () => {
        URL.revokeObjectURL(url)
        if (audioRef.current === audio) audioRef.current = null
      }

      try {
        await audio.play()
        console.log('[ElevenLabs] playing audio OK')
      } catch (playErr: any) {
        // Browser autoplay blocked — user must interact first. Click the bubble to replay.
        console.warn('[ElevenLabs] autoplay blocked (need user gesture):', playErr?.message)
      }
    } catch (err) {
      console.warn('[ElevenLabs] speak failed:', err)
    } finally {
      pendingRef.current = false
    }
  }, [soundMuted])

  const stop = useCallback(() => {
    lastTextRef.current = '' // Reset currently playing/requested text
    if (audioRef.current) {
      audioRef.current.pause()
      URL.revokeObjectURL(audioRef.current.src)
      audioRef.current = null
    }
  }, [])

  return { speak, stop }
}
