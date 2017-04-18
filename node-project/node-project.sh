node-project () {
  DIR="${BASH_SOURCE%/*}"

  case $1 in

    (init)
    echo 'project name:'
    read PROJECTNAME

    source $DIR/folders.sh $PROJECTNAME
    source $DIR/index.sh
    source $DIR/readme.sh
    source $DIR/gitignore.sh
    source $DIR/babelrc.sh
    source $DIR/eslintrc.sh
    source $DIR/tern-project.sh
    source $DIR/dependencies.sh
    source $DIR/install-packages.sh
    source $DIR/package-json.sh

    folders $PROJECTNAME
    cd $PROJECTNAME
    index
    readme $PROJECTNAME
    gitignore $PROJECTNAME
    babelrc
    eslintrc
    tern-project
    npm init -y
    install-packages "$DEFAULT_DEPENDENCIES"
    package-json
    ;;

    (add)
    case $2 in

      (binary)
      echo 'adding binary'
      source $DIR/binary.sh
      binary
      echo 'done'
      ;;

      (jest)
      echo 'adding jest'
      source $DIR/jest.sh
      jest
      echo 'done'
      ;;

      (prettier)
      echo 'adding prettier'
      source $DIR/prettier.sh
      prettier
      echo 'done'

    esac
    ;;

  esac
}
