.data
instruction: .space 64
debt: .space 40000 # 100 * 100 people * 4 bytes (integer)
names: .space 400
benefit: .space 400
people_count: .word 0
buffer: .space 32 # for extracted strings from instruction
newLine: .asciz "\n"

.text
.global _start
_start:
    addi sp, sp, -32
    sw ra, 28(sp)
    li a7, 5
    ecall
    mv s3, a0
    sw t0, 0(sp)

main:
    beqz s3, program_end

    la a0, instruction
    li a1, 64
    jal ra, empty_memory

    la a0, instruction
    li a1, 64
    li a7, 8
    ecall

    la a0, buffer
    li a1, 32
    jal ra, empty_memory

    la t1, instruction
    mv a0, t1
    jal ra, parse_instruction

    la t1, instruction
    lb t2, 0(t1)

    li t3, '1'
    beq t2, t3, cmd_1
    li t3, '2'
    beq t2, t3, cmd_2
    li t3, '3'
    beq t2, t3, cmd_3
    li t3, '4'
    beq t2, t3, cmd_4
    li t3, '5'
    beq t2, t3, cmd_5
    li t3, '6'
    beq t2, t3, cmd_6
    
cmd_end:
    addi s3, s3, -1
    j main

program_end:
    li a7, 10
    ecall

empty_memory:
    li t2, 4
    div t1, a1, t2

empty_memory_loop:
    beqz t1, empty_memory_end
    sw zero, 0(a0)
    addi t1, t1, -1
    addi a0, a0, 4
    j empty_memory_loop

empty_memory_end:
    jr ra

parse_instruction:
    la t1, buffer # name1 pointer
    addi t5, t1, 8 # name2 pointer
    addi t2, t1, 16 # amount pointer
    
    addi a0, a0, 1
    li t0, 0 # state: 0=command, 1=name1, 2=name2, 3=amount

parse_loop:
    lb t3, 0(a0)
    beqz t3, parse_end
    li t4, 32 # ' '
    beq t3, t4, handle_space

    li t3, 1
    beq t0, t3, store_name1
    li t3, 2
    beq t0, t3, store_name2
    li t3, 3
    beq t0, t3, store_amount
    j parse_end

store_name1:
    lb t6, 0(a0)
    sb t6, 0(t1)
    addi a0, a0, 1
    addi t1, t1, 1
    j parse_loop

store_name2:
    lb t6, 0(a0)
    sb t6, 0(t5)
    addi a0, a0, 1
    addi t5, t5, 1
    j parse_loop

store_amount:
    lb t6, 0(a0)
    sb t6, 0(t2)
    addi a0, a0, 1
    addi t2, t2, 1
    j parse_loop

handle_space:
    addi a0, a0, 1
    addi t0, t0, 1
    j parse_loop

parse_end:
    jr ra

string_compare:
    li t4, 8

string_compare_loop:
    beqz t4, are_equal
    lb t5, 0(a0)
    lb t6, 0(a1)
    li t3, 10 #\n
    bne t5, t3, a_check
    li t5, 0
a_check:
    bne t6, t3, b_check
    li t6, 0
b_check:
    bne t5, t6, not_equal
    addi a0, a0, 1
    addi a1, a1, 1
    addi t4, t4, -1
    j string_compare_loop

are_equal:
    li a0, 1
    jr ra

not_equal:
    li a0, 0
    jr ra

find_name_index:
    la t1, people_count
    lw t2, 0(t1)
    li t1, 0
    mv t3, a0

find_name_loop:
    beq t1, t2, name_not_found
    li t4, 12
    mul t5, t1, t4
    la t6, names
    add t0, t6, t5

    addi sp, sp, -12
    sw t1, 0(sp)
    sw ra, 4(sp)
    sw t3, 8(sp)

    mv a1, t0
    mv a0, t3
    jal ra, string_compare

    lw t1, 0(sp)
    lw ra, 4(sp)
    lw t3, 8(sp)
    addi sp, sp, 12

    beqz a0, find_name_loop_continue
    mv a0, t1
    jr ra

find_name_loop_continue:
    addi t1, t1, 1
    j find_name_loop

name_not_found:
    li a0, -1
    jr ra

parse_money:
    la t1, buffer
    addi t1, t1, 16
    li t2, 0

parse_integer_part:
    lb t3, 0(t1)
    li t4, 46 # '.'
    beq t3, t4, parse_fraction_part

    li t4, 48 # '0'
    sub t3, t3, t4
    li t4, 10
    mul t5, t4, t2
    add t2, t3, t5

    addi t1, t1, 1
    j parse_integer_part

parse_fraction_part:
    addi t1, t1, 1 # skips '.'

    lb t3, 0(t1)
    li t4, 48 # '0'
    sub t3, t3, t4
    li t4, 10
    mul t5, t4, t2
    add t2, t3, t5
    addi t1, t1, 1

    lb t3, 0(t1)
    li t4, 48 # '0'
    sub t3, t3, t4
    li t4, 10
    mul t5, t4, t2
    add t2, t3, t5

    mv a0, t2
    jr ra

strcpy:
    mv t1, a0
    mv t2, a1
    li t3, 8

strcpy_loop:
    beqz t3, strcpy_end
    lb t4, 0(t1)
    sb t4, 0(t2)
    addi t1, t1, 1
    addi t2, t2, 1
    addi t3, t3, -1
    j strcpy_loop

strcpy_end:
    sw zero, 0(t2)
    jr ra

add_new_name:
    la t2, names
    la t3, people_count
    lw t0, 0(t3)
    li t4, 12
    mul t5, t0, t4
    add t6, t5, t2

    addi sp, sp, -20
    sw t3, 0(sp)
    sw t0, 8(sp)
    sw ra, 16(sp)

    mv a1, t6
    jal ra, strcpy

    lw ra, 16(sp)
    lw t3, 0(sp)
    lw t0, 8(sp)
    addi sp, sp, 20
    mv a0, t0
    addi t0, t0, 1
    sw t0, 0(t3)
    jr ra

lexical_compare:
    la t1, names
    li t4, 12
    mul t2, a0, t4
    add t2, t2, t1
    mul t3, a1, t4
    add t3, t3, t1

lexical_compare_loop:
    lb t4, 0(t2)
    lb t5, 0(t3)
    beq t4, t5, lexical_rest_word
    bgt t4, t5, name2_is_greater
    j name1_is_greater

lexical_rest_word:
    addi t2, t2, 1
    addi t3, t3, 1
    j lexical_compare_loop

name1_is_greater:
    jr ra

name2_is_greater:
    mv a0, a1
    jr ra

calculate_debt:
    la t1, debt
    li t2, 100
    mul t3, a0, t2
    add t3, t3, a1
    slli t3, t3, 2
    add t4, t3, t1

    lw t2, 0(t4)
    sub t3, a2, t2
    mv a0, t3
    jr ra

cmd_1:
    la t1, buffer
    mv a0, t1
    addi sp, sp, 4
    sw t1, 0(sp)
    jal ra, find_name_index
    lw t1, 0(sp)
    addi sp, sp, -4
    li t2, -1
    bne a0, t2, process_name1
    mv a0, t1
    jal ra, add_new_name
process_name1:
    mv s1, a0

    la t1, buffer
    addi a0, t1, 8
    addi sp, sp, -4
    sw t1, 0(sp)
    jal ra, find_name_index
    lw t1, 0(sp)
    addi sp, sp, 4
    li t2, -1
    bne a0, t2, process_name2
    addi a0, t1, 8
    jal ra, add_new_name
process_name2:
    mv s2, a0
    jal ra, parse_money

    la t1, debt
    li t2, 100
    mul t3, t2, s1
    add t3, t3, s2
    slli t3, t3, 2
    add t3, t3, t1

    lw t4, 0(t3)
    add t5, a0, t4
    sw t5, 0(t3)

    la t1, benefit
    slli s1, s1, 2
    add t2, t1, s1
    lw t3, 0(t2)
    sub t3, t3, a0
    sw t3, 0(t2)

    slli s2, s2, 2
    add t2, t1, s2
    lw t3, 0(t2)
    add t3, t3, a0
    sw t3, 0(t2)
    j cmd_end

cmd_2:
    la t1, benefit
    li t2, 0
    li t0, -1
    li t4, 0

find_richest_loop:
    lw t3, people_count
    beq t3, t4, end_richest_loop

    lw t3, 0(t1)
    ble t3, t2, mid_continue_richest
    addi t2, t3, 0
    mv t0, t4
    addi t4, t4, 1
    addi t1, t1, 4
    j find_richest_loop

mid_continue_richest:
    beq t2, zero, continue_richest
    bne t2, t3, continue_richest
    addi sp, sp, -12
    sw t1, 0(sp)
    sw t2, 4(sp)
    sw t4, 8(sp)
    mv a0, t4
    mv a1, t0
    jal ra, lexical_compare

    mv t0, a0
    lw t1, 0(sp)
    lw t2, 4(sp)
    lw t4, 8(sp)
    addi sp, sp, 12

continue_richest:
    addi t4, t4, 1
    addi t1, t1, 4
    j find_richest_loop

end_richest_loop:
    li t1, -1
    beq t0, t1, no_richest_person

    la t1, names
    li t5, 12
    mul t2, t0, t5
    add t0, t2, t1

    mv a0, t0
    li a7, 4
    ecall

    la a0, newLine
    li a7, 4
    ecall
    j cmd_end

no_richest_person:
    mv a0, t0
    li a7, 1
    ecall
    la a0, newLine
    li a7, 4
    ecall
    j cmd_end

cmd_3:
    la t1, benefit
    li t2, 0
    li t0, -1
    li t4, 0

find_poorest_loop:
    lw t3, people_count
    beq t3, t4, end_poorest_loop

    lw t3, 0(t1)
    bge t3, t2, mid_continue_poorest
    addi t2, t3, 0
    mv t0, t4
    addi t4, t4, 1
    addi t1, t1, 4
    j find_poorest_loop

mid_continue_poorest:
    beq t2, zero, continue_poorest
    bne t2, t3, continue_poorest
    addi sp, sp, -12
    sw t1, 0(sp)
    sw t2, 4(sp)
    sw t4, 8(sp)
    mv a0, t4
    mv a1, t0
    jal ra, lexical_compare
    mv t0, a0
    lw t1, 0(sp)
    lw t2, 4(sp)
    lw t4, 8(sp)
    addi sp, sp, 12

continue_poorest:
    addi t4, t4, 1
    addi t1, t1, 4
    j find_poorest_loop

end_poorest_loop:
    li t1, -1
    beq t0, t1, no_poorest_person

    la t1, names
    li t5, 12
    mul t2, t0, t5
    add t0, t2, t1

    mv a0, t0
    li a7, 4
    ecall

    la a0, newLine
    li a7, 4
    ecall
    j cmd_end

no_poorest_person:
    mv a0, t0 # t0=-1
    li a7, 1
    ecall
    la a0, newLine
    li a7, 4
    ecall
    j cmd_end

cmd_4:
    la a0, buffer
    jal ra, find_name_index

    la t1, debt
    li t3, 0

    la t4, people_count
    lw t5, 0(t4)
    li t4, 0

    slli t6, a0, 2
    add t1, t1, t6
    mv t6, a0

check_debtors_loop:
    beq t5, t4, end_debtor_count
    lw t2, 0(t1)
    beqz t2, next_debtor

    addi sp, sp, -16
    sw t1, 0(sp)
    sw t3, 4(sp)
    sw t4, 8(sp)
    sw t5, 12(sp)

    mv a0, t6
    mv a1, t4
    mv a2, t2
    jal ra, calculate_debt

    lw t1, 0(sp)
    lw t3, 4(sp)
    lw t4, 8(sp)
    lw t5, 12(sp)
    addi sp, sp, 16

    ble a0, zero, next_debtor
    addi t3, t3, 1

next_debtor:
    addi t1, t1, 400
    addi t4, t4, 1
    j check_debtors_loop

end_debtor_count:
    mv a0, t3
    li a7, 1
    ecall

    la a0, newLine
    li a7, 4
    ecall
    j cmd_end

cmd_5:
    la a0, buffer
    jal ra, find_name_index

    la t1, debt
    li t3, 0

    la t4, people_count
    lw t5, 0(t4)
    li t4, 0

    li t2, 400
    mul t6, t2, a0
    add t1, t1, t6

    mv t6, a0

check_debts_loop:
    beq t5, t4, end_debt_count
    lw t2, 0(t1)
    beqz t2, next_debt_check

    addi sp, sp, -16
    sw t1, 0(sp)
    sw t3, 4(sp)
    sw t4, 8(sp)
    sw t5, 12(sp)

    mv a1, t6
    mv a0, t4
    mv a2, t2
    jal ra, calculate_debt
    lw t1, 0(sp)
    lw t3, 4(sp)
    lw t4, 8(sp)
    lw t5, 12(sp)
    addi sp, sp, 16

    ble a0, zero, next_debt_check
    addi t3, t3, 1

next_debt_check:
    addi t1, t1, 4
    addi t4, t4, 1
    j check_debts_loop

end_debt_count:
    mv a0, t3
    li a7, 1
    ecall

    la a0, newLine
    li a7, 4
    ecall
    j cmd_end

cmd_6:
    la a0, buffer
    jal ra, find_name_index
    mv s1, a0 # person 1 index

    la t1, buffer
    addi a0, t1, 8
    jal ra, find_name_index
    mv s2, a0 # person 2 index

    la t1, debt
    li t2, 100
    mul t3, t2, s2
    add t3, t3, s1
    slli t3, t3, 2
    add t4, t3, t1

    lw t1, 0(t4)
    mv a0, s1
    mv a1, s2
    mv a2, t1
    jal ra, calculate_debt

    li t2, 100
    div t1, a0, t2 # integer part
    rem t3, a0, t2 # fractional part
    li t2, 46 # '.'

    mv a0, t1
    li a7, 1
    ecall # print integer part
    mv a0, t2
    li a7, 11
    ecall # print '.'

    li t2, 10
    blt t3, t2, print_fraction_zero

print_fraction_part:
    mv a0, t3
    li a7, 1
    ecall
    la a0, newLine
    li a7, 4
    ecall
    j cmd_end

print_fraction_zero:
    li a0, 48 # '0'
    li a7, 11
    ecall
    j print_fraction_part