require.paths.unshift('build/default');
parser = require('hello');
process.mixin(require('sys'));

puts(parser.hello);
p = new parser.Parser();
puts(p.parse("input"));
puts(p.parse("input"));
puts(p.parse("input"));
