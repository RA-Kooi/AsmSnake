%include "defs.inc"
%define INIT_GL_S
%include "opengl.inc"

section .rodata
debug_text: db "glDebugMessageCallbackARB",0
stack_space: equ 0x28

section .bss
global gl_pointers
gl_pointers: resb gl_pointers_t_size

global init_gl
section .text

; Stack layout
; QW: padding
; Shadow space

; void init_gl()
init_gl:
	sub rsp, stack_space

	lea arg1, [debug_text]
	call [glGetProcAddress]

	mov [gl_pointers + gl_pointers_t.glDebugMessageCallbackARB], rax

	add rsp, stack_space
	ret
