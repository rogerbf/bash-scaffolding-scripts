eslintrc () {
  {
    echo '{'
    echo '  "parser": "babel-eslint",'
    echo '  "extends": "standard",'
    echo '  "env": {'
    echo '    "node": true'
    echo '  },'
    echo '  "parserOptions": {'
    echo '    "ecmaVersion": 2017,'
    echo '    "sourceType": "module",'
    echo '    "ecmaFeatures": {'
    echo '      "experimentalObjectRestSpread": true'
    echo '    }'
    echo '  },'
    echo '  "rules": {'
    echo '    "quotes": ['
    echo '      "warn",'
    echo '      "backtick"'
    echo '    ]'
    echo '  }'
    echo '}'
  } >> .eslintrc.json

  {
    echo 'node_modules'
    echo 'distribution'
  } >> .eslintignore
}
