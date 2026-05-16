// Ambient floating clouds for the World Map
export default function CloudLayer() {
  const clouds = [
    { y: '12%', duration: 42, delay: 0,  scale: 1.0, opacity: 0.08 },
    { y: '24%', duration: 58, delay: -15, scale: 0.7, opacity: 0.06 },
    { y: '8%',  duration: 70, delay: -30, scale: 1.3, opacity: 0.07 },
    { y: '38%', duration: 90, delay: -50, scale: 0.55, opacity: 0.05 },
  ]

  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden">
      {clouds.map((c, i) => (
        <div
          key={i}
          className="absolute"
          style={{
            top: c.y,
            opacity: c.opacity,
            transform: `scale(${c.scale})`,
            animation: `runnerBg ${c.duration}s linear ${c.delay}s infinite`,
          }}
        >
          {/* Cloud: 3 overlapping circles */}
          <svg viewBox="0 0 120 50" width="200" fill="white">
            <circle cx="40" cy="35" r="22" />
            <circle cx="65" cy="28" r="28" />
            <circle cx="90" cy="35" r="20" />
            <rect x="20" y="35" width="88" height="20" />
          </svg>
        </div>
      ))}
    </div>
  )
}
