nodeproject () {
  case $1 in
    (create)
    if !([ -z "$2" ]); then
      PROJECTNAME=$2
      mkdir $PROJECTNAME
      cd $PROJECTNAME

      # README.md
      echo "# "$PROJECTNAME >> README.md

      # .gitignore
      echo "node_modules" >> .gitignore
      echo "dist" >> .gitignore
      echo ".DS_Store" >> .gitignore
      echo "package" >> .gitignore
      echo $PROJECTNAME"*.tgz" >> .gitignore
      echo "npm-debug.log" >> .gitignore

      # default files & folders
      mkdir src
      echo "module.exports = {}" >> src/index.js

      # package.json
      npm init -y
      npm i --save-dev babel-cli babel-preset-es2015 rimraf
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
      package.scripts['test'] = 'echo \'tests not available\''
      package.scripts['prebuild'] = 'npm test && rimraf dist'
      package.scripts['build'] = 'babel --ignore *.test.js --out-dir dist src'
      package.scripts['prepublish'] = 'npm run build'
      fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
      "

      # initial build
      npm run build
    fi
    ;;
    (add)
    case $2 in
      (tests)
      # index.test.js
      echo "const test = require('tape')" >> src/index.test.js
      echo "" >> src/index.test.js
      echo "test('A passing test.', assert => {" >> src/index.test.js
      echo "  assert.pass('This test will pass.')" >> src/index.test.js
      echo "  assert.end()" >> src/index.test.js
      echo "})" >> src/index.test.js

      # package.json
      npm i --save-dev faucet nodemon tape
      node -e "
      const fs = require('fs')
      const package = JSON.parse(fs.readFileSync('./package.json'))
      package.scripts['test'] = 'babel-node ./src/index.test.js | faucet'
      package.scripts['watch:test'] = 'nodemon -x \'npm test\''
      fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
      "
      ;;
    esac
    ;;
  esac
}
