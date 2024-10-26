import type { Config } from 'tailwindcss';

const config = {
  darkMode: ['class'],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  prefix: '',
  theme: {
    container: {
      center: true,
      padding: '2rem',
      screens: {
        '2xl': '1400px',
      },
    },
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
        yuma: {
          '50': '#f9f7f1',
          '100': '#ede9d8',
          '200': '#d3c89d', //Default cream
          '300': '#c7b782',
          '400': '#baa265',
          '500': '#ae8c52',
          '600': '#997246',
          '700': '#805a3d',
          '800': '#6a4a36',
          '900': '#583e2f',
          '950': '#312017',
        },
        chalet: {
          '50': '#f5f7ee',
          '100': '#e9ecdb',
          '200': '#d3dcba',
          '300': '#b7c591',
          '400': '#9bad6e',
          '500': '#7e9250',
          '600': '#62733d',
          '700': '#556438', //Default dark olive
          '800': '#3f482c',
          '900': '#363f28',
          '950': '#1b2112',
        },
        woodsmoke: {
          '50': '#f6f7f7',
          '100': '#e1e6e5',
          '200': '#c3ccca',
          '300': '#9daba9',
          '400': '#798886',
          '500': '#5e6e6c',
          '600': '#4a5756',
          '700': '#3e4747',
          '800': '#343b3b',
          '900': '#2e3333',
          '950': '#171b1b', //Default light black
        },
        husk: {
          '50': '#f7f6ee',
          '100': '#edeada',
          '200': '#dcd7ba',
          '300': '#c5be91',
          '400': '#aca468', //Default olive green
          '500': '#938c4f',
          '600': '#746f3c',
          '700': '#5a5831',
          '800': '#49472b',
          '900': '#3f3f28',
          '950': '#212112',
        },
        wasabi: {
          '50': '#f5f7ee',
          '100': '#eaeed9',
          '200': '#d7deb8',
          '300': '#bcc88e',
          '400': '#a1b269',
          '500': '#798a45', //Default in between dark olive and olive
          '600': '#667739',
          '700': '#505c2f',
          '800': '#414b29',
          '900': '#394126',
          '950': '#1d2211',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      keyframes: {
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-accordion-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-accordion-content-height)' },
          to: { height: '0' },
        },
      },
      animation: {
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
      },
    },
  },
  plugins: [require('tailwindcss-animate'), require('flowbite/plugin')],
} satisfies Config;

export default config;
