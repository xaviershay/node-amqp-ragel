require.paths.unshift('build/default');
parser = require('hello');
process.mixin(require('sys'));

puts(parser.hello);
p = new parser.Parser();
p.addListener("receive", function(x) {
  puts("RECV: " + x);
});

function stringToBytes ( str ) {
  var ch, st, re = [];
  for (var i = 0; i < str.length; i++ ) {
    ch = str.charCodeAt(i);  // get char
    st = [];                 // set up "stack"
    do {
      st.push( ch & 0xFF );  // push byte to stack
      ch = ch >> 8;          // shift value down by 1 byte
    }
    while ( ch );
    // add stack contents to result
    // done because chars have "wrong" endianness
    re = re.concat( st.reverse() );
  }
  // return an array of bytes
  return re;
}

test = "\u0001\u0000\u0001\u0000\u0000\u0000\u0004\u0000\u0014\u0000\u000b\u00ce"
puts(inspect(test));
puts(inspect(p.parse(stringToBytes(test))));
//puts(p.parse("He"));
