; vim: ft=nasm

%ifndef HELPERS_INC
%define HELPERS_INC

; void* get_table_val(table, i)
%macro get_table_val 3
	lea %1, [%2]
	mov %1, [%1 + %3]
%endmacro

%macro get_stderr 1
	mov %1, 2
%ifidn __OUTPUT_FORMAT__, win64
	call [__imp___acrt_iob_func]
	mov %1, rax
%endif
%endmacro

%endif ; HELPERS_INC
