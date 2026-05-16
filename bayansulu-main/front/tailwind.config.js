/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        /* ── warm dark palette ── */
        'noir':         '#0D0404',   // deepest bg
        'surface':      '#180808',   // card bg
        'surface-2':    '#220D0D',   // elevated surface
        'bordeaux':     '#6B1A1A',   // бордовый
        'crimson':      '#991B1B',   // deep red
        'scarlet':      '#DC2626',   // bright red
        'ember':        '#EA580C',   // burnt orange
        'gold':         '#D97706',   // amber / Kazakh gold
        'gold-light':   '#FCD34D',   // highlight
        'cream':        '#FEF3C7',   // off-white text

        /* ── backward-compat aliases (old tokens referenced in game pages) ── */
        'deep-navy':      '#0D0404',
        'surface-purple': '#220D0D',
        'kazakh-gold':    '#D97706',
        'sky-blue':       '#0EA5E9',
        'warm-orange':    '#EA580C',
        'candy-pink':     '#F43F5E',
        'mint-green':     '#10B981',
      },
      fontFamily: {
        nunito:    ['Nunito',    'sans-serif'],
        unbounded: ['Unbounded', 'sans-serif'],
      },
      borderRadius: {
        '3xl': '1.5rem',
        '4xl': '2rem',
        '5xl': '3rem',
      },
      animation: {
        'float':      'float 3s ease-in-out infinite',
        'float-slow': 'float 5s ease-in-out infinite',
        'pulse-glow': 'pulseGlow 2s ease-in-out infinite',
        'bounce-in':  'bounceIn 0.5s cubic-bezier(0.36,0.07,0.19,0.97) forwards',
        'slide-up':   'slideUp 0.4s ease-out forwards',
        'shimmer':    'shimmer 2s linear infinite',
        'spin-slow':  'spin 8s linear infinite',
        'wiggle':     'wiggle 0.4s ease-in-out',
        'coin-fly':   'coinFly 0.8s ease-out forwards',
        'runner-bg':  'runnerScroll 8s linear infinite',
        'ping-slow':  'ping 2s cubic-bezier(0,0,0.2,1) infinite',
        'ember-pulse':'emberPulse 3s ease-in-out infinite',
      },
      keyframes: {
        float: {
          '0%,100%': { transform: 'translateY(0px)' },
          '50%':     { transform: 'translateY(-12px)' },
        },
        pulseGlow: {
          '0%,100%': { boxShadow: '0 0 10px 2px rgba(217,119,6,0.3)' },
          '50%':     { boxShadow: '0 0 25px 8px rgba(217,119,6,0.6)' },
        },
        emberPulse: {
          '0%,100%': { boxShadow: '0 0 12px 2px rgba(234,88,12,0.25)' },
          '50%':     { boxShadow: '0 0 28px 8px rgba(220,38,38,0.45)' },
        },
        bounceIn: {
          '0%':   { transform: 'scale(0.3)', opacity: '0' },
          '60%':  { transform: 'scale(1.1)', opacity: '1' },
          '80%':  { transform: 'scale(0.95)' },
          '100%': { transform: 'scale(1)' },
        },
        slideUp: {
          from: { transform: 'translateY(30px)', opacity: '0' },
          to:   { transform: 'translateY(0)',    opacity: '1' },
        },
        shimmer: {
          '0%':   { backgroundPosition: '-200% center' },
          '100%': { backgroundPosition: '200% center' },
        },
        wiggle: {
          '0%,100%': { transform: 'rotate(0deg)' },
          '25%':     { transform: 'rotate(-8deg)' },
          '75%':     { transform: 'rotate(8deg)' },
        },
        coinFly: {
          '0%':   { transform: 'translateY(0) scale(1)',       opacity: '1' },
          '100%': { transform: 'translateY(-80px) scale(0.5)', opacity: '0' },
        },
        runnerScroll: {
          from: { transform: 'translateX(0)' },
          to:   { transform: 'translateX(-50%)' },
        },
      },
      boxShadow: {
        'glow-gold':    '0 0 20px 4px rgba(217,119,6,0.45)',
        'glow-ember':   '0 0 20px 4px rgba(234,88,12,0.45)',
        'glow-crimson': '0 0 20px 4px rgba(153,27,27,0.5)',
        'glow-blue':    '0 0 20px 4px rgba(14,165,233,0.4)',
        'glow-orange':  '0 0 20px 4px rgba(234,88,12,0.45)',
        'glow-pink':    '0 0 20px 4px rgba(244,63,94,0.45)',
        'card':         '0 8px 32px rgba(0,0,0,0.55)',
        'button':       '0 4px 16px rgba(0,0,0,0.4)',
        'inset-light':  'inset 0 1px 0 rgba(255,255,255,0.07)',
      },
    },
  },
  plugins: [],
}
