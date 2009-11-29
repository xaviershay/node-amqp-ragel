#include <v8.h>
#include <node.h>
#include <node_events.h>

using namespace v8;
using namespace node;

class Parser : public EventEmitter {
  public:
    static void Initialize(Handle<Object> target) {
      target->Set(String::New("hello"), String::New("World"));

      Local<FunctionTemplate> t = FunctionTemplate::New(New);

      t->Inherit(EventEmitter::constructor_template);
      t->InstanceTemplate()->SetInternalFieldCount(1);

      NODE_SET_PROTOTYPE_METHOD(t, "parse", Parse);

      target->Set(String::NewSymbol("Parser"), t->GetFunction());
    }

    int Parse(const char* input) {
      counter += 1;
      return counter;
    }

  int counter;

  Parser() : EventEmitter() {
    counter = 0;
  }
 protected:

  static Handle<Value> New (const Arguments& args) {
    HandleScope scope;

    Parser *parser = new Parser();
    parser->Wrap(args.This());

    return args.This();
  }

  static Handle<Value>
  Parse (const Arguments& args)
  {
    Parser *parser = ObjectWrap::Unwrap<Parser>(args.This());

    HandleScope scope;

    if (args.Length() == 0 || !args[0]->IsString()) {
      return ThrowException(String::New("Must give conninfo string as argument"));
    }

    String::Utf8Value input(args[0]->ToString());

    int r = parser->Parse(*input);

    return Integer::New(r);
  }

};

extern "C" void
init (Handle<Object> target)
{
  Parser::Initialize(target);
}
