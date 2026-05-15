import {
  defineConfig,
  presetUno,
  presetAttributify,
  presetIcons,
  presetWebFonts,
} from 'unocss'

export default defineConfig({
  presets: [
    presetUno(),
    presetAttributify(),
    presetIcons({
      scale: 1.2,
      cdn: 'https://esm.sh/',
    }),
    presetWebFonts({
      provider: 'google',
      fonts: {
        sans: 'Inter:400,500,600,700',
        mono: 'Fira Code',
      },
    }),
  ],
  shortcuts: [
    ['flex-center', 'flex justify-center items-center'],
    ['flex-between', 'flex justify-between items-center'],
    ['btn', 'px-4 py-2 rounded cursor-pointer transition-all duration-200'],
    ['btn-primary', 'btn bg-blue-500 text-white hover:bg-blue-600'],
  ],
  theme: {
    colors: {
      primary: '#409eff',
    },
  },
})