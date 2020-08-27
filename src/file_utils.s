%include "defs.inc"

global read_entire_file

section .rodata
file_mode: db "rb",0
error_str: db "Failed to open file %s: %s",10,0

stack_space: equ 0x28

section .text

; Shadow space
	; QW: padding 0x18
	; QW: r14     0x10
	; QW: r13     0x08
	; QW: r12     0x00
; return address
; Stack layout
; Padding      0x28
; Shadow space 0x20

; char *read_entire_file(char *fileName)
read_entire_file:
	mov [rsp + 0x08], r12 ; Save R12 before we use it
	mov [rsp + 0x10], r13 ; Save R13 before we use it
	mov [rsp + 0x18], r14 ; Save R14 before we use it

	sub rsp, stack_space

	; r12 = FILE*
	; r13 = file_len
	; r14 = data

	lea arg2, [file_mode]
	call [fopen]

	test rax, rax ; if !file
	jz .error
	mov arg1, rax ; if file
	mov r12, rax

	; fseek(file, 0, SEEK_END)
	xor arg2, arg2
	mov arg3, SEEK_END
	call [fseek]

	; ftell(file)
	mov arg1, r12
	call [ftell]
	mov r13, rax

	; fseek(file, 0, SEEK_SET)
	mov arg1, r12
	xor arg2, arg2
	mov arg3, SEEK_SET ; SEEK_SET may not be 0, so don't xor
	call [fseek]

	; malloc(file_len)
	mov arg1, r13
	call [malloc]

	; Assume malloc doesn't fail
	mov r14, rax

	; Hope to GOD we can read this shit in a single fread call
	; fread(data, file_len, 1, file)
	mov arg1, r14
	mov arg2, r13
	mov arg3, 1
	mov arg4, r12
	call [fread]

	cmp rax, r13
	; if the read bytes aren't the same, just trap so the debugger can take over
	jne .trap

	; fclose(file)
	mov arg1, r12
	call [fclose]

	mov rax, r14

.end
	add rsp, stack_space
	mov r12, [rsp + 0x08] ; Restore r12
	mov r13, [rsp + 0x10] ; Restore r13
	mov r14, [rsp + 0x18] ; Restore r14
	ret

.error
	; Get errno value
	call [errno]

	; strerror(errno)
	mov arg1, [rax]
	call [strerror]
	; move result to arg4 for fprintf
	mov arg4, rax

	; Move filename to arg3 for fprintf
	mov arg3, arg1

	; fprintf(stderr, error_str, fileName, strerror(errno))
	mov arg1, 2
%ifidn __OUTPUT_FORMAT__, win64
	call [__imp___acrt_iob_func]
	mov arg1, rax
%endif

	lea arg2, [error_str]
	call [fprintf]

	xor rax, rax

	jmp .end

.trap
	int 3
