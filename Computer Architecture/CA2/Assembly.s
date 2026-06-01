addi s2, zero, 1000
addi s0, zero, 0
slti t0, s0, 9
beq  t0, zero, DONE
addi s2, zero, 1000
addi s1, zero, 0
slti t1, s1, 9
beq  t1, zero, END_INNER
lw   t2, 0(s2)
lw   t3, 4(s2)
blt  t3, t2, SWAP
addi s2, s2, 4
addi s1, s1, 1
jal  zero, INNER
add  t4, t2, zero
add  t2, t3, zero
add  t3, t4, zero
sw   t2, 0(s2)
sw   t3, 4(s2)
addi s2, s2, 4
addi s1, s1, 1
jal  zero, INNER
addi s0, s0, 1
jal  zero, OUTER
addi s6, zero, 1000
lw   s7,  0(s6)
lw   s7,  4(s6)
lw   s7,  8(s6)
lw   s7, 12(s6)
lw   s7, 16(s6)
lw   s7, 20(s6)
lw   s7, 24(s6)
lw   s7, 28(s6)
lw   s7, 32(s6)
lw   s7, 36(s6)
jal  zero, 0