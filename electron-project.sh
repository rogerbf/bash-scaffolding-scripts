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

    echo 'enter project name:'
    read PROJECTNAME

    ep_addFilesAndFolders
    ep_addGitIgnore
    npm init -y
    ep_addBabelConfig
    ep_addEslintConfig
    ep_installDependencies
    ep_configurePackageJson

    cd application
    npm init -y
    ep_configureApplicationPackageJson
    cd ..

  esac

}

ep_addFilesAndFolders () {
  mkdir $PROJECTNAME
  cd $PROJECTNAME

  mkdir source
  mkdir source/shell
  mkdir source/styles
  mkdir source/menu
  touch source/shell/shell.js

  mkdir application

  mkdir icons

  # shell.css
  {
    echo 'html, body {'
    echo 'padding: 0;'
    echo 'margin: 0;'
    echo 'user-select: none;'
    echo 'font: caption;'
    echo 'cursor: default;'
    echo '}'
  } >> source/styles/shell.css

  # shell.html
  {
    echo '<!doctype html>'
    echo '<html>'
    echo '<head>'
    echo '  <meta charset="utf-8" />'
    echo '  <title>'$PROJECTNAME'</title>'
    echo '  <script src="shell.js"></script>'
    echo '  <link rel="stylesheet" type="text/css" href="../styles/shell.css">'
    echo '</head>'
    echo '<body>'
    echo '  <h1>'$PROJECTNAME'</h1>'
    echo '  <p>happy coding!</p>'
    echo '</body>'
    echo '</html>'
  } >> source/shell/shell.html

  # core.js
  {
    echo 'import { app, BrowserWindow } from '"'electron'"
    echo 'import initializeApplicationMenu from '"'./menu/menu.js'"
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
    echo '  mainWindow = new BrowserWindow({'
    echo '    width: 800,'
    echo '    height: 600,'
    echo '    // Ubuntu shows the window icon in dock, macos & win use application icon.'
    echo '    // icon: ``,'
    echo '    // title: ``,'
    echo '    // backgroundColor: ``,'
    echo '    show: false'
    echo '  })'
    echo ''
    echo '  mainWindow.on(`ready-to-show`, () => {'
    echo '    mainWindow.show()'
    echo '    mainWindow.focus'
    echo '  })'
    echo ''
    echo '  // and load the index.html of the app.'
    echo '  mainWindow.loadURL(`file://${__dirname}/shell/shell.html`)'
    echo ''
    echo '  // Open the DevTools.'
    echo '  mainWindow.webContents.openDevTools({ detach: true })'
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
    echo 'app.on(`ready`, () => {'
    echo '  initializeApplicationMenu()'
    echo '  createWindow()'
    echo '})'
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

  {
    echo 'import { Menu } from '"'electron'"
    echo 'import development from '"'./development.js'"
    echo 'import darwin from '"'./darwin.js'"
    echo ''
    echo 'export default () => {'
    echo '  let template = []'
    echo ''
    echo '  if (process.platform === `darwin`) {'
    echo '    template = template.concat(darwin)'
    echo '  }'
    echo ''
    echo '  if (process.env.NODE_ENV === `development`) {'
    echo '    template = template.concat(development)'
    echo '  }'
    echo ''
    echo '  Menu.setApplicationMenu('
    echo '    Menu.buildFromTemplate(template)'
    echo '  )'
    echo '}'
    echo ''
  } >> source/menu/menu.js

  {
    echo 'import { BrowserWindow } from '"'electron'"
    echo ''
    echo 'export default ['
    echo '  {'
    echo '    label: `Developer`,'
    echo '    submenu: [{'
    echo '      label: `Toggle DevTools`,'
    echo '      accelerator: `CmdOrCtrl+Shift+D`,'
    echo '      click: () => {'
    echo '        BrowserWindow'
    echo '            .getFocusedWindow().webContents'
    echo '            .openDevTools({ detach: true })'
    echo '      }'
    echo '    }]'
    echo '  }'
    echo ']'
    echo ''
  } >> source/menu/development.js

  {
    echo 'import { app } from '"'electron'"
    echo ''
    echo 'export default ['
    echo '  {'
    echo '    label: `mainMenu`,'
    echo '    submenu: [{'
    echo '      label: `Quit`,'
    echo '      accelerator: `CmdOrCtrl+Q`,'
    echo '      click: () => app.quit()'
    echo '    }]'
    echo '  },'
    echo '  {'
    echo '    label: `Edit`,'
    echo '    submenu: [{'
    echo '      label: `Undo`,'
    echo '      accelerator: `CmdOrCtrl+Z`,'
    echo '      selector: `undo:`'
    echo '    }, {'
    echo '      label: `Redo`,'
    echo '      accelerator: `Shift+CmdOrCtrl+Z`,'
    echo '      selector: `redo:`'
    echo '    }, {'
    echo '      type: `separator`'
    echo '    }, {'
    echo '      label: `Cut`,'
    echo '      accelerator: `CmdOrCtrl+X`,'
    echo '      selector: `cut:`'
    echo '    }, {'
    echo '      label: `Copy`,'
    echo '      accelerator: `CmdOrCtrl+C`,'
    echo '      selector: `copy:`'
    echo '    }, {'
    echo '      label: `Paste`,'
    echo '      accelerator: `CmdOrCtrl+V`,'
    echo '      selector: `paste:`'
    echo '    }, {'
    echo '      label: `Select All`,'
    echo '      accelerator: `CmdOrCtrl+A`,'
    echo '      selector: `selectAll:`'
    echo '    }]'
    echo '  }'
    echo ']'
    echo ''
  } >> source/menu/darwin.js

}

ep_addGitIgnore () {
  {
    echo 'node_modules'
  } >> .gitignore
}

ep_addBabelConfig () {
  {
    echo '{'
    echo '  "presets": ['
    echo '    ["env", {'
    echo '      "targets": {'
    echo '        "node": 6.5'
    echo '      },'
    echo '      "loose": true,'
    echo '      "modules": "commonjs"'
    echo '    }]'
    echo '  ]'
    echo '}'
  } >> .babelrc
}

ep_addEslintConfig () {
  {
    echo '{'
    echo '  "extends": "standard",'
    echo '  "env": {'
    echo '    "node": true,'
    echo '    "browser": true'
    echo '  },'
    echo '  "parserOptions": {'
    echo '    "ecmaVersion": 6,'
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
    echo 'application'
  } >> .eslintignore
}

ep_installDependencies () {
  DEV_DEPENDENCIES_BABEL='babel-cli babel-preset-env'
  DEV_DEPENDENCIES_ESLINT='eslint eslint-config-standard eslint-plugin-promise eslint-plugin-standard'
  DEV_DEPENDENCIES_POSTCSS='postcss-cli postcss-cssnext'
  DEV_DEPENDENCIES_OTHER='electron-reload html-minifier npm-run-all onchange'

  if ($USE_YARN)
  then
    yarn add $DEV_DEPENDENCIES_BABEL $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_POSTCSS $DEV_DEPENDENCIES_OTHER --dev
    yarn add electron
  else
    npm i --save-dev $DEV_DEPENDENCIES_BABEL $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_POSTCSS $DEV_DEPENDENCIES_OTHER
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
  package.scripts['build'] = 'npm-run-all --parallel build:*'
  package.scripts['build:html'] = 'html-minifier --file-ext html --remove-comments --input-dir source --output-dir application'
  package.scripts['build:js'] = 'babel source --out-dir application'
  package.scripts['build:css'] = 'postcss --use postcss-cssnext --dir application/styles source/styles/*.css'
  package.scripts['watch:html'] = 'onchange \"source/*.html\" \"source/**/*.html\" -- npm run build:html'
  package.scripts['watch:js'] = 'onchange \"source/*.js\" \"source/**/*.js\" -- npm run build:js'
  package.scripts['watch:css'] = 'onchange \"source/styles/*.css\" -- npm run build:css'
  package.scripts['eslint:fix'] = 'eslint --fix source'

  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}

ep_configureApplicationPackageJson () {
  PROJECTNAME=$PROJECTNAME node -e "
  const fs = require('fs')

  const package = JSON.parse(fs.readFileSync('./package.json'))

  package.main = 'core.js'
  package.name = process.env.PROJECTNAME
  package.productName = process.env.PROJECTNAME
  package.copyright = ''

  delete package['scripts']

  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}
