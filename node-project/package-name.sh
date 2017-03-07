package-name () {
  local PACKAGENAME=$(node -e "
  const package = require('fs').readFileSync('./package.json')
  process.stdout.write(JSON.parse(package).name)
  ")
  echo $PACKAGENAME
}
