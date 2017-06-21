import babel from 'rollup-plugin-babel'
import resolve from 'rollup-plugin-node-resolve'
import commonjs from 'rollup-plugin-commonjs'
import replace from 'rollup-plugin-replace'
import uglify from 'rollup-plugin-uglify'
import execute from 'rollup-plugin-execute'
import postcss from 'rollup-plugin-postcss'
import cssnext from 'postcss-cssnext'
import cssnano from 'cssnano'
import cssimport from 'postcss-import'

const ENV = process.env.NODE_ENV

const paths = {
  node_modules: `node_modules/**`
}

const baseConfiguration = {
  entry: `source/scripts/main.js`,
  dest: `build/bundle.js`,
  format: `iife`,
  sourceMap: `inline`,
  plugins: [
    postcss({
      extensions: [ `.css` ],
      plugins: [
        cssimport(),
        cssnext({
          warnForDuplicates: false
        }),
        cssnano()
      ]
    }),
    resolve({
      jsnext: true,
      main: true,
      browser: true
    }),
    commonjs(),
    babel({
      exclude: paths.node_modules
    }),
    replace({
      exclude: paths.node_modules,
      ENV: ENV || `development`
    }),
    execute([ `node tasks/build-html.js` ])
  ]
}

export default Object.assign(
  {},
  baseConfiguration,
  ENV === `production` ? {
    sourceMap: false,
    plugins: [
      ...baseConfiguration.plugins,
      uglify()
    ]
  }
  : {}
)
