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
      echo "export default {}" >> src/index.js

      # .eslintrc.json
      node -e "
      const fs = require('fs')
      const eslintConfig = {
        env: {
          node: true,
        },
        parserOptions: {
          ecmaVersion: 6,
          sourceType: 'module',
          ecmaFeatures: {
            experimentalObjectRestSpread: true
          }
        },
        rules: {
          quotes: ['error', 'backtick']
        }
      }
      fs.writeFileSync('./.eslintrc.json', JSON.stringify(eslintConfig, null, 2))
      "
      echo "dist" >> .eslintignore

      # .babelrc
      node -e "
      const fs = require('fs')
      const babel = {
        presets: ['es2015'],
        plugins: ['transform-es2015-destructuring', 'transform-object-rest-spread', 'add-module-exports']
      }
      fs.writeFileSync('./.babelrc', JSON.stringify(babel, null, 2))
      "

      # package.json
      npm init -y
      npm i --save-dev babel-cli babel-preset-es2015 babel-plugin-transform-es2015-destructuring babel-plugin-transform-object-rest-spread babel-plugin-add-module-exports rimraf nodemon eslint
      node -e "
      const fs = require('fs')
      const package = JSON.parse(fs.readFileSync('./package.json'))
      package.main = './dist/index.js'
      package.files = ['dist', 'README.md']
      package.dependencies = {}
      package.scripts['test'] = 'echo \'no tests\''
      package.scripts['prebuild'] = 'npm test && rimraf dist'
      package.scripts['build'] = 'babel --ignore *.test.* --out-dir dist src'
      package.scripts['prepublish'] = 'npm run build'
      package.scripts['start'] = 'npm run build && node ./dist/index.js'
      package.scripts['start:watch'] = 'nodemon --watch src -x npm run start'
      package.scripts['eslint:fix'] = 'eslint --fix src'
      fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
      "

      # initial build
      npm run build
    fi
    ;;
    (add)
    case $2 in
      (tests)
      mkdir src/tests
      # index.test.js
      echo "import test from 'tape'" >> src/tests/index.test.js
      echo "import app from '../index.js'" >> src/tests/index.test.js
      echo "" >> src/tests/index.test.js
      echo "test(\`A passing test.\`, assert => {" >> src/tests/index.test.js
      echo "  assert.pass(\`This test will pass.\`)" >> src/tests/index.test.js
      echo "  assert.end()" >> src/tests/index.test.js
      echo "})" >> src/tests/index.test.js

      # package.json
      npm i --save-dev tap-dot nodemon tape
      node -e "
      const fs = require('fs')
      const package = JSON.parse(fs.readFileSync('./package.json'))
      package.scripts['test'] = 'tape -r babel-register ./src/tests/*.js | tap-dot'
      package.scripts['watch:test'] = 'nodemon -x \'npm test\''
      fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
      "
      ;;

      (binary)
      # files & folders
      mkdir src/bin
      echo "#!/usr/bin/env node" >> src/bin/cli.js

      # package.json
      node -e "
      const fs = require('fs')
      const package = JSON.parse(fs.readFileSync('./package.json'))
      const bin = {}
      bin[package.name] = './dist/bin/cli.js'
      package.bin = bin
      fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
      "
      ;;
    esac
    ;;
  esac
}
