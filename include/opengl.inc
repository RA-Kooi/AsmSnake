; vim: ft=nasm

%ifndef OPENGL_S
%define OPENGL_S

%ifidn __OUTPUT_FORMAT__, win64
%define glClearColor __imp_glClearColor
%define glClear __imp_glClear
%define glEnable __imp_glEnable
%define glGetProcAddress __imp_wglGetProcAddress
%else
%define glGetProcAddress glXGetProcAddress
%endif

extern glClearColor:proc
extern glClear:proc
extern glEnable:proc
extern glGetProcAddress:proc

section .rodata
GL_COLOR_BUFFER_BIT:               equ 0x00004000
GL_FRAGMENT_SHADER                 equ 0x00008B30
GL_VERTEX_SHADER                   equ 0x00008B31

GL_COMPILE_STATUS:                 equ 0x00008B81
GL_LINK_STATUS:                    equ 0x00008B82
GL_INFO_LOG_LENGTH:                equ 0x00008B84

GL_DEBUG_OUTPUT:                   equ 0x000092E0
GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB:   equ 0x00008242

GL_DEBUG_SOURCE_API:               equ 0x00008246
GL_DEBUG_SOURCE_WINDOW_SYSTEM:     equ 0x00008247
GL_DEBUG_SOURCE_SHADER_COMPILER:   equ 0x00008248
GL_DEBUG_SOURCE_THIRD_PARTY:       equ 0x00008249
GL_DEBUG_SOURCE_APPLICATION:       equ 0x0000824A
GL_DEBUG_SOURCE_OTHER:             equ 0x0000824B

GL_DEBUG_TYPE_ERROR:               equ 0x0000824C
GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: equ 0x0000824D
GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR:  equ 0x0000824E
GL_DEBUG_TYPE_PORTABILITY:         equ 0x0000824F
GL_DEBUG_TYPE_PERFORMANCE:         equ 0x00008250
GL_DEBUG_TYPE_OTHER:               equ 0x00008251

GL_DEBUG_SEVERITY_HIGH:            equ 0x00009146
GL_DEBUG_SEVERITY_MEDIUM:          equ 0x00009147
GL_DEBUG_SEVERITY_LOW:             equ 0x00009148
GL_DEBUG_SEVERITY_NOTIFICATION:    equ 0x0000826B

section .bss
struc gl_pointers_t
.glDebugMessageCallbackARB: resq 1
.glCreateShader:            resq 1
.glDeleteShader:            resq 1
.glShaderSource:            resq 1
.glCompileShader:           resq 1
.glAttachShader:            resq 1
.glGetShaderiv:             resq 1
.glGetShaderInfoLog:        resq 1
.glCreateProgram:           resq 1
.glDeleteProgram:           resq 1
.glLinkProgram:             resq 1
.glGetProgramiv:            resq 1
.glGetProgramInfoLog:       resq 1
.glUseProgram:              resq 1
.glBindAttribLocation:      resq 1
.glGenBuffers:              resq 1
.glDeleteBuffers:           resq 1
endstruc

%ifndef INIT_GL_S
extern gl_pointers:gl_pointers_t
%endif

%endif ; OPENGL_S
