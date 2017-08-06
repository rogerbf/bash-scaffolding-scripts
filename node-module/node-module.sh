node-module () {
  echo 'Enter project name:'
  read PROJECTNAME

  DIR="${BASH_SOURCE%/*}"

  mkdir $PROJECTNAME
  cd $PROJECTNAME

  cp -R $DIR/default-project-files/ .

  npm init -y

  npm install --save-dev babel-eslint babel-plugin-external-helpers babel-preset-env babel-preset-stage-3 prettier-standard rollup rollup-plugin-babel nsp

  echo '# '$PROJECTNAME >> README.md
  echo 'export default `'$PROJECTNAME'`' >> source/main.js

  node -e "
  const package = JSON.parse(fs.readFileSync('./package.json'))
  package.main = './build/' + package.name + '.cjs.js'
  package.module = './build/' + package.name + '.esm.js'
  package.files = ['build', 'README.md']
  package.scripts['build'] = 'rollup -c'
  package.scripts['prepublish'] = 'npm run lint && npm run format && nsp check && npm run build'
  package.scripts['lint'] = 'eslint source'
  package.scripts['format'] = 'prettier-standard \"source/**/*.js\"'
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}
