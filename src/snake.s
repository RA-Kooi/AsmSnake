%include "defs.inc"
%define SNAKE_S
%include "snake.inc"

section .rodata
; rng divisors
s1d: dd 30269.0
s2d: dd 30307.0
s3d: dd 30323.0
board_mid: equ board_width / 2 * board_height / 2

section .data
; rng state
s1: dd 100.0
s2: dd 100.0
s3: dd 100.0

section .bss
board: resb board_t_size

section .text

global init_board

; Wichmann-Hill rng
; float rng()
rng:
	; s1 = (171 * s1) % 30269
	; s2 = (172 * s2) % 30307
	; s3 = (170 * s3) % 30323
	; return (s1 / 30269.0 + s2/30307.0 + s3/30323.0) % 1.0

	; s1 = (171 * s1) % 30269
	cvttss2si eax, [s1] ; convert s1 to int
	imul eax, eax, 171 ; (171 * s1)
	mov ecx, 30269
	cdq ; sign extend, because idiv works on 64 bit / 32 bit (why? idfk)
	idiv ecx ; / 30269, remainder is in edx
	cvtsi2ss xmm0, edx

	; s2 = (172 * s2) % 30307
	cvttss2si eax, [s2] ; convert s2 to int
	imul eax, eax, 172 ; (172 * s2)
	mov ecx, 30307
	cdq ; sign extend, because idiv works on 64 bit / 32 bit (why? idfk)
	idiv ecx ; / 30307, remainder is in edx
	cvtsi2ss xmm1, edx

	; s3 = (170 * s3) % 30323
	cvttss2si eax, [s3] ; convert s3 to int
	imul eax, eax, 170 ; (170 * s3)
	mov ecx, 30323
	cdq ; sign extend, because idiv works on 64 bit / 32 bit (why? idfk)
	idiv ecx ; / 30323, remainder is in edx
	cvtsi2ss xmm2, edx

	; Update global state
	movss [s1], xmm0
	movss [s2], xmm1
	movss [s3], xmm2

	; s1 / 30269.0
	divss xmm0, [s1d]

	; s2 / 30307
	divss xmm1, [s2d]

	; s3 / 30323
	divss xmm2, [s3d]

	; s1 + s2
	addss xmm0, xmm1

	; (s1 + s2) + s3
	addss xmm0, xmm2

	; mod 1 = f -= int(f)
	cvttss2si eax, xmm0
	cvtsi2ss xmm1, eax
	subss xmm0, xmm1

	ret

random_tile_id:
	call rng
	mov eax, board_size
	cvtsi2ss xmm1, eax
	mulss xmm0, xmm1
	cvttss2si eax, xmm0

	ret

init_board:
	; Set random food block
	call random_tile_id
	lea rdx, [board]
	mov byte[rdx + rax], 2

	; Set player block
	mov byte[rdx + board_mid], 1

	ret
