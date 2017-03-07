gitignore () {
  {
    echo 'node_modules'
    echo 'distribution'
    echo '.DS_Store'
    echo 'package'
    echo $1'*.tgz'
    echo 'npm-debug.log'
    echo '.vscode'
  } >> .gitignore
}
