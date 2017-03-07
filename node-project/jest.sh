jest () {
  DIR="${BASH_SOURCE%/*}"

  source $DIR/dependencies.sh
  source $DIR/install-packages.sh

  install-packages "$JEST_DEPENDENCIES"

  echo 'coverage' >> .gitignore

  source $DIR/package-name.sh
  source $DIR/js-safe-name.sh

  PACKAGENAME=$(package-name)
  SAFENAME=$(js-safe-name $PACKAGENAME)

  {
    echo 'import '"$SAFENAME"' from '"'./index'"
    echo ''
    echo 'test(`'"$SAFENAME"' is defined`, () => {'
    echo '  expect('"$SAFENAME"').toBeDefined()'
    echo '})'
  } >> source/index.test.js

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
