.text
.intel_syntax noprefix
.globl  _main
_main:
    mov edi, 1
    lea rsi, [rip + str]
    mov rdx, 12
    mov rax, 0x2000004
    syscall

    xor eax,eax
    ret

.cstring
str:
    .ascii "Hello world\n"
