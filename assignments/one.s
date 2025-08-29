.data
arr: .space 400

.text
.global _start
_start:
	
	li a7, 5
	ecall
	
	add a1, x0, a0 #store n in a1
	add a2, x0, x0 #a2 is an index
	la a3, arr #have access to array via a3
	
	add a4, x0, x0 #store sum
	add a5, x0, x0 #store mean
	
	
	loop:
		beq a1, a2, continue
		
		li a7, 5
		ecall
		
		add t0, a3, a2
		slli t0, t0, 2
		sw a0, 0(t0)
		addi a2, a2, 1
		jal x0, loop
		
	continue:
		add t1, x0, x0
		
	sum:
		beq a1, t1, mean
		add t2, t1, a3
		slli t2, t2, 2
		lw a2, 0(t2)
		add a4, a4, a2
		addi t1, t1, 1
		jal x0, sum
		
	mean:
		div a5, a4, a1
		
	end:
		mv a0, a4
		jal ra, print
		mv a0, a5
		jal ra, print
		
	done:
		jal x0, done
			
		
	print:
		li   a7, 1          # syscall: print int
    	ecall
		
		li   a0, 10         # '\n'
		li   a7, 11         # syscall: print char
		ecall
	
		ret
