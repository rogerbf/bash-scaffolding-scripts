package-json () {
  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  package.main = './distribution/index.js'
  package.files = ['distribution', 'README.md']
  package.dependencies = {}
  package.scripts['test'] = 'echo \'no tests\''
  package.scripts['prebuild'] = 'npm test && rimraf distribution'
  package.scripts['build'] = 'cross-env BABEL_ENV=production babel --out-dir distribution source'
  package.scripts['prepublish'] = 'npm run nsp && npm run build'
  package.scripts['start'] = 'npm run build && node ./distribution/index.js'
  package.scripts['watch:start'] = 'chokidar \"source/*.js\" \"source/**/*.js\" -c \"npm run start\"'
  package.scripts['eslint'] = 'eslint source'
  package.scripts['eslint:fix'] = 'eslint --fix source'
  package.scripts['repl'] = 'npm run build && babel-node'
  package.scripts['nsp'] = 'nsp check'
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}
