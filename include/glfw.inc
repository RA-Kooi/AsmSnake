; vim: ft=asm

%ifndef GLFW_INC
%define GLFW_INC

%ifidn __OUTPUT_FORMAT__, win64
%define glfwInit __imp_glfwInit
%define glfwTerminate __imp_glfwTerminate
%define glfwCreateWindow __imp_glfwCreateWindow
%define glfwMakeContextCurrent __imp_glfwMakeContextCurrent
%define glfwWindowShouldClose __imp_glfwWindowShouldClose
%define glfwSwapBuffers __imp_glfwSwapBuffers
%define glfwWaitEventsTimeout __imp_glfwWaitEventsTimeout
%define glfwWaitEvents __imp_glfwWaitEvents
%define glfwPollEvents __imp_glfwPollEvents
%define glfwWindowHint __imp_glfwWindowHint
%endif

extern glfwInit:proc
extern glfwTerminate:proc
extern glfwCreateWindow:proc
extern glfwMakeContextCurrent:proc
extern glfwWindowShouldClose:proc
extern glfwSwapBuffers:proc
extern glfwWaitEventsTimeout:proc
extern glfwWindowHint:proc

section .rodata
; Input
GLFW_RELEASE: equ 0
GLFW_PRESS:   equ 1
GLFW_REPEAT:  equ 2

; Errors
GLFW_NO_ERROR: equ 0 ; Not really using this since test rax, rax

; Window hints
GLFW_RESIZABLE: equ 0x00020003

; Context hints
GLFW_CLIENT_API:            equ 0x00022001
GLFW_CONTEXT_VERSION_MAJOR: equ 0x00022002
GLFW_CONTEXT_VERSION_MINOR: equ 0x00022003
GLFW_OPENGL_FORWARD_COMPAT: equ 0x00022006
GLFW_OPENGL_DEBUG_CONTEXT:  equ 0x00022007
GLFW_OPENGL_PROFILE:        equ 0x00022008

; Context values
GLFW_OPENGL_API:            equ 0x00030001
GLFW_OPENGL_CORE_PROFILE:   equ 0x00032001

%endif ; GLFW_INC
