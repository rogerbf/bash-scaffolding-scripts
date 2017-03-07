js-safe-name () {
  local JS_SAFE_NAME=$(PROJECTNAME=$1 node -e "
    process.stdout.write(
    process.env.PROJECTNAME.replace(/-\w/g, match => match.slice(-1).toUpperCase())
    )
    ")
  echo "$JS_SAFE_NAME"
}
