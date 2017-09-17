node-app () {
  echo 'Project name:'
  read PROJECTNAME

  echo 'Authors full name:'
  read AUTHOR

  DIR="${BASH_SOURCE%/*}"

  mkdir $PROJECTNAME
  cd $PROJECTNAME

  cp -R $DIR/default-project-files/ .

  npm init -y

  ESLINT="babel-eslint eslint-config-standard eslint-plugin-standard eslint-plugin-promise eslint-plugin-import eslint-plugin-node"
  BABEL="babel-cli babel-plugin-add-module-exports babel-preset-env babel-preset-stage-3 babel-plugin-dynamic-import-node"
  OTHER="nsp prettier-standard"

  npm install --save-dev $ESLINT $BABEL $OTHER

  echo '# '$PROJECTNAME >> README.md
  echo 'export default `'$PROJECTNAME'`' >> source/index.js

  node -e "
  const package = JSON.parse(fs.readFileSync('./package.json'))
  package.main = 'build/index.js'
  package.module = 'source/index.js'
  package.files = [ 'LICENSE', 'README.md', 'source', 'build' ]
  package.scripts['build'] = 'babel source --out-dir build'
  package.scripts['prepublish'] = 'npm run format && npm run lint && nsp check && npm run build'
  package.scripts['lint'] = 'eslint source'
  package.scripts['format'] = 'prettier-standard \"source/**/*.js\"'
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "

  AUTHOR=$AUTHOR node -e "
  fs.writeFileSync(
    './LICENSE',
    fs.readFileSync('./LICENSE', 'utf8')
      .replace('[fullname]', process.env.AUTHOR)
      .replace('[year]', (new Date()).getFullYear())
  )
  "
}
