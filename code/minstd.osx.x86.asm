section .data

global _exit
global _write

%macro __syscall 1
    mov eax, %1
    int 0x80
%endmacro

section .text

; Implementation relies on calling convention
; to be the same as for normal functions

_exit:
    __syscall 0x1
    ret

_write:
    __syscall 0x4
    ret


