%include "defs.inc"
%include "opengl.inc"
%include "helpers.inc"

global init_debug_context

section .rodata
format_str:
	db "OpenGL Error: %s, "
	db "[Source = %s, Type = %s, Severity = %s, ID = %d]",10,0

source_api:            db "API",0
source_app:            db "Application",0
source_wm:             db "Window System",0
source_shader:         db "Shader Compiler",0
source_third:          db "Third Party",0

type_error:            db "Error",0
type_deprecated:       db "Deprecated Behavior",0
type_undefined:        db "Undefined Behavior",0
type_portability:      db "Portability",0
type_performance:      db "Performance",0

severity_high:         db "High",0
severity_medium:       db "Medium",0
severity_low:          db "Low",0
severity_notification: db "Notification",0

other:                 db "Other",0
unknown:               db "Unknown",0

sources:
	dq source_api
	dq source_wm
	dq source_shader
	dq source_third
	dq source_app
	dq other

types:
	dq type_error
	dq type_deprecated
	dq type_undefined
	dq type_portability
	dq type_performance
	dq other

severities:
	dq severity_high
	dq severity_medium
	dq severity_low
	dq severity_notification

init_stack_space: equ 0x28 ; 32 byte shadow space + 8 bytes alignment
debug_stack: equ 0x38

section .text

init_debug_context:
	sub rsp, init_stack_space

	mov arg1, GL_DEBUG_OUTPUT
	call [glEnable]

	mov arg1, GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB
	call [glEnable]

	lea arg1, [debug_callback]
	xor arg2, arg2
	call [gl_pointers + gl_pointers_t.glDebugMessageCallbackARB]

	add rsp, init_stack_space
	ret

; GLsizei = int32
; GLenum = uint32
; GLuint = uint32
; GLchar = char
; void debug_callback(
;	GLenum source,
;	GLenum type,
;	GLuint id,
;	GLenum severity,
;	GLsizei length,
;	GLchar* message,
;	void *userParam)
debug_callback:
	; Caller stack layout
	; QW userParam
	; QW message:     0x78
	; DW: padding:    0x70
	; DW: length      0x6C
	; Shadow space:   0x68
	; return address: 0x48

	; Stack layout
	; DW: padding  0x38
	; DW: ID       0x34
	; QW: severity 0x30
	; QW: type     0x28
	; Shadow space 0x20

	mov [rsp + 8], r12 ; save r12
	sub rsp, debug_stack

	; arg1 source -> 2
	; arg2 type -> message
	; arg3 id -> source string r10
	; arg4 severity -> type string r11
	; arg5 length -> severity string r12
	; arg6 message -> ID

	call get_source
	call get_type
	call get_severity

	; fprintf(2, format string, msg, source str, type str, sev str, id)
	mov arg1, 2
%ifidn __OUTPUT_FORMAT__,win64
	call [__imp___acrt_iob_func]
	mov arg1, rax
%endif
	lea arg2,          [format_str]
	mov [arg5 + 0x10], arg3 ; ID
	mov arg3,          [arg5 + 0x10 + debug_stack] ; msg
	mov arg4,          r10 ; source
	mov [arg5],        r11 ; type
	mov [arg5 + 0x08], r12 ; sev
	call [fprintf]

	add rsp, debug_stack
	mov r12, [rsp + 8] ; restore r12
	ret

get_source:
	cmp arg1, GL_DEBUG_SOURCE_OTHER
	jbe .source
	lea r10, [unknown]
	ret

.source
	sub arg1, GL_DEBUG_SOURCE_API
	get_table_val r10, sources, arg1

	ret

get_type:
	cmp arg2, GL_DEBUG_TYPE_OTHER
	jbe .type
	lea r11, [unknown]
	ret

.type
	sub arg2, GL_DEBUG_TYPE_ERROR
	get_table_val r11, types, arg2

	ret

get_severity:
	cmp arg4, GL_DEBUG_SEVERITY_NOTIFICATION
	jne .severity
	mov r12, [severities + 3]
	ret

.severity
	cmp arg4, GL_DEBUG_SEVERITY_LOW
	jbe .end
	lea r12, [unknown]
	ret

.end
	sub arg4, GL_DEBUG_SEVERITY_HIGH
	get_table_val r12, severities, arg4

	ret
