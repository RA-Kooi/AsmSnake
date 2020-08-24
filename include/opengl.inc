; vim: ft=asm

%ifndef OPENGL_S
%define OPENGL_S

%ifidn __OUTPUT_FORMAT__, win64
%define glClearColor __imp_glClearColor
%define glClear __imp_glClear
%endif

extern glClearColor:proc
extern glClear:proc

section .rodata
GL_COLOR_BUFFER_BIT:               equ 0x00004000

%endif ; OPENGL_S
