basic-node () {

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

    JS_SAFE_NAME=$(PROJECTNAME=$PROJECTNAME node -e "
    process.stdout.write(
    process.env.PROJECTNAME.replace(/-\w/g, match => match.slice(-1).toUpperCase())
    )
    ")

    nb_addFilesAndFolders
    nb_addGitIgnore
    npm init -y
    nb_addEslintConfig
    nb_addTernConfig
    nb_installDependencies
    nb_configurePackageJson
    ;;

    (add)
    case $2 in
      (binary)
      nb_binary
      ;;

      (jest)
      nb_jest
      ;;
    esac
    ;;

  esac

}

nb_addFilesAndFolders () {
  mkdir $PROJECTNAME
  cd $PROJECTNAME

  {
    echo '# '$PROJECTNAME
    echo ''
  } >> README.md

  {
    echo 'module.exports = {}'
    echo ''
  } >> index.js
}

nb_addGitIgnore () {
  {
    echo 'node_modules'
    echo '.DS_Store'
    echo 'package'
    echo $PROJECTNAME'*.tgz'
    echo 'npm-debug.log'
  } >> .gitignore
}

nb_addEslintConfig () {
  {
    echo '{'
    echo '  "extends": "standard",'
    echo '  "env": {'
    echo '    "node": true'
    echo '  },'
    echo '  "parserOptions": {'
    echo '    "ecmaVersion": 2017'
    echo '  },'
    echo '  "rules": {'
    echo '    "quotes": ['
    echo '      "error",'
    echo '      "backtick"'
    echo '    ]'
    echo '  }'
    echo '}'
  } >> .eslintrc.json

  echo 'node_modules' >> .eslintignore
}

nb_addTernConfig () {
  {
    echo '{'
    echo '  "ecmaVersion": 7,'
    echo '  "libs": [],'
    echo '  "dontLoad": ['
    echo '    "node_modules"'
    echo '  ],'
    echo '  "plugins": {'
    echo '    "complete_strings": {'
    echo '      "maxLength": 15'
    echo '    },'
    echo '    "node": {},'
    echo '    "doc_comment": {'
    echo '      "fullDocs": true,'
    echo '      "strong": true'
    echo '    }'
    echo '  }'
    echo '}'
  } >> .tern-project
}

nb_installDependencies () {
  DEV_DEPENDENCIES_ESLINT='eslint eslint-config-standard eslint-plugin-promise eslint-plugin-standard'
  DEV_DEPENDENCIES_OTHER='chokidar-cli'

  if ($USE_YARN)
  then
    yarn add $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_OTHER --dev
  else
    npm i --save-dev $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_OTHER
  fi
}

nb_configurePackageJson () {
  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  package.dependencies = {}
  package.scripts['test'] = 'echo \'no tests\''
  package.scripts['start'] = 'node index.js'
  package.scripts['watch:start'] = 'chokidar \"*.js\" \"./**/*.js\" -c \"npm run start\"'
  package.scripts['eslint'] = 'eslint .'
  package.scripts['eslint:fix'] = 'eslint --fix .'
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}

nb_binary () {
  mkdir binary

  {
    echo '#!/usr/bin/env node'
    echo ''
  } >> binary/cli.js

  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  Object.assign(
    package,
    { binary: { [package.name]: './binary/cli.js' } }
  )
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}

nb_jest () {
  echo 'coverage' >> .gitignore
  echo 'coverage' >> .npmignore

  {
    echo 'const '"$JS_SAFE_NAME"' = require(`./index`)'
    echo ''
    echo 'test(`'"$JS_SAFE_NAME"' is defined`, () => {'
    echo '  expect('"$JS_SAFE_NAME"').toBeDefined()'
    echo '})'
  } >> index.test.js

  DEV_DEPENDENCIES_UNITTESTS="jest-cli"

  if ($USE_YARN)
  then
    yarn add $DEV_DEPENDENCIES_UNITTESTS --dev
  else
    npm i --save-dev $DEV_DEPENDENCIES_UNITTESTS
  fi

  {
    echo '{'
    echo '  "testEnvironment": "node"'
    echo '}'
  } >> .jest

  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  package.scripts['test'] = 'jest --config .jest'
  package.scripts['watch:test'] = 'jest --config .jest --watch'
  package.scripts['coverage'] = 'jest --config .jest --coverage'
  package.scripts['watch:coverage'] = 'jest --config .jest --coverage --watch'
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "

  node -e "
  const fs = require('fs')
  const eslintrc = JSON.parse(fs.readFileSync('./.eslintrc.json'))
  eslintrc.env.jest = true
  fs.writeFileSync('./.eslintrc.json', JSON.stringify(eslintrc, null, 2))
  "
}
