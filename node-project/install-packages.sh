install-packages () {
  if (which yarn > /dev/null)
  then
    echo 'using yarn'
    yarn add $1 --dev
  else
    echo 'using npm'
    npm install --save-dev $1
  fi
}
