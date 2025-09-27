.data
dash: .asciz "*"
message: .asciz "the top of the stack is: "

.text
.global _start
_start:
	
	#get n
	li a7, 5
	ecall
	mv s0, a0
	
	#a1 as the second argument that the define the depth of stack
	add a1, x0, x0
	
	#call fun
	jal ra, fun
	
	#over
	done:
		j done	
	
	fun:
		addi a2, a0, -1
		beq a1, x0, if_empty_stack
		bne a1, x0, if_not_empty_stack
		
		if_empty_stack:
			loop1:
				beq a2, x0, end_loop
				sub t0, a0, a2
				addi sp, sp, -20
				sw t0, 0(sp)
				sw a0, 4(sp)
				sw ra, 8(sp)
				sw a1, 12(sp)
				sw a2, 16(sp)
				
				addi a1, a1, 1
				mv a0, a2
				jal ra, fun
				
				lw a0, 4(sp)
				lw ra, 8(sp)
				lw a1, 12(sp)
				lw a2, 16(sp)
				addi sp, sp, 20
				
				addi a2, a2, -1
				j loop1

		if_not_empty_stack:
			#a0 is num, a1 is stack depth, a2 is cpy or num-1
			beq a0, x0, end_loop
			
			#print prefix
			#t0 is dynamic depth to iterate
			add t0, a1, x0
			print:
				beq t0, x0, end_print
				addi t1, x0, 20
				add t4, t0, -1
				mul t1, t1, t4
				add t2, sp, t1
				lw t3, 0(t2)
				mv a3, a0

				mv a0, t3
				li a7, 1
				ecall
				la a0, dash
				li a7, 4
				ecall

				mv a0, a3
				addi t0, t0, -1
				j print

			end_print:
				#print newline
				li a7, 1
				ecall
				li a0, 10
				li a7, 11
				ecall
				mv a0, a3
				
			loop2:
				beq a2, x0, end_loop
				sub t0, a0, a2
				
				addi sp, sp, -20
				sw t0, 0(sp)
				sw a0, 4(sp)
				sw ra, 8(sp)
				sw a1, 12(sp)
				sw a2, 16(sp)
				
				
				addi a1, a1, 1
				mv a0, a2
				jal ra, fun
				
				lw a0, 4(sp)
				lw ra, 8(sp)
				lw a1, 12(sp)
				lw a2, 16(sp)
				addi sp, sp, 20
				
				addi a2, a2, -1
				j loop2
					
					
		end_loop:
			ret
				

		return:
			ret