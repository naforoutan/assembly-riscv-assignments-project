.data
arr: .space 256
is_pal_msg: .asciz "\nIS PALINDROME\n"
isnt_pal_msg: .asciz "\nIS NOT PALINDROME\n"


.text
.global _start
_start:
	
	li a7, 5
	ecall #read the n
	
	add s0, x0, a0 #s0 keeps n
	la s1, arr
	add s2, x0, a0
	srai s2, s2, 1 #n/2
	
	get_char:
		add t0, x0, x0 #t0 as index
	get_char_loop:
		beq t0, s0, is_palindrome
		add t1, s1, t0
		
		li a7, 12
		ecall
		
		sb a0, 0(t1)

		addi t0, t0, 1
		jal x0, get_char_loop
		
	is_palindrome:
		add a1, x0, x0
	
	is_pal_loop:
		sub t0, x0, a1
		add a2, s0, t0
		addi a2, a2, -1
		jal ra, make_small
		add t3, a1, s1
		lb t4, 0(t3)

		add t5, a2, s1
		lbu t6, 0(t5)
		
		bne t4, t6, pal_false
		#check if is middle
		beq a1, s2, pal_true
		add a1, a1, 1
		jal x0, is_pal_loop
		
	make_small:
		#check a1
		add t0, a1, s1
		lbu t1, 0(t0)
		li t2, 'A'     
		blt t1, t2, check_last
		li t2, 'Z'     
		bgt t1, t2, check_last
		addi t1, t1, 32
		sb t1, 0(t0)
		
	check_last:
		#check a2
		add t0, a2, s1
		lbu t1, 0(t0)
		li t2, 'A'     
		blt t1, t2, end_make_small
		li t2, 'Z'     
		bgt t1, t2, end_make_small
		addi t1, t1, 32
		sb t1, 0(t0)
		
	end_make_small:
		ret	
		
	pal_true:
		li a7, 11
		li t0, '\n'
		add a0, x0, t0
		ecall
		
		jal ra, print_word
		
		la a0, is_pal_msg
		li a7, 4
    	ecall	
		jal x0, done
	
	
	pal_false:
		li a7, 11
		li t0, '\n'
		add a0, x0, t0
		ecall
		
		jal ra, print_word
		
		la a0, isnt_pal_msg
		li a7, 4
    	ecall
		jal x0, done
	
	
	print_word:
		add a1, x0, x0
	print_w_loop:
		beq a1, s0, end_print_w_loop
		add a2, a1, s1
		lb a0, 0(a2)
		li a7, 11
		ecall
		addi a1, a1, 1
		jal x0, print_w_loop
	end_print_w_loop:
		ret


	done:
		jal x0, done