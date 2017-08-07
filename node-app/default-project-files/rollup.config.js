import { main as cjs, module as esm, dependencies } from './package.json'
import babel from 'rollup-plugin-babel'

export default Object.assign(
  {
    entry: `source/main.js`,
    targets: [
      { dest: cjs, format: `cjs` },
      { dest: esm, format: `es` },
    ],
    plugins: [
      babel({ exclude: `node_modules/**` })
    ]
  },
  dependencies ? { external: Object.keys(dependencies) } : {},
)
