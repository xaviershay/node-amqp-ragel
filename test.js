require.paths.unshift('build/default');
parser = require('hello');
process.mixin(require('sys'));

puts(parser.hello);
p = new parser.Parser();
p.addListener("receive", function(x) {
  puts("RECV: " + x);
});
puts(p.parse("2"));
puts(p.parse("h"));
puts(p.parse("2"));
puts(p.parse("hello1"));
//puts(p.parse("He"));
