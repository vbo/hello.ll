section .data

global _exit
global _write

%macro __syscall 1
    mov rax, %1
    syscall
%endmacro

section .text

_exit:
    __syscall 0x2000001
    ret

_write:
    __syscall 0x2000004
    ret

