electron-project () {

  # prefer yarn for package installs
  if (which yarn > /dev/null)
  then
    USE_YARN=true
  else
    USE_YARN=false
  fi

  case $1 in
    (init)

    echo "enter project name:"
    read PROJECTNAME

    ep_addFilesAndFolders
    ep_addGitIgnore
    npm init -y
    ep_addBabelConfig
    ep_addEslintConfig
    ep_installDependencies
    ep_configurePackageJson

    # npm run eslint:fix

  esac

}

ep_addFilesAndFolders () {
  mkdir $PROJECTNAME
  cd $PROJECTNAME

  mkdir source
  mkdir application

  touch source/shell.css
  touch source/shell.js

  # shell.html
  {
    echo '<!doctype html>'
    echo '<html>'
    echo '<head>'
    echo '  <meta charset="utf-8" />'
    echo '  <title>'$PROJECTNAME'</title>'
    echo '  <script src="shell.js"></script>'
    echo '  <link rel="stylesheet" type="text/css" href="shell.css">'
    echo '</head>'
    echo '<body>'
    echo '  <h1>'$PROJECTNAME'</h1>'
    echo '</body>'
    echo '</html>'
  } >> source/shell.html

  # core.js
  {
    echo 'import { app, BrowserWindow } from "electron"'
    echo ''
    echo 'if (process.env.NODE_ENV === `development`) {'
    echo '  require(`electron-reload`)(__dirname)'
    echo '}'
    echo '// Keep a global reference of the window object, if you don`t, the window will'
    echo '// be closed automatically when the JavaScript object is garbage collected.'
    echo 'let mainWindow'
    echo ''
    echo 'function createWindow () {'
    echo '  // Create the browser window.'
    echo '  mainWindow = new BrowserWindow({width: 800, height: 600})'
    echo ''
    echo '  // and load the index.html of the app.'
    echo '  mainWindow.loadURL(`file://${__dirname}/shell.html`)'
    echo ''
    echo '  // Open the DevTools.'
    echo '  mainWindow.webContents.openDevTools({ mode : `undocked` })'
    echo ''
    echo '  // Emitted when the window is closed.'
    echo '  mainWindow.on(`closed`, () => {'
    echo '    // Dereference the window object, usually you would store windows'
    echo '    // in an array if your app supports multi windows, this is the time'
    echo '    // when you should delete the corresponding element.'
    echo '    mainWindow = null'
    echo '  })'
    echo '}'
    echo ''
    echo '// This method will be called when Electron has finished'
    echo '// initialization and is ready to create browser windows.'
    echo '// Some APIs can only be used after this event occurs.'
    echo 'app.on(`ready`, createWindow)'
    echo ''
    echo '// Quit when all windows are closed.'
    echo 'app.on(`window-all-closed`, () => {'
    echo '  // On OS X it is common for applications and their menu bar'
    echo '  // to stay active until the user quits explicitly with Cmd + Q'
    echo '  if (process.platform !== `darwin`) {'
    echo '    app.quit()'
    echo '  }'
    echo '})'
    echo ''
    echo 'app.on(`activate`, () => {'
    echo '  // On OS X its common to re-create a window in the app when the'
    echo '  // dock icon is clicked and there are no other windows open.'
    echo '  if (mainWindow === null) {'
    echo '    createWindow()'
    echo '  }'
    echo '})'
    echo ''

  } >> source/core.js

}

ep_addGitIgnore () {
  {
    echo "node_modules"
    echo "yarn.lock"
  } >> .gitignore
}

ep_addBabelConfig () {
  {
    echo "{"
    echo "  \"presets\": ["
    echo "    [\"env\", {"
    echo "      \"targets\": {"
    echo "        \"node\": 6.5"
    echo "      },"
    echo "      \"loose\": true,"
    echo "      \"modules\": \"commonjs\""
    echo "    }]"
    echo "  ]"
    echo "}"
  } >> .babelrc
}

ep_addEslintConfig () {
  {
    echo "{"
    echo "  \"extends\": \"standard\","
    echo "  \"env\": {"
    echo "    \"node\": true,"
    echo "    \"browser\": true"
    echo "  },"
    echo "  \"parserOptions\": {"
    echo "    \"ecmaVersion\": 6,"
    echo "    \"sourceType\": \"module\","
    echo "    \"ecmaFeatures\": {"
    echo "      \"experimentalObjectRestSpread\": true"
    echo "    }"
    echo "  },"
    echo "  \"rules\": {"
    echo "    \"quotes\": ["
    echo "      \"error\","
    echo "      \"backtick\""
    echo "    ]"
    echo "  }"
    echo "}"
  } >> .eslintrc.json

  {
    echo "application"
  } >> .eslintignore
}

ep_installDependencies () {
  DEV_DEPENDENCIES_BABEL="babel-cli babel-preset-env"
  DEV_DEPENDENCIES_ESLINT="eslint eslint-config-standard eslint-plugin-promise eslint-plugin-standard"
  DEV_DEPENDENCIES_OTHER="electron-reload html-minifier npm-run-all onchange"

  if ($USE_YARN)
  then
    yarn add $DEV_DEPENDENCIES_BABEL $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_OTHER --dev
    yarn add electron
  else
    npm i --save-dev $DEV_DEPENDENCIES_BABEL $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_OTHER
    npm i --save electron
  fi
}

ep_configurePackageJson () {
  node -e "
  const fs = require('fs')

  const package = JSON.parse(fs.readFileSync('./package.json'))

  package.main = 'application/core.js'

  package.scripts['start'] = 'npm run build && electron .'
  package.scripts['start:watch'] = 'NODE_ENV=development npm-run-all --parallel start watch'
  package.scripts['watch'] = 'npm-run-all --parallel watch:*'
  package.scripts['build'] = 'npm run html-minifier & npm run babel'
  package.scripts['html-minifier'] = 'html-minifier --file-ext html --remove-comments --input-dir source --output-dir application'
  package.scripts['babel'] = 'babel source --out-dir application'
  package.scripts['eslint:fix'] = 'eslint --fix source'
  package.scripts['watch:html'] = 'onchange \"source/*.html\" \"source/**/*.html\" -- npm run html-minifier'
  package.scripts['watch:js'] = 'onchange \"source/*.js\" \"source/**/*.js\" -- npm run babel'

  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}
