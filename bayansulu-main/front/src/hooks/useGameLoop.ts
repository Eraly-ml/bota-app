import { useRef, useEffect, useCallback } from 'react'

export function useGameLoop(
  callback: (deltaTime: number) => void,
  running: boolean
) {
  const callbackRef = useRef(callback)
  const rafRef = useRef<number>(0)
  const lastTimeRef = useRef<number | undefined>(undefined)

  useEffect(() => {
    callbackRef.current = callback
  }, [callback])

  const loop = useCallback((time: number) => {
    if (lastTimeRef.current !== undefined) {
      const delta = time - lastTimeRef.current
      callbackRef.current(delta)
    }
    lastTimeRef.current = time
    rafRef.current = requestAnimationFrame(loop)
  }, [])

  useEffect(() => {
    if (running) {
      rafRef.current = requestAnimationFrame(loop)
    } else {
      if (rafRef.current) cancelAnimationFrame(rafRef.current)
      lastTimeRef.current = undefined
    }
    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current)
    }
  }, [running, loop])
}
