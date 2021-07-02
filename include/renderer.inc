; vim: ft=nasm

%ifndef RENDERER_INC
%define RENDERER_INC

%ifndef RENDERER_S
extern init_renderer:proc
extern destroy_renderer:proc
%endif

section .bss
struc render_state_t
.vertex_shader:   resd 1
.fragment_shader: resd 1
.program:         resd 1
.vbo:             resd 1
.vao:             resd 1
.padding:         resd 1
endstruc

%endif ; RENDERER_INC
