[BITS 64]

%include "defs.inc"
%include "glfw.inc"
%include "opengl.inc"

section .rodata
init_error: db "Error initializing GLFW",0
window_title: db "AsmSnake",0
window_error: db "Error creating window",0
fps: dd 0.1 ; 10 FPS ought to be enough I guess

stack_space: equ 0x28 ; 32 byte shadow space + 8 bytes alignment

global main
section .text code align=16

; r12 = glfw window

main:
	sub rsp, stack_space

	call [glfwInit]
	test rax, rax ; if !glfwInit
	jnz .success
	lea arg1, [init_error]
	call [puts]
	mov rax, 1
	ret

.success
	mov arg1, GLFW_CLIENT_API
	mov arg2, GLFW_OPENGL_API
	call [glfwWindowHint]

	mov arg1, GLFW_CONTEXT_VERSION_MAJOR
	mov arg2, 3
	call [glfwWindowHint]

	mov arg1, GLFW_CONTEXT_VERSION_MINOR
	mov arg2, 3
	call [glfwWindowHint]

	mov arg1, GLFW_OPENGL_FORWARD_COMPAT
	xor arg2, arg2
	call [glfwWindowHint]

	mov arg1, GLFW_OPENGL_DEBUG_CONTEXT
	mov arg2, 1
	call [glfwWindowHint]

	mov arg1, GLFW_OPENGL_PROFILE
	mov arg2, GLFW_OPENGL_CORE_PROFILE
	call [glfwWindowHint]

	mov arg1, screen_x
	mov arg2, screen_y
	lea arg3, [window_title]
	xor arg4, arg4
	mov qword[arg5], 0 ; put the last argument on the stack
	call [glfwCreateWindow]

	test rax, rax ; if !window
	jz .window_fail
	mov r12, rax ; r12 = window

	mov arg1, rax
	call [glfwMakeContextCurrent]

	pxor arg1f, arg1f
	pxor arg2f, arg2f
	pxor arg3f, arg3f
	movss arg4f, [f1]
	call [glClearColor]

	mov arg1, GL_COLOR_BUFFER_BIT
	call [glClear]

	mov arg1, r12
	call [glfwSwapBuffers]

	; while(!glfwShouldClose(window))
.no_close_begin
	mov arg1, r12
	call [glfwWindowShouldClose]

	test rax, rax ; if !rax
	jne .no_close_end

	mov arg1, GL_COLOR_BUFFER_BIT
	call [glClear]

	mov arg1, r12
	call [glfwSwapBuffers]

	movss arg1f, [fps]
	call [glfwWaitEventsTimeout]

	jmp .no_close_begin
.no_close_end
	jmp .end

.window_fail
	lea arg1, [window_error]
	call [puts]

.end
	call [glfwTerminate]

	; Return 0
	xor rax, rax

	add rsp, stack_space

	ret
