/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#8B1A1A',
        'primary-light': '#FFF0F0',
      }
    },
  },
  plugins: [],
}