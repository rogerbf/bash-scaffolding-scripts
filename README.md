# project scaffolding scripts

## Node.js scaffolding

Initialize a new Node.js project with transpilation provided by Babel using babel-preset-es2015, babel-plugin-transform-es2015-destructuring, babel-plugin-transform-object-rest-spread:

``` bash
nodeproject create [PROJECTNAME]

npm run build
```

Add unit test suite:

``` bash
nodeproject add tests

npm test

npm run watch:test
```

Add binary:

``` bash
nodeproject add binary
```

## initialize a web project

`webproject create [PROJECTNAME]`
