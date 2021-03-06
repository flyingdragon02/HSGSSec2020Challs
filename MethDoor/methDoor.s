SYS_EXIT equ 0x3c
SYS_READ equ 0x0
SYS_WRITE equ 0x1
section .text
global _start
_start:
	entered_pin equ -0x10
	push rbp
	mov rbp, rsp
	; Print welcome message
	xor rdi, rdi
	inc rdi
	lea rsi, [rel welcome_msg]
	mov rdx, end_welcome_msg
	sub rdx, rsi
	mov rax, SYS_WRITE
	syscall
	; read pin
	xor rdi, rdi
	lea rsi, [rbp+entered_pin]
	mov rdx, 16
	mov rax, SYS_READ
	syscall
	; check printable
	lea rsi, [rbp+entered_pin]
	xor rax, rax
.check_loop:
	lodsb
	cmp al, ' '
	jle .fail
	cmp al, '~'
	jg .fail
	cmp rsi, rbp
	jl .check_loop

	; verify
	lea rsi, [rbp+entered_pin]
	mov rcx, 8
	xor rax, rax
.verify_loop:
	shl rax, 8
	lodsb
	xor al, byte [rsi+7]
	loop .verify_loop	
	
	mov rbx, rax
	lea rsi, [rel correct_pin]
	lodsq
	cmp rax, rbx
	je .success
.fail:
	xor rdi, rdi
	inc rdi
	lea rsi, [rel incorrect_msg]
	mov rdx, end_incorrect_msg
	sub rdx, rsi
	mov rax, SYS_WRITE
	syscall
	mov rdi, 1
	jmp .end
.success:
	xor rdi, rdi
	inc rdi
	lea rsi, [rel correct_msg]
	mov rdx, end_correct_msg
	sub rdx, rsi
	mov rax, SYS_WRITE
	syscall
	xor rdi, rdi
.end:
	mov rax, SYS_EXIT
	syscall
	hlt
	leave
	ret

section .data
welcome_msg:
db "PIN CODE:",0xa,0
end_welcome_msg:
correct_msg:
db "CORRECT! The Flag is HSGSSec{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}",0xa,0
end_correct_msg:
incorrect_msg:
db "INCORRECT!",0xa,0
end_incorrect_msg:
correct_pin:
dq 0x7c0558000056084a
