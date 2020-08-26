; vim: ft=asm

%ifndef HELPERS_INC
%define HELPERS_INC

; void* get_table_val(table, i)
%macro get_table_val 3
	lea %1, [%2]
	mov %1, [%1 + %3]
%endmacro

%endif ; HELPERS_INC
