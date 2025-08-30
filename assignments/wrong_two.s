.data
arr:            .space 256
is_pal_msg:   .asciz "IS PALINDROME\n"
isnt_pal_msg: .asciz "ISN'T PALINDROME\n"

.text
.global _start
_start:

    li  a7, 5
    ecall                         # read n

    add s0, x0, a0                # s0 = n
    la  s1, arr                   # s1 = &arr[0]
    add s2, x0, a0
    srai s2, s2, 1                # s2 = n/2

get_char:
    add t0, x0, x0                # t0 = i
get_char_loop:
    beq t0, s0, is_palindrome
    add t1, s1, t0                # t1 = &arr[i]  (byte array ⇒ no *4)
    li  a7, 12
    ecall                         # a0 = char
    sb  a0, 0(t1)                 # store byte
    addi t0, t0, 1
    jal x0, get_char_loop

is_palindrome:
    add a1, x0, x0                # a1 = i

is_pal_loop:
    sub  t0, x0, a1               # t0 = -i
    add  a2, s0, t0               # a2 = n - i
    addi a2, a2, -1               # a2 = n - 1 - i   (right index)

    jal  ra, make_small           # lowercase arr[i] & arr[j] in-place

    # load the two chars and compare
    add  t3, a1, s1               # &arr[i]
    lbu  t4, 0(t3)                # left char
    add  t5, a2, s1               # &arr[j]
    lbu  t6, 0(t5)                # right char
    bne  t4, t6, pal_false

    # middle check
    beq  a1, s2, pal_true
    add  a1, a1, 1
    jal  x0, is_pal_loop

make_small:
    # ---- left side: i ----
    add  t0, a1, s1               # t0 = &arr[i]
    lbu  t1, 0(t0)                # t1 = arr[i]
    li   t2, 'A'
    blt  t1, t2, check_last       # if t1 < 'A' → skip
    li   t2, 'Z'
    blt  t2, t1, check_last       # if 'Z' < t1 → skip (i.e., t1 > 'Z')
    addi t1, t1, 32               # to lowercase
    sb   t1, 0(t0)

check_last:
    # ---- right side: j ----
    add  t0, a2, s1               # t0 = &arr[j]
    lbu  t1, 0(t0)                # t1 = arr[j]
    li   t2, 'A'
    blt  t1, t2, end_make_small   # if t1 < 'A' → skip
    li   t2, 'Z'
    blt  t2, t1, end_make_small   # if 'Z' < t1 → skip (t1 > 'Z')
    addi t1, t1, 32               # to lowercase
    sb   t1, 0(t0)

end_make_small:
    ret

pal_true:
    jal  ra, print_word
	li   a0, 10                   # '\n'
    li   a7, 11 
	ecall
    la   a0, is_pal_msg           # print string (a0 = address)
    li   a7, 4
    ecall
    jal  x0, done

pal_false:
    jal  ra, print_word
	li   a0, 10                   # '\n'
    li   a7, 11 
	ecall
    la   a0, isnt_pal_msg
    li   a7, 4
    ecall
    jal  x0, done

print_word:
    li   a0, 10                   # '\n'
    li   a7, 11                   # print char
    ecall
    add  t0, x0, x0               # i = 0
print_loop:
    beq  t0, s0, end_print
    add  t1, s1, t0               # &arr[i]
    lbu  a0, 0(t1)                # load byte to print
    li   a7, 11                   # print char
    ecall
    addi t0, t0, 1
    jal  x0, print_loop
end_print:
    ret

done:
    jal  x0, done
