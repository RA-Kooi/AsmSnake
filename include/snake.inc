; vim: ft=nasm

%ifndef SNAKE_INC
%define SNAKE_INC

%include "defs.inc"

section .rodata
tile_size: equ 32
half_tile_size: equ tile_size / 2

board_width: equ screen_x / tile_size
board_height: equ screen_y / tile_size
board_size: equ board_width * board_height

struc board_t
.tiles: resb board_size
endstruc

%ifndef SNAKE_S
extern init_board:proc
%endif

%endif ; SNAKE_INC
