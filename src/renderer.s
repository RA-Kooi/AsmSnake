; vim: ft=nasm

%include "defs.inc"
%define RENDERER_S
%include "renderer.inc"
%include "opengl.inc"
%include "file_utils.inc"
%include "helpers.inc"

section .rodata
init_stack_size:           equ 0x28
load_stack_size:           equ 0x28
destroy_stack_size:        equ 0x28
create_stack_size:         equ 0x28
compile_stack_size:        equ 0x28
compile_shader_stack_size: equ 0x28
link_stack_size:           equ 0x28

vertex_shader:   db "shaders/points.vert",0
fragment_shader: db "shaders/points.frag",0
shader_error:    db "Error (shader compiler): %s",10,0
program_error:   db "Error (shader linking): %s",10,0

section .bss
render_state: resb render_state_t_size

section .text
global init_renderer
global destroy_renderer

; bool init_renderer()
init_renderer:
	sub rsp, init_stack_size

	call load_shaders
	test rax, rax
	jz .end
	mov rax, 1

.end
	add rsp, init_stack_size
	ret

; bool load_shaders()
load_shaders:
	sub rsp, load_stack_size

	mov arg1, GL_VERTEX_SHADER
	lea arg2, [render_state + render_state_t.vertex_shader]
	lea arg3, [vertex_shader]
	call create_shader
	test rax, rax
	jz .end

	mov arg1, GL_FRAGMENT_SHADER
	lea arg2, [render_state + render_state_t.fragment_shader]
	lea arg3, [fragment_shader]
	call create_shader
	test rax, rax
	jz .end

	call [gl_pointers + gl_pointers_t.glCreateProgram]
	mov [render_state + render_state_t.program], rax

	mov arg1, rax
	mov edx, [render_state + render_state_t.vertex_shader]
	call [gl_pointers + gl_pointers_t.glAttachShader]

	mov ecx, [render_state + render_state_t.program]
	mov edx, [render_state + render_state_t.fragment_shader]
	call [gl_pointers + gl_pointers_t.glAttachShader]

	call compile_shaders
	test rax, rax
	jz .end

	call link_program
	test rax, rax
	jz .end

	mov rax, 1

.end
	add rsp, load_stack_size
	ret

; void destroy_renderer()
destroy_renderer:
	sub rsp, destroy_stack_size

	mov arg1, [render_state + render_state_t.program]
	call [gl_pointers + gl_pointers_t.glDeleteProgram]

	mov arg1, [render_state + render_state_t.fragment_shader]
	call [gl_pointers + gl_pointers_t.glDeleteShader]

	mov arg1, [render_state + render_state_t.vertex_shader]
	call [gl_pointers + gl_pointers_t.glDeleteShader]

	add rsp, destroy_stack_size
	ret

; bool create_shader(int type, int &shader, char* shaderPath)
create_shader:
	; Stack layout:
	; Caller:
	; Shadow space
		; string data: 0x20
		; r12:         0x18
		; arg3:        0x10
		; arg2:        0x08
	; Return address:  0x00
	; Us:
	; string_length:   0x28
	; Shadow space:    0x20

	mov [rsp + 0x08], arg2
	mov [rsp + 0x10], arg3
	mov [rsp + 0x18], r12
	sub rsp, create_stack_size

	call [gl_pointers + gl_pointers_t.glCreateShader]
	mov rcx, [rsp + create_stack_size + 0x08] ; take pointer to shader
	mov [rcx], rax ; *shader = rax

	mov arg1, [rsp + create_stack_size + 0x10] ; take pointer to shader path
	call read_entire_file
	test rax, rax
	jz .error

	mov r12, rax ; save pointer to string data
	mov [arg5], arg2 ; save length
	mov [rsp + create_stack_size + 0x20], rax ; save string data

	lea arg4, [arg5] ; take pointer to string length
	lea arg3, [rsp + load_stack_size + 0x20] ; take pointer to string data
	mov arg2, 1
	mov arg1, [rsp + create_stack_size + 0x08] ; take pointer shader
	mov arg1, [arg1] ; *shader
	call [gl_pointers + gl_pointers_t.glShaderSource]

	mov arg1, r12
	call [free]

	mov rax, 1

.end
	add rsp, create_stack_size
	mov r12, [rsp + 0x18]
	ret

.error
	xor rax, rax
	jmp .end

; bool compile_shaders()
compile_shaders:
	sub rsp, compile_stack_size

	mov ecx, [render_state + render_state_t.vertex_shader]
	call compile_shader
	test rax, rax
	jz .end

	mov ecx, [render_state + render_state_t.fragment_shader]
	call compile_shader

.end
	add rsp, compile_stack_size
	ret

; bool compile_shader(int shader)
compile_shader:
	mov [rsp + 0x08], arg1
	mov [rsp + 0x10], r12
	sub rsp, compile_shader_stack_size

	call [gl_pointers + gl_pointers_t.glCompileShader]

	mov arg1, [rsp + compile_shader_stack_size + 0x08]
	mov arg2, GL_COMPILE_STATUS
	lea arg3, [arg5]
	call [gl_pointers + gl_pointers_t.glGetShaderiv]

	mov rax, 1
	mov ecx, [arg5]
	cmp rcx, 1
	jz .end

	mov arg1, [rsp + compile_shader_stack_size + 0x08]
	mov arg2, GL_INFO_LOG_LENGTH
	lea arg3, [arg5]
	call [gl_pointers + gl_pointers_t.glGetShaderiv]

	mov rax, [arg5]
	test rax, rax
	jz .end

	mov arg1, rax
	call [malloc]
	mov r12, rax

	mov [rsp + compile_shader_stack_size + 0x18], rax
	mov arg1, [rsp + compile_shader_stack_size + 0x08]
	mov arg2, [arg5]
	xor arg3, arg3
	mov arg4, rax
	call [gl_pointers + gl_pointers_t.glGetShaderInfoLog]

	get_stderr arg1
	lea arg2, [shader_error]
	mov arg3, [rsp + compile_shader_stack_size + 0x18]
	call [fprintf]

	mov arg1, r12
	call [free]

	xor rax, rax

.end
	add rsp, compile_shader_stack_size
	mov r12, [rsp + 0x10]
	ret

; bool link_program()
link_program:
	mov [rsp + 0x08], r12
	sub rsp, link_stack_size

	mov arg1, [render_state + render_state_t.program]
	call [gl_pointers + gl_pointers_t.glLinkProgram]

	mov arg1, [render_state + render_state_t.program]
	mov arg2, GL_LINK_STATUS
	lea arg3, [arg5]
	call [gl_pointers + gl_pointers_t.glGetProgramiv]

	mov rax, [arg5]
	test rax, rax
	jnz .end

	mov arg1, [render_state + render_state_t.program]
	mov arg2, GL_INFO_LOG_LENGTH
	lea arg3, [arg5]
	call [gl_pointers + gl_pointers_t.glGetProgramiv]

	xor rax, rax
	mov arg1, [arg5]
	test arg1, arg1
	jz .end

	call [malloc]
	mov r12, rax

	mov arg1, [render_state + render_state_t.program]
	mov arg2, [arg5]
	xor arg3, arg3
	mov arg4, rax
	call [gl_pointers + gl_pointers_t.glGetProgramInfoLog]

	get_stderr arg1
	lea arg2, [program_error]
	mov arg3, r12
	call [fprintf]

	mov arg1, r12
	call [free]

	xor rax, rax

.end
	add rsp, link_stack_size
	mov r12, [rsp + 0x08]
	ret
