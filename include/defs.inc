; vim: ft=asm

%ifndef DEFS_INC
%define DEFS_INC

DEFAULT REL

section .rodata data align=8
screen_x: equ 640
screen_y: equ 480

; x64 argument registers
%define arg1 rcx
%define arg2 rdx
%define arg3 r8
%define arg4 r9

%define arg5 rsp + 0x20

; x64 floating point argument registers
%define arg1f xmm0
%define arg2f xmm1
%define arg3f xmm2
%define arg4f xmm3

%ifidn __OUTPUT_FORMAT__, win64
%define puts __imp_puts
%endif

extern puts:proc

section .rodata
f1: dd 1.0

section .bss align=4

%endif ; DEFS_INC
