; vim: ft=asm

%ifndef OPENGL_S
%define OPENGL_S

%ifidn __OUTPUT_FORMAT__, win64
%define glClearColor __imp_glClearColor
%define glClear __imp_glClear
%define glGetProcAddress __imp_wglGetProcAddress
%else
%define glGetProcAddress glXGetProcAddress
%endif

extern glClearColor:proc
extern glClear:proc
extern glGetProcAddress:proc

section .rodata
GL_COLOR_BUFFER_BIT:               equ 0x00004000

section .bss
struc gl_pointers_t
.glDebugMessageCallbackARB: resq 1
endstruc

%ifndef INIT_GL_S
extern gl_pointers:gl_pointers_t
%endif

%endif ; OPENGL_S
