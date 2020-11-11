module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/views/**/*.ex",
    "../**/live/**/*.ex",
    "./js/**/*.js"
  ],
  theme: {
    inset: {
      '0': '0',
      'auto': 'auto',
      '4': '1rem',
      '8': '2rem',
      '12': '3rem',
      '16': '4rem'
    }
  },
  variants: {},
  plugins: [],
}
