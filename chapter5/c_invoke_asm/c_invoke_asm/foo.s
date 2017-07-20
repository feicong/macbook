.section	__TEXT,__text,regular,pure_instructions
.macosx_version_min 10, 12
.intel_syntax noprefix
.globl	_foo
.align	4, 0x90
_foo:
push	rbp
mov	rbp, rsp
lea	rax, [rdi + rsi]
add	rax, rdx
add	rax, rcx
add	rax, r8
add	rax, r9
add	rax, qword ptr [rbp + 16]
add	rax, qword ptr [rbp + 24]
add	rax, qword ptr [rbp + 32]
add	rax, qword ptr [rbp + 40]
pop	rbp
ret
