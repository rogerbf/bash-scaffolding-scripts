babelrc () {
  {
    echo '{'
    echo '  "presets": ['
    echo '    "stage-3",'
    echo '    ['
    echo '      "env",'
    echo '      {'
    echo '        "targets": {'
    echo '          "node": "current"'
    echo '        }'
    echo '      }'
    echo '    ]'
    echo '  ],'
    echo '  "plugins": ['
    echo '    "add-module-exports"'
    echo '  ],'
    echo '  "env": {'
    echo '    "production": {'
    echo '      "ignore": ['
    echo '        "*.test.*"'
    echo '      ],'
    echo '      "comments": false'
    echo '    }'
    echo '  }'
    echo '}'
  } >> .babelrc
}
