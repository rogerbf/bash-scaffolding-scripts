node-project () {

  # prefer yarn for package installs
  if (which yarn > /dev/null)
  then
    USE_YARN=true
  else
    USE_YARN=false
  fi

  case $1 in
    (init)
    echo 'enter project name:'
    read PROJECTNAME

    np_addFilesAndFolders
    np_addGitIgnore
    npm init -y
    np_addBabelConfig
    np_addEslintConfig
    np_addTernConfig
    np_installDependencies
    np_configurePackageJson
    ;;

    (add)
    case $2 in
      (unittesting)
      np_unittesting
      ;;

      (binary)
      np_binary
      ;;

      (coverage)
      np_coverage
      ;;
    esac
    ;;

  esac

}

np_addFilesAndFolders () {
  mkdir $PROJECTNAME
  cd $PROJECTNAME
  mkdir source
  mkdir distribution

  {
    echo '# '$PROJECTNAME
    echo ''
  } >> README.md

  {
    echo 'export default {}'
    echo ''
  } >> source/index.js
}

np_addGitIgnore () {
  {
    echo 'node_modules'
    echo 'distribution'
    echo '.DS_Store'
    echo 'package'
    echo $PROJECTNAME'*.tgz'
    echo 'npm-debug.log'
  } >> .gitignore
}

np_addBabelConfig () {
  {
    echo '{'
    echo '  "presets": ['
    echo '    "latest",'
    echo '    "stage-3"'
    echo '  ],'
    echo '  "plugins": ['
    echo '    "add-module-exports"'
    echo '  ],'
    echo '  "env": {'
    echo '    "production": {'
    echo '      "ignore": ['
    echo '        "*.test.*"'
    echo '      ],'
    echo '      "comments": false'
    echo '    }'
    echo '  }'
    echo '}'
  } >> .babelrc
}

np_addEslintConfig () {
  {
    echo '{'
    echo '  "extends": "standard",'
    echo '  "env": {'
    echo '    "node": true'
    echo '  },'
    echo '  "parserOptions": {'
    echo '    "ecmaVersion": 2017,'
    echo '    "sourceType": "module",'
    echo '    "ecmaFeatures": {'
    echo '      "experimentalObjectRestSpread": true'
    echo '    }'
    echo '  },'
    echo '  "rules": {'
    echo '    "quotes": ['
    echo '      "error",'
    echo '      "backtick"'
    echo '    ]'
    echo '  }'
    echo '}'
  } >> .eslintrc.json

  {
    echo 'node_modules'
    echo 'distribution'
  } >> .eslintignore
}

np_addTernConfig () {
  {
    echo '{'
    echo '  "ecmaVersion": 7,'
    echo '  "libs": [],'
    echo '  "loadEagerly": ['
    echo '    "source"'
    echo '  ],'
    echo '  "dontLoad": ['
    echo '    "distribution",'
    echo '    "node_modules"'
    echo '  ],'
    echo '  "plugins": {'
    echo '    "complete_strings": {'
    echo '      "maxLength": 15'
    echo '    },'
    echo '    "node": {},'
    echo '    "es_modules": {},'
    echo '    "doc_comment": {'
    echo '      "fullDocs": true,'
    echo '      "strong": true'
    echo '    }'
    echo '  }'
    echo '}'
  } >> .tern-project
}

np_installDependencies () {
  DEV_DEPENDENCIES_BABEL='babel-cli babel-preset-latest babel-preset-stage-3 babel-plugin-add-module-exports'
  DEV_DEPENDENCIES_ESLINT='eslint eslint-config-standard eslint-plugin-promise eslint-plugin-standard'
  DEV_DEPENDENCIES_OTHER='rimraf onchange cross-env nsp'

  if ($USE_YARN)
  then
    yarn add $DEV_DEPENDENCIES_BABEL $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_OTHER --dev
  else
    npm i --save-dev $DEV_DEPENDENCIES_BABEL $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_OTHER
  fi
}

np_configurePackageJson () {
  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  package.main = './distribution/index.js'
  package.files = ['distribution', 'README.md']
  package.dependencies = {}
  package.scripts['test'] = 'echo \'no tests\''
  package.scripts['prebuild'] = 'npm test && rimraf distribution'
  package.scripts['build'] = 'cross-env BABEL_ENV=production babel --out-dir distribution source'
  package.scripts['prepublish'] = 'npm run nsp && npm run test && npm run build'
  package.scripts['start'] = 'npm run build && node ./distribution/index.js'
  package.scripts['watch:start'] = 'onchange source/*.js source/**/*.js -- npm run start'
  package.scripts['eslint'] = 'eslint source'
  package.scripts['eslint:fix'] = 'eslint --fix source'
  package.scripts['repl'] = 'npm run build && babel-node'
  package.scripts['nsp'] = 'nsp check'
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}

np_unittesting () {
  mkdir source/test

  {
    echo 'import test from '"'tape'"
    echo 'import '"$PROJECTNAME"' from '"'../index'"
    echo ''
    echo 'test(`'"$PROJECTNAME"'`, assert => {'
    echo '  assert.ok('"$PROJECTNAME"', `exports something`)'
    echo '  assert.end()'
    echo '})'
    echo ''
  } >> source/test/index.test.js

  DEV_DEPENDENCIES_UNITTESTS="tape tap-dot"

  if ($USE_YARN)
  then
    yarn add $DEV_DEPENDENCIES_UNITTESTS --dev
  else
    npm i --save-dev $DEV_DEPENDENCIES_UNITTESTS
  fi

  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  package.scripts['test'] = 'tape -r babel-register ./source/**/*.test.js | tap-dot'
  package.scripts['watch:test'] = 'onchange source/*.js source/**/*.js -- npm run test'
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}

np_binary () {
  mkdir source/binary

  {
    echo '#!/usr/bin/env node'
    echo ''
  } >> source/binary/cli.js

  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  Object.assign(
    package,
    { binary: { [package.name]: './distribution/binary/cli.js' } }
  )
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}

np_coverage () {
  DEV_DEPENDENCIES_COVERAGE="nyc"

  if ($USE_YARN)
  then
    yarn add $DEV_DEPENDENCIES_COVERAGE --dev
  else
    npm i --save-dev $DEV_DEPENDENCIES_COVERAGE
  fi

  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  package.scripts['test:coverage'] = 'nyc --reporter=lcov --require babel-register npm test && nyc report'
  package.scripts['watch:test:coverage'] = 'onchange source/*.js source/**/*.js -- npm run test:coverage'
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "

  {
    echo '.nyc_output'
    echo 'coverage'
  } >> .gitignore
}
