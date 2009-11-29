require.paths.unshift('build/default');
parser = require('hello');
process.mixin(require('sys'));

puts(parser.hello);
p = new parser.Parser();
p.addListener("receive", function(x) {
  puts("RECV: " + x);
});
test = "\u0001\u0000\u0001\u0000\u0000\u0000\u0004\u0000\u0014\u0000\u000b\u00ce"
puts(inspect(test));
puts(p.parse(test));
//puts(p.parse("He"));
