webproject () {
  case $1 in
    (init)
    if !([ -z "$2" ]); then
      PROJECTNAME=$2
      echo $PROJECTNAME
      mkdir $PROJECTNAME
      cd $PROJECTNAME

      # .gitignore
      echo "node_modules" >> .gitignore
      echo "build" >> .gitignore
      echo ".DS_Store" >> .gitignore
      echo "npm-debug.log" >> .gitignore

      # default folders
      mkdir "source"
      mkdir "build"

      # index.html
      touch source/index.js
      echo "<!doctype html>" >> source/index.html
      echo "<head>" >> source/index.html
      echo "  <meta charset=\"utf-8\" />" >> source/index.html
      echo "  <title>$PROJECTNAME</title>" >> source/index.html
      echo "  <script src=\"bundle.js\"></script>" >> source/index.html
      echo "</head>" >> source/index.html

      # .eslintrc.json
      node -e "
      const fs = require('fs')
      const eslintConfig = {
        env: {
          browser: true,
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

      # .eslintignore
      echo "build" >> .eslintignore

      # .babelrc
      node -e "
      const fs = require('fs')
      const babel = {
        presets: [['es2015', { modules: false }], 'stage-3'],
      }
      fs.writeFileSync('./.babelrc', JSON.stringify(babel, null, 2))
      "

      # dev-dependencies
      npm init -y
      npm i --save-dev babel-cli babel-preset-es2015 babel-preset-stage-3 rimraf mkdirp html-minifier rollup uglify-js browser-sync npm-run-all

      node -e "
      const fs = require('fs')
      const package = JSON.parse(fs.readFileSync('./package.json'))
      package.main = './source/index.js'
      package.dependencies = {}
      package.scripts['clean:development'] = 'rimraf build/development'
      package.scripts['clean:production'] = 'rimraf build/production'
      package.scripts['clean:all'] = 'npm-run-all clean:development clean:production'
      package.scripts['babel'] = 'rimraf build/.babel && mkdirp build/.babel && babel --out-dir build/.babel source'
      package.scripts['build:development'] = 'npm-run-all --parallel build:development:*'
      package.scripts['build:production'] = 'npm-run-all --parallel build:production:*'
      package.scripts['build:development:js'] = 'npm run babel && rollup --sourcemap inline --output build/development/bundle.js build/.babel/index.js'
      package.scripts['build:production:js'] = 'npm run babel && mkdirp build/production && rollup build/.babel/index.js | uglifyjs --mangle --compress --output build/production/bundle.js && rimraf build/.babel-output'
      package.scripts['build:development:html'] = 'html-minifier --file-ext html --input-dir source --output-dir build/development'
      package.scripts['build:production:html'] = 'html-minifier --collapse-whitespace --remove-comments --minify-css --file-ext html --input-dir source --output-dir build/production'
      package.scripts['server:development'] = 'browser-sync start --server build/development --files build/development --no-open'
      fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
      "
    fi
    ;;
    (add)
    case $2 in
      (css)
      mkdir source/styles
      touch source/index.css
      npm i --save-dev postcss-cli postcss-cssnext postcss-import clean-css
      node -e "
      const fs = require('fs')
      const package = JSON.parse(fs.readFileSync('./package.json'))
      package.scripts['build:development:css'] = 'postcss -u postcss-import -u postcss-cssnext -o build/development/bundle.css source/index.css'
      package.scripts['build:production:css'] = 'postcss -u postcss-import -u postcss-cssnext source/index.css | cleancss --output build/production/bundle.css'
      fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))

      fs.writeFileSync(
        './source/index.html',
        fs.readFileSync('./source/index.html', 'utf-8')
          .split('\n')
          .reduceRight((acc, curr) => {
            if (/\/head/.test(curr)) {
              return [
                ...acc,
                curr,
                '  <link rel=\"stylesheet\" type=\"text/css\" href=\"bundle.css\">'
              ]
            } else {
              return [ ...acc, curr ]
            }
          }, [])
          .reverse()
          .join('\n')
      )
      "
      ;;
    esac
  esac
}
