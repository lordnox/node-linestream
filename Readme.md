
# line-stream

Line-stream breaks any stream into seperate lines

## How to Install

    npm install line-stream

## How to use

First, require `line-stream`:

```js
var Linestream = require('line-stream');
```

Now we can parse this script and put linenumbers infront of each line, like `cat -n`  would do

```js
// libs needed for the example
var fs    = require('fs');

stream = new Linestream(fs.createReadStream(__filename));

stream.on('line', function(line, no) {
  console.log(no + ': ' + line);
});

stream.on('end', function() {
  console.log('EOF');
});

stream.on('error', function(err) {});
```

