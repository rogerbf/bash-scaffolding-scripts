# project scaffolding scripts

## Node.js scaffolding

Initialize a new Node.js project with transpilation provided by Babel using babel-preset-es2015:

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
