#include <v8.h>
#include <node.h>
#include <node_events.h>
#include <string.h>

using namespace v8;
using namespace node;

%% machine amqp;
%% write data;

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

    int Parse(char* input) {
      HandleScope scope;

      printf("Parsing: %s\n", input);
      int res = 0;
      char *p = input;
      char *pe = input + strlen(input);
      Local<Value> ret;

      %%{
        action FrameEnd {
          ret = String::New("abcde");
          Emit("receive", 0, &ret); // yields undefined, so incorrect
          printf("GOT FRAME\n");
        }
        ALPHA = 0x41..0x5a | 0x61..0x7a;
        DIGIT = 0x30..0x39;
        STR = ALPHA+ DIGIT;
        main := STR @FrameEnd;

        write init;
        write exec;
      }%%
      return cs;
    }

  int counter;
  int cs;

  Parser() : EventEmitter() {
    counter = 0;
    cs = 0;
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
      return ThrowException(String::New("Must give string to parse as argument"));
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
