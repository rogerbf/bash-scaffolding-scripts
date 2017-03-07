binary () {
  mkdir source/binary

  {
    echo '#!/usr/bin/env node'
    echo 'const main = require(`../index`)'
  } >> source/binary/cli.js

  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  Object.assign(
    package,
    { bin: { [package.name]: './distribution/binary/cli.js' } }
  )
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}
