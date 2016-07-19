nodeproject () {
  echo "name:"
  read projectName
  mkdir $projectName
  cd $projectName

  # README.md
  echo "# "$projectName >> README.md

  # .gitignore
  echo "node_modules" >> .gitignore
  echo "dist" >> .gitignore
  echo ".DS_Store" >> .gitignore
  echo "package" >> .gitignore
  echo $projectName"*.tgz" >> .gitignore
  echo "npm-debug.log" >> .gitignore

  # default folders & files
  mkdir src
  echo "module.exports = {}" >> src/index.js
  echo "
  const test = require('tape')
  test('A passing test.', assert => {
    assert.pass('This test will pass.')
    assert.end()
  })
  " >> src/index.test.js

  # package.json
  npm init -y
  npm i --save-dev babel-cli babel-preset-es2015 faucet nodemon rimraf tape
  node -e "
    const eslintConfig = {
      env: {
        node: true
      },
      parserOptions: {
        ecmaVersion: 6
      }
    }
    const babel = {
      presets: ['es2015']
    }
    const fs = require('fs')
    const package = JSON.parse(fs.readFileSync('./package.json'))
    package.main = './dist/index.js'
    package.files = ['dist', 'README.md']
    package.eslintConfig = eslintConfig
    package.babel = babel
    package.scripts = {}
    package.scripts['test'] = 'babel-node ./src/index.test.js | faucet'
    package.scripts['watch:test'] = 'nodemon -x \'npm test\''
    package.scripts['prebuild'] = 'npm test && rimraf dist'
    package.scripts['build'] = 'babel --ignore *.test.js --out-dir dist src'
    package.scripts['prepublish'] = 'npm run build'
    fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "

  # initial build
  npm run build
}
