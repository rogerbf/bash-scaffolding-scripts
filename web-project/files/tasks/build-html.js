const { fork } = require(`child_process`)
const { join } = require(`path`)

const ENV = process.env.NODE_ENV

fork(
  join(
    __dirname,
    `../node_modules/.bin/html-minifier`
  ),
  [
    ...[ `--input-dir`, `source` ],
    ...[ `--output-dir`, `build` ],
    ...[ `--file-ext`, `html` ],
    ...(
      ENV === `production`
      ? [
        `--collapse-whitespace`,
        `--remove-comments`,
        `--minify-css`,
        `--minify-js`
      ]
      : []
    )
  ]
)
.on(`error`, error => {
  console.error(error)
  process.exit(1)
})
.on(`close`, code => {
  code !== 0 && process.exit(code)
  process.exit()
})
