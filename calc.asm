format ELF64 executable 3


entry start

segment readable executable

macro write fd, buffer, size {
		mov    	rax, 1
		mov    	rdi, fd
		mov    	rsi, buffer
		mov    	rdx, size
		syscall

		}
start:
		mov    	rax, 0
		mov    	rdi, qword [fd]
		mov    	rsi, msgbuff
		mov    	rdx, msgbuff_len
		syscall

		mov    	rcx, msgbuff

mainloop:
		mov    	al, byte [rcx]
		cmp    	al, 0
		jz     	done
		cmp    	al, 10
		jz     	done
		cmp    	al, '0'
		jb     	notnumber
		cmp    	al, '9'
		ja     	notnumber

		jmp    	number

		; push   	rax
		; write  	1, rsp, 1
		; pop    	rax
notnumber:
		cmp    	al, '+'
		je     	plus
		cmp    	al, '-'
		je     	minusres
		cmp    	al, '*'
		je     	imulres
		cmp    	al, '/'
		je     	divideres
		inc    	rcx
		jmp    	mainloop
		; push   	rax
		; write  	1, rsp, 1
		; pop    	rax
		; jmp    	exit
plus:
		mov    	byte [isplus], 1
		inc    	rcx
		jmp    	mainloop
minusres:
		mov    	byte [isminus], 1
		inc    	rcx
		jmp    	mainloop
imulres:
		mov    	byte [isimul], 1
		inc    	rcx
		jmp    	mainloop
divideres:
		mov    	byte [isdivide], 1
		inc    	rcx
		jmp    	mainloop
number:
		cmp    	[isminus], 0
		jne    	WorkSecond
		cmp    	[isplus], 0
		jne    	WorkSecond
		cmp    	[isimul], 0
		jne    	WorkSecond
		cmp    	[isdivide], 0
		jne    	WorkSecond

		sub    	al, '0'
		movzx  	rdx, al
		mov    	rax, [firth]
		imul   	rax, 10
		add    	rax, rdx
		mov    	[firth], rax
		inc    	rcx
		jmp    	mainloop


WorkSecond:
		sub    	al, '0'
		movzx  	rdx, al
		mov    	rax, [second]
		imul   	rax, 10
		add    	rax, rdx
		mov    	[second], rax
		inc    	rcx
		jmp    	mainloop

done:
		cmp    	[isplus], 1
		je     	plusing
		cmp    	[isminus], 1
		je     	minusing
		cmp    	[isimul], 1
		je     	imuling
		cmp    	[isdivide], 1
		je     	dividing
		jmp    	exit
plusing:
		mov    	rdi, [firth]
		mov    	rdx, [second]
		add    	rdi, rdx
		mov    	rax, rdi
		xor    	r8, r8
		jmp    	check_sign
minusing:
		mov    	rdi, [firth]
		mov    	rdx, [second]
		sub    	rdi, rdx
		mov    	rax, rdi
		xor    	r8, r8
		jmp    	check_sign
imuling:
		mov    	rdi, [firth]
		mov    	rdx, [second]
		imul   	rdi, rdx
		mov    	rax, rdi
		xor    	r8, r8
		jmp    	check_sign
dividing:
		mov    	rax, [firth]
		xor    	rdx, rdx
		mov    	rbx, [second]
		cmp    	rbx, 0
		je     	exit
		div    	rbx
		xor    	r8, r8
		jmp    	check_sign
check_sign:
		test   	rax, rax
		jns    	print
		neg    	rax

		push   	rax
		push   	'-'
		write  	1, rsp, 1
		pop    	rdx
		pop    	rax


print:
		xor    	rdx, rdx
		mov    	rbx, 10
		; mov	rdx, rax
		div    	rbx
		inc    	r8
		add    	rdx, '0'
		push   	rdx
		cmp    	rax, 0
		jg     	print
printt:
		cmp    	r8, 0
		je     	exit
		test   	rax, rax
		js     	addminus
		write  	1, rsp, 1
		pop    	rdx
		dec    	r8
		jmp    	printt
addminus:
		neg    	rax
		write  	1, rsp, 1
		pop    	rdx
		dec    	r8
		jmp    	print

exit:
		mov    	rax, 60
		xor    	rdi, rdi
		syscall








segment readable writeable
		msgbuff	rb 	16
		msgbuff_len	= 	$ - msgbuff
		firth  	dq 		0
		second 	dq 		0
		fd     	rb 		4
		isplus 	rb 		1
		isminus	rb 		1
		isimul 	rb 		1
		isdivide	rb	1
