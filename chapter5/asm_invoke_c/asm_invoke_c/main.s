.text
.intel_syntax noprefix
.globl	_main
.align	4, 0x90
_main:
    push	rbp
    mov	rbp, rsp
    push 10
    push 9
    push 8
    push 7
    mov r9d, 6
    mov r8d, 5
    mov ecx, 4
    mov edx, 3
    mov esi, 2
    mov edi, 1
    call _foo
    add rsp, 32
    pop rbp
    ret
