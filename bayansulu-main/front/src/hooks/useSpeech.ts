/**
 * useSpeech — thin wrapper that delegates to ElevenLabs TTS.
 * Existing call-sites don't need changing.
 */
export { useElevenLabs as useSpeech } from '@/hooks/useElevenLabs'
