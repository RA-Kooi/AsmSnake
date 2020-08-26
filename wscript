#!/usr/bin/env python3
# encoding: utf-8
# vim: sw=4 ts=4 noexpandtab

from waflib import Logs

top = '.'
out = 'build'

def options(opt):
	Logs.enable_colors(2)

	opt.load('nasm')
#enddef

def configure(cfg):
	import os, shutil
	from waflib import Logs
	from waflib.extras import clang_cl

	Logs.enable_colors(2)

	cfg.load('nasm')
	cfg.env.append_value('ASFLAGS', ['-g', 'cv8', '-f', 'win64', '-m', 'amd64'])

	if cfg.env.ASM_NAME != 'yasm':
		Logs.warn('Assembler is not yasm, things may not work.')

	cfg.load('msvc')
	cfg.env.append_value('LDFLAGS', ['/DEBUG', '/INCREMENTAL:NO', '/WX'])

	cfg.check_lib_msvc(libname='opengl32', uselib_store='opengl')

	def environ(key):
		return os.environ.get(key).split(';')

	cfg.env.GLFW3BIN = cfg.find_file('glfw3.dll', environ('PATH'))
	cfg.msg('Checking for DLL \'glfw3.dll\'', cfg.env.GLFW3BIN)

	cfg.env.GLFW3PDB = cfg.find_file_opt('glfw3.pdb', environ('PATH'))
	cfg.msg('Checking for PDB \'glfw3.pdb\'', cfg.env.GLFW3PDB)

	cfg.env.LIB_GLFW3 = cfg.find_file('glfw3dll.lib', environ('LIB'))
	cfg.msg('Checking for library \'glfw3dll.lib\'', cfg.env.LIB_GLFW3)

	cfg.env.LIB_GLFW3 = cfg.env.LIB_GLFW3[:-4]

	shutil.copy(cfg.env.GLFW3BIN, cfg.bldnode.abspath())
	if cfg.env.GLFW3PDB:
		shutil.copy(cfg.env.GLFW3PDB, cfg.bldnode.abspath())
	#endif
#enddef

def build(bld):
	Logs.enable_colors(2)

	bld.objects(
		name='asmObjs',
		includes=['include'],
		source=['src/main.s', 'src/init_gl.s', 'src/debug_context.s'])

	bld.program(
		name='AsmSnake',
		features='cprogram',
		source=['src/dummy.c'],
		use=['asmObjs'],
		uselib=['CRT_MULTITHREADED_DLL_DBG', 'GLFW3', 'opengl'],
		target='AsmSnake')
#enddef

from waflib.Configure import conf
@conf
def find_file_opt(self, filename, path_list=[]):
	import os
	from waflib import Utils

	for n in Utils.to_list(filename):
		for d in Utils.to_list(path_list):
			p = os.path.expanduser(os.path.join(d, n))
			if os.path.exists(p):
				return p
			#endif
		#endfor
	#endfor

	return None
#enddef
