/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './index.html',
    './src/**/*.{js,jsx,ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Paleta SIRES — azul institucional salud pública México
        primary: {
          50:  '#e6f0ff',
          100: '#b3d1ff',
          200: '#80b2ff',
          300: '#4d94ff',
          400: '#1a75ff',
          500: '#0057e6',
          600: '#0044b3',
          700: '#003280',
          800: '#00214d',
          900: '#00101a',
        },
        secondary: {
          500: '#00897b', // verde salud
          600: '#00695c',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
