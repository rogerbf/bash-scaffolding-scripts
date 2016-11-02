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
    ep_addTernConfig
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
  mkdir source/mainWindow
  mkdir source/styles
  mkdir source/menu
  touch source/mainWindow/mainWindow.js

  mkdir application

  mkdir distribution
  mkdir distribution/assets

  # mainWindow.css
  {
    echo 'html, body {'
    echo '  padding: 0;'
    echo '  margin: 0;'
    echo '  user-select: none;'
    echo '  font: caption;'
    echo '  cursor: default;'
    echo '}'
  } >> source/styles/mainWindow.css

  # mainWindow.html
  {
    echo '<!doctype html>'
    echo '<html>'
    echo '<head>'
    echo '  <meta charset="utf-8" />'
    echo '  <title>'$PROJECTNAME'</title>'
    echo '  <link rel="stylesheet" type="text/css" href="../styles/mainWindow.css">'
    echo '  <script src="mainWindow.js"></script>'
    echo '</head>'
    echo '<body>'
    echo '  <h1>'$PROJECTNAME'</h1>'
    echo '  <p>happy coding!</p>'
    echo '</body>'
    echo '</html>'
  } >> source/mainWindow/mainWindow.html

  # mainWindow.js
  {
    echo 'const start = () => {'
    echo '  console.log(`dom loaded`)'
    echo '}'
    echo ''
    echo 'window.addEventListener(`load`, start)'
    echo ''
  } >> source/mainWindow/mainWindow.js

  # core.js
  {
    echo 'import { app, BrowserWindow } from '"'electron'"
    echo 'import initializeApplicationMenu from '"'./menu/menu.js'"
    echo ''
    echo 'if (process.env.NODE_ENV === `development`) {'
    echo '  require(`electron-reload`)(__dirname)'
    echo '}'
    echo ''
    echo '// Keep a global reference of the window object, if you don`t, the window will'
    echo '// be closed automatically when the JavaScript object is garbage collected.'
    echo 'let mainWindow'
    echo ''
    echo 'function createMainWindow () {'
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
    echo '  mainWindow.loadURL(`file://${__dirname}/mainWindow/mainWindow.html`)'
    echo ''
    echo '  // Open the DevTools.'
    echo '  if (process.env.NODE_ENV === `development`) {'
    echo '    mainWindow.webContents.openDevTools({ detach: true })'
    echo '  }'
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
    echo '  createMainWindow()'
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
    echo '    createMainWindow()'
    echo '  }'
    echo '})'
    echo ''
  } >> source/core.js

  # menu/menu.js
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

  # menu/development.js
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

  # menu/darwin.js
  {
    echo 'import { app } from '"'electron'"
    echo ''
    echo 'export default ['
    echo '  {'
    echo '    label: app.getName(),'
    echo '    submenu: ['
    echo '      {'
    echo '        role: `about`'
    echo '      },'
    echo '      {'
    echo '        type: `separator`'
    echo '      },'
    echo '      {'
    echo '        role: `services`,'
    echo '        submenu: []'
    echo '      },'
    echo '      {'
    echo '        type: `separator`'
    echo '      },'
    echo '      {'
    echo '        role: `hide`'
    echo '      },'
    echo '      {'
    echo '        role: `hideothers`'
    echo '      },'
    echo '      {'
    echo '        role: `unhide`'
    echo '      },'
    echo '      {'
    echo '        type: `separator`'
    echo '      },'
    echo '      {'
    echo '        role: `quit`'
    echo '      }'
    echo '    ]'
    echo '  },'
    echo '  {'
    echo '    label: `Edit`,'
    echo '    submenu: ['
    echo '      {'
    echo '        label: `Undo`,'
    echo '        accelerator: `CmdOrCtrl+Z`,'
    echo '        selector: `undo:`'
    echo '      }, {'
    echo '        label: `Redo`,'
    echo '        accelerator: `Shift+CmdOrCtrl+Z`,'
    echo '        selector: `redo:`'
    echo '      }, {'
    echo '        type: `separator`'
    echo '      }, {'
    echo '        label: `Cut`,'
    echo '        accelerator: `CmdOrCtrl+X`,'
    echo '        selector: `cut:`'
    echo '      }, {'
    echo '        label: `Copy`,'
    echo '        accelerator: `CmdOrCtrl+C`,'
    echo '        selector: `copy:`'
    echo '      }, {'
    echo '        label: `Paste`,'
    echo '        accelerator: `CmdOrCtrl+V`,'
    echo '        selector: `paste:`'
    echo '      }, {'
    echo '        label: `Select All`,'
    echo '        accelerator: `CmdOrCtrl+A`,'
    echo '        selector: `selectAll:`'
    echo '      }'
    echo '    ]'
    echo '  },'
    echo '  {'
    echo '    role: `window`,'
    echo '    submenu: ['
    echo '      {'
    echo '        label: `Close`,'
    echo '        accelerator: `CmdOrCtrl+W`,'
    echo '        role: `close`'
    echo '      },'
    echo '      {'
    echo '        label: `Minimize`,'
    echo '        accelerator: `CmdOrCtrl+M`,'
    echo '        role: `minimize`'
    echo '      },'
    echo '      {'
    echo '        label: `Zoom`,'
    echo '        role: `zoom`'
    echo '      },'
    echo '      {'
    echo '        type: `separator`'
    echo '      },'
    echo '      {'
    echo '        label: `Bring All to Front`,'
    echo '        role: `front`'
    echo '      }'
    echo '    ]'
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
    echo '  ],'
    echo '  "comments": false'
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
    echo 'application'
  } >> .eslintignore
}

ep_addTernConfig () {
  {
    echo '{'
    echo '  "ecmaVersion": 7,'
    echo '  "libs": ['
    echo '    "browser"'
    echo '  ],'
    echo '  "loadEagerly": ['
    echo '    "source"'
    echo '  ],'
    echo '  "dontLoad": ['
    echo '    "application",'
    echo '    "distribution"'
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

ep_installDependencies () {
  DEV_DEPENDENCIES_ELECTRON='electron electron-builder electron-reload'
  DEV_DEPENDENCIES_BABEL='babel-cli babel-preset-env'
  DEV_DEPENDENCIES_ESLINT='eslint eslint-config-standard eslint-plugin-promise eslint-plugin-standard'
  DEV_DEPENDENCIES_POSTCSS='postcss-cli postcss-cssnext'
  DEV_DEPENDENCIES_OTHER='html-minifier npm-run-all onchange'

  if ($USE_YARN)
  then
    yarn add $DEV_DEPENDENCIES_ELECTRON $DEV_DEPENDENCIES_BABEL $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_POSTCSS $DEV_DEPENDENCIES_OTHER --dev
  else
    npm i --save-dev $DEV_DEPENDENCIES_ELECTRON $DEV_DEPENDENCIES_BABEL $DEV_DEPENDENCIES_ESLINT $DEV_DEPENDENCIES_POSTCSS $DEV_DEPENDENCIES_OTHER
  fi
}

ep_configurePackageJson () {
  PROJECTNAME=$PROJECTNAME node -e "
  const fs = require('fs')

  const package = JSON.parse(fs.readFileSync('./package.json'))

  package.main = 'application/core.js'

  package.scripts['start'] = 'npm run build && electron .'
  package.scripts['start:development'] = 'npm run build && NODE_ENV=development electron .'
  package.scripts['start:development:watch'] = 'NODE_ENV=development npm-run-all --parallel start watch'
  package.scripts['watch'] = 'npm-run-all --parallel watch:*'
  package.scripts['build'] = 'npm-run-all --parallel build:*'
  package.scripts['eslint:fix'] = 'eslint --fix source'
  package.scripts['build:html'] = 'html-minifier --file-ext html --remove-comments --input-dir source --output-dir application'
  package.scripts['build:js'] = 'babel source --out-dir application'
  package.scripts['build:css'] = 'postcss --use postcss-cssnext --dir application/styles source/styles/*.css'
  package.scripts['watch:html'] = 'onchange \"source/*.html\" \"source/**/*.html\" -- npm run build:html'
  package.scripts['watch:js'] = 'onchange \"source/*.js\" \"source/**/*.js\" -- npm run build:js'
  package.scripts['watch:css'] = 'onchange \"source/styles/*.css\" -- npm run build:css'
  package.scripts['release:macos'] = 'npm run build && build --macos'
  package.scripts['release:windows'] = 'npm run build && build --windows --ia32 --x64'
  package.scripts['release:all'] = 'npm run build && build --macos --windows --ia32 --x64'

  const directories = {
    buildResources: 'distribution/assets',
    output: 'distribution/releases',
    app: 'application'
  }

  const build = {
    appId: 'com.example.' + process.env.PROJECTNAME,
    mac: {
      'app-category-type': 'application.category',
      'target': ['zip', 'dmg']
    },
    win: {
      target: [
        'nsis'
      ]
    }
  }

  package.directories = directories
  package.build = build

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
  package.description = 'application description'
  package.homepage = ''
  package.copyright = ''

  delete package['scripts']

  const sortedPackage = Object.keys(package).sort().reduce(
  (acc, key) => {
      return Object.assign(acc, { [key]: package[key] })
    }, {}
  )

  fs.writeFileSync('./package.json', JSON.stringify(sortedPackage, null, 2))
  "
}
