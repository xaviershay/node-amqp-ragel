#include <v8.h>
#include <node.h>
#include <node_events.h>
#include <string.h>

using namespace v8;
using namespace node;

%% machine amqp;
%% alphtype unsigned char;
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

    Local<Object> Parse(unsigned char* input, unsigned int length) {
      HandleScope scope;

      int res = 0;
      unsigned char *p = input;
      unsigned char *pe = input + length;
      Local<Object> ret = Object::New();
      Local<Value> frame;

      for (int i = 0; i < length; ++i) {
        printf("%x ", *(p + i));
      }
      printf("\n");

      %%{
        action FrameEnd {
          frame = String::New("abcde");
          Emit("receive", 0, &frame); // yields undefined, so incorrect
          printf("GOT FRAME\n");
        }

        # generated rules, define required actions
        ALPHA = 0x41..0x5a | 0x61..0x7a;
        BIT = "0" | "1";
        CHAR = 0x01..0x7f;
        CR = "\r";
        LF = "\n";
        CRLF = CR LF;
        CTL = 0x00..0x1f | 0x7f;
        DIGIT = 0x30..0x39;
        DQUOTE = "\"";
        HEXDIG = DIGIT | "A"i | "B"i | "C"i | "D"i | "E"i | "F"i;
        HTAB = "\t";
        SP = " ";
        WSP = SP | HTAB;
        LWSP = ( WSP | ( CRLF WSP ) )*;
        OCTET = any;
        VCHAR = 0x21..0x7e;
        literal_AMQP = 0x41.0x4d.0x51.0x50;
        protocol_id = "\0";
        protocol_version = 0x00.0x09.0x01;
        protocol_header = literal_AMQP protocol_id protocol_version;
        short_uint = OCTET{2,};
        channel = short_uint >{
          printf("%x\n", *fpc);
          printf("%x\n", fc);
          ret->Set(String::New("channel"), Integer::New(fc)); };
        long_uint = OCTET{4,};
        payload_size = long_uint;
        frame_properties = channel  payload_size;
        class_id = 0x01..0xff;
        method_id = 0x01..0xff @{ ret->Set(String::New("method"), Integer::New(1)); };
        long_long_uint = OCTET{8,};
        string_char = OCTET;
        short_string = OCTET string_char*;
        long_string = long_uint OCTET*;
        timestamp = long_long_uint;
        field_name = short_string;
        boolean = OCTET;
        short_short_int = OCTET;
        short_short_uint = OCTET;
        short_int = OCTET{2,};
        long_int = OCTET{4,};
        long_long_int = OCTET{8,};
        float = OCTET{4,};
        double = OCTET{8,};
        scale = OCTET;
        decimal_value = scale long_uint;
        field_value = ( "t"i boolean ) | ( "b"i short_short_int ) | ( "B"i short_short_uint ) | ( "U"i short_int ) | ( "u"i short_uint ) | ( "I"i long_int ) | ( "i"i long_uint ) | ( "L"i long_long_int ) | ( "l"i long_long_uint ) | ( "f"i float ) | ( "d"i double ) | ( "D"i decimal_value ) | ( "s"i short_string ) | ( "S"i long_string ) | ( "T"i timestamp ) | "V"i;
        field_value_pair = field_name field_value;
        field_table = long_uint field_value_pair*;
        amqp_field = BIT | OCTET | short_uint | long_uint | long_long_uint | short_string | long_string | timestamp | field_table;
        method_payload = class_id method_id amqp_field*;
        frame_end = 0xce;
        method_top = 0x01 ;
        method_frame = method_top frame_properties method_payload frame_end;
        content_class = OCTET;
        content_weight = "\0";
        content_body_size = long_long_uint;
        property_flags = BIT{15,} "\0";
        property_list = amqp_field*;
        header_payload = content_class content_weight content_body_size property_flags property_list;
        content_header = frame_properties header_payload frame_end;
        body_payload = OCTET*;
        content_body = 0x03 frame_properties body_payload frame_end;
        content = 0x02 content_header content_body*;
        method = method_frame content?;
        heartbeat = "\b" "\0" "\0" frame_end;
        amqp_unit = method | content | heartbeat;
        amqp = protocol_header amqp_unit*;
        field_array = long_int field_value*;

        # instantiate machine rules
        main:= amqp_unit @FrameEnd;
      }%%

      %%{
        write init;
        write exec;
      }%%
      return ret;
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

    if (args.Length() == 0 || !args[0]->IsArray()) {
      return ThrowException(String::New("Argument must be an array"));
    }

    Local<Array> input = args[0].toArray();
    unsigned char buffer[input->Length()];
    for (int i = 0; i < input->Length(); ++i) {
      buffer[i] = (unsigned char)input->Get(Integer::New(i)).Value();
    }
    /*
    uint16_t * buffer = malloc(uint16_t * input.length());
    input.Write(buffer);
    for (int i = 0; i < input.length(); ++i) {
      printf("%x ", *(buffer + i));
    }
    printf("\n");
    */

    Local<Object> ret = parser->Parse(buffer, input->Length());

    return ret;
  }

};

extern "C" void
init (Handle<Object> target)
{
  Parser::Initialize(target);
}
