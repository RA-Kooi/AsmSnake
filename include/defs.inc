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
%define fprintf __imp_fprintf
%define strerror __imp_strerror
%define errno __imp__errno

%define fopen __imp_fopen
%define fclose __imp_fclose
%define fread __imp_fread
%define fseek __imp_fseek
%define ftell __imp_ftell

%define malloc __imp_malloc
%define free __imp_free

extern __imp___acrt_iob_func:proc

section .drectve info
db "/defaultlib:legacy_stdio_definitions.lib"
%endif

extern puts:proc
extern fprintf:proc
extern strerror:proc
extern errno:proc ; ???linux???

extern fopen:proc
extern fclose:proc
extern fread:proc
extern fseek:proc
extern ftell:proc

extern malloc:proc
extern free:proc

section .rodata
f1: dd 1.0

SEEK_SET: equ 0
SEEK_CUR: equ 1
SEEK_END: equ 2

section .bss align=4

%endif ; DEFS_INC
