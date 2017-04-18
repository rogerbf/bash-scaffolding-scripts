prettier () {
  DIR="${BASH_SOURCE%/*}"

  source $DIR/install-packages.sh

  install-packages "prettier-eslint-cli"

  node -e "
  const fs = require('fs')
  const package = JSON.parse(fs.readFileSync('./package.json'))
  package.scripts['prettier'] = 'prettier-eslint --write'
  package.scripts['prettier:all'] = 'prettier-eslint --write \"source/**/*.js\"'
  fs.writeFileSync('./package.json', JSON.stringify(package, null, 2))
  "
}
