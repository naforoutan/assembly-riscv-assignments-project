.data
arr: .space 256

.text
.global _start
_start:
	
	li a7, 5
	ecall
	add s0, a0, x0 #store n in s0
	la s1, arr
	
	give_nums:
		add a1, x0, x0
	loop:
		beq a1, s0, print_res

		li a7, 5
		ecall
		
		add a2, s1, a1
		sb a0, 0(a2)
		
		addi a1, a1, 1
		jal x0, loop
		
			
	print_res:
		add a1, x0, x0
	lop:		
		beq a1, s0, done
		add a2, a1, s1
		lb a0, 0(a2)
		
		li a7, 1
		ecall
		
		li a0, ' '
		li a7, 11
		ecall
		
		addi a1, a1, 1
		jal x0, lop
	
	
	done:
		jal x0, done