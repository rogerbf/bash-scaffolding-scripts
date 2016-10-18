webproject () {
  # check if yarn is in PATH
  if (which yarn > /dev/null)
  then
    USE_YARN=true
    echo "using yarn"
  else
    USE_YARN=false
    echo "using npm"
  fi

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
      echo ".tmp" >> .gitignore
      echo ".DS_Store" >> .gitignore
      echo "npm-debug.log" >> .gitignore

      # default folders
      mkdir "source"
      mkdir "source/js"
      mkdir "build"
      mkdir "build/production"
      mkdir "build/development"

      # index.html
      touch source/index.js
      echo "<!doctype html>" >> source/index.html
      echo "<head>" >> source/index.html
      echo "  <meta charset=\"utf-8\" />" >> source/index.html
      echo "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" >> source/index.html
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
        presets: ['es2015', 'stage-3'],
      }
      fs.writeFileSync('./.babelrc', JSON.stringify(babel, null, 2))
      "

      # dev-dependencies
      npm init -y

      BASE_DEPENDENCIES="babel-cli babel-preset-es2015 babel-preset-stage-3 rimraf mkdirp browserify rollupify babelify html-minifier uglify-js browser-sync npm-run-all onchange"

      if ($USE_YARN)
      then
        yarn add $BASE_DEPENDENCIES --dev
      else
        npm i --save-dev $BASE_DEPENDENCIES
      fi

      node -e "
      const fs = require('fs')
      const package = JSON.parse(fs.readFileSync('./package.json'))
      package.main = './source/index.js'
      package.dependencies = {}
      package.scripts['clean:development'] = 'rimraf build/development/*'
      package.scripts['clean:production'] = 'rimraf build/production/*'
      package.scripts['clean:all'] = 'npm run clean:development & npm run clean:production'
      package.scripts['server:development'] = 'npm run watch:development & browser-sync start --server build/development --files build/development --no-open --no-inject-changes'
      package.scripts['build:development'] = 'npm-run-all --parallel build:development:*'
      package.scripts['watch:development'] = 'npm-run-all --parallel watch:development:*'
      package.scripts['build:production'] = 'npm-run-all --parallel build:production:*'
      package.scripts['build:development:js'] = 'browserify --debug -t rollupify -t babelify source/index.js > build/development/bundle.js'
      package.scripts['watch:development:js'] = 'onchange \"source/*.js\" \"source/**/*.js\" -- npm run build:development:js'
      package.scripts['build:production:js'] = 'browserify -t rollupify -t babelify source/index.js | uglifyjs --mangle --compress --output build/production/bundle.js'
      package.scripts['build:development:html'] = 'html-minifier --file-ext html --input-dir source --output-dir build/development'
      package.scripts['watch:development:html'] = 'onchange \"source/*.html\" \"source/**/*.html\" -- npm run build:development:html'
      package.scripts['build:production:html'] = 'html-minifier --collapse-whitespace --remove-comments --minify-css --minify-js --file-ext html --input-dir source --output-dir build/production'
      fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
      "
    fi
    ;;
    (add)
    case $2 in
      (css)
      mkdir source/css
      touch source/index.css

      CSS_DEPENDENCIES="postcss-cli postcss-cssnext postcss-import clean-css"

      if ($USE_YARN)
      then
        yarn add $CSS_DEPENDENCIES --dev
      else
        npm i --save-dev $CSS_DEPENDENCIES
      fi

      node -e "
      const fs = require('fs')
      const package = JSON.parse(fs.readFileSync('./package.json'))
      package.scripts['build:development:css'] = 'postcss -u postcss-import -u postcss-cssnext --output build/development/bundle.css source/index.css'
      package.scripts['watch:development:css'] = 'onchange \"source/*.css\" \"source/**/*.css\" -- npm run build:development:css'
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
