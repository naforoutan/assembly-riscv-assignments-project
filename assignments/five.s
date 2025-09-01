.global _start
_start:
	
	li a7, 5
	ecall
	
	add s0, x0, a0 #store n
	
	factorial:
		add a1, x0, s0
		addi a2, x0, 1
	loop:
		beq a1, x0, res
		mul a2, a2, a1
		addi a1, a1, -1
		jal x0, loop
		
	res:
		add a0, a2, x0
		li a7, 1
		ecall
	done:
		jal x0, done