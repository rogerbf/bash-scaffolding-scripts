web-project () {
  DIR="${BASH_SOURCE%/*}"

  case $1 in

    (init)
    echo 'project name:'
    read PROJECTNAME

    mkdir $PROJECTNAME
    cd $PROJECTNAME
    echo '# '$PROJECTNAME >> README.md
    cp -R $DIR/files/*.* .
    npm init -y
    npm install --save-dev babel-eslint babel-plugin-external-helpers babel-preset-env babel-preset-stage-3 budo chokidar-cli cross-env cssnano eslint eslint-config-standard eslint-plugin-compat eslint-plugin-html eslint-plugin-import eslint-plugin-node eslint-plugin-promise eslint-plugin-standard html-minifier postcss-cssnext postcss-import rollup rollup-plugin-babel rollup-plugin-commonjs rollup-plugin-execute rollup-plugin-node-resolve rollup-plugin-postcss rollup-plugin-replace rollup-plugin-uglify
    node -e "
    const fs = require('fs')
    const package = JSON.parse(fs.readFileSync('./package.json'))
    package.main = './build/bundle.js'
    package.scripts['linter'] = 'eslint .'
    package.scripts['linter:fix'] = 'eslint --fix .'
    package.scripts['build'] = 'rollup --config'
    package.scripts['build:production'] = 'cross-env NODE_ENV=production npm run build'
    package.scripts['watch'] = 'chokidar \"source\" -c \"npm run build\"'
    package.scripts['serve'] = 'npm run watch & budo --live --dir build'
    fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
    "
    ;;

  esac
}
