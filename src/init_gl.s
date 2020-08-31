%include "defs.inc"
%define INIT_GL_S
%include "opengl.inc"

section .rodata
gl_debug:                db "glDebugMessageCallbackARB",0
gl_create_shader:        db "glCreateShader",0
gl_delete_shader:        db "glDeleteShader",0
gl_shader_source:        db "glShaderSource",0
gl_compile_shader:       db "glCompileShader",0
gl_attach_shader:        db "glAttachShader",0
gl_get_shader_iv:        db "glGetShaderiv",0
gl_get_shader_info_log:  db "glGetShaderInfoLog",0
gl_create_program:       db "glCreateProgram",0
gl_delete_program:       db "glDeleteProgram",0
gl_link_program:         db "glLinkProgram",0
gl_get_program_iv:       db "glGetProgramiv",0
gl_get_program_info_log: db "glGetProgramInfoLog",0
gl_use_program:          db "glUseProgram",0
gl_bind_attrib_location: db "glBindAttribLocation",0
gl_gen_buffers:          db "glGenBuffers",0
gl_delete_buffers:       db "glDeleteBuffers",0

strings:
	dq gl_debug
	dq gl_create_shader
	dq gl_delete_shader
	dq gl_shader_source
	dq gl_compile_shader
	dq gl_attach_shader
	dq gl_get_shader_iv
	dq gl_get_shader_info_log
	dq gl_create_program
	dq gl_delete_program
	dq gl_link_program
	dq gl_get_program_iv
	dq gl_get_program_info_log
	dq gl_use_program
	dq gl_bind_attrib_location
	dq gl_gen_buffers
	dq gl_delete_buffers

strings_len: equ ($ - strings) / 8

stack_space:       equ 0x28

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
	mov [rsp + 0x08], r12
	mov [rsp + 0x10], r13
	mov [rsp + 0x18], r14
	sub rsp, stack_space

	mov r12, strings_len
	lea r13, [strings]
	lea r14, [gl_pointers]

	; for(int i = strings_len; i > 0; --i)
.load_func
	mov arg1, [r13 + (r12 - 1) * 8] ; strings + (i - 1)
	call [glGetProcAddress]
	mov [r14 + (r12 - 1) * 8], rax ; gl_pointers + (i - 1)

	sub r12, 1
	jnz .load_func

	add rsp, stack_space
	mov r14, [rsp + 0x18]
	mov r13, [rsp + 0x10]
	mov r12, [rsp + 0x08]
	ret
