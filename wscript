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
	import os
	from waflib import Logs
	from waflib.extras import clang_cl

	Logs.enable_colors(2)

	cfg.load('nasm')
	cfg.env.append_value('ASFLAGS', ['-g', 'cv8', '-f', 'win64', '-m', 'amd64'])

	if cfg.env.ASM_NAME != 'yasm':
		Logs.warn('Assembler is not yasm, things may not work.')

	cfg.load('msvc')
	cfg.env.append_value('LDFLAGS', ['/DEBUG', '/INCREMENTAL:NO', '/WX'])

	cfg.env.GLFW3BIN = cfg.find_file('glfw3.dll', os.environ.get('PATH').split(';'))
	cfg.msg('Checking for DLL \'glfw3.dll\'', cfg.env.GLFW3BIN)
	cfg.env.LIB_GLFW3 = cfg.find_file('glfw3dll.lib', os.environ.get('LIB').split(';'))
	cfg.msg('Checking for library \'glfw3dll.lib\'', cfg.env.LIB_GLFW3)
	cfg.env.LIB_GLFW3 = cfg.env.LIB_GLFW3[:-4]
#enddef

def build(bld):
	Logs.enable_colors(2)

	bld.objects(
		name='asmObjs',
		source=['src/main.s'])

	bld.program(
		name='AsmSnake',
		features='cprogram',
		source=['src/dummy.c'],
		use=['asmObjs'],
		uselib=['CRT_MULTITHREADED_DLL_DBG', 'GLFW3'],
		target='AsmSnake')
