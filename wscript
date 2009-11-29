import TaskGen

srcdir = "."
blddir = "build"
VERSION = "0.0.1"

TaskGen.declare_chain(
	name = 'ragel',
	action = '${RAGEL} ${SRC} -o ${TGT}',
	ext_in = '.rl',
	ext_out = '.c',
  reentrant = 0,
)

def set_options(opt):
  opt.tool_options("compiler_cxx")

def configure(conf):
  conf.check_tool("compiler_cxx")
  conf.check_tool("node_addon")
  conf.find_program("ragel", var='RAGEL')

def build(bld):
  bld.new_task_gen(source='hello.rl')

  obj = bld.new_task_gen("cxx", "shlib", "node_addon")
  obj.target = "hello"
  obj.source = "hello.c"
