.globl classify

.text
classify:
	# =====================================
	# COMMAND LINE ARGUMENTS
	# =====================================
	# Args:
	#   a0 (int)    argc
	#   a1 (char**) argv
	#   a2 (int)    print_classification, if this is zero, 
	#               you should print the classification. Otherwise,
	#               this function should not print ANYTHING.
	# Returns:
	#   a0 (int)    Classification
	# Exceptions:
	# - If there are an incorrect number of command line args,
	#   this function terminates the program with exit code 35
	# - If malloc fails, this function terminates the program with exit code 48
	#
	# Usage:
	#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
	li t0, 5
	bne a0, t0, error35

	addi sp, sp, -52
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)			# stores the number of rows in m0
	sw s4, 20(sp)			# the number of columns in m0
	sw s5, 24(sp)			# pointer to m0
	sw s6, 28(sp)			# number of rows in m1
	sw s7, 32(sp)			# number of columns in m1
	sw s8, 36(sp)			# pointer to m1
	sw s9, 40(sp)			# number of rows in the input matrix
	sw s10, 44(sp)			# number of columns in the input matrix
	sw s11, 48(sp)			# pointer to the input matrix

	mv s0, a0
	mv s1, a1
	mv s2, a2

	# =====================================
	# LOAD MATRICES
	# =====================================
	# Load pretrained m0
	lw a0, 4(s1)
	addi sp, sp, -8
	mv a1, sp
	addi a2, sp, 4
	jal read_matrix
	lw s3, 0(sp)
	lw s4, 4(sp)
	mv s5, a0
	addi sp, sp, 8
	# Load pretrained m1
	lw a0, 8(s1)
	addi sp, sp, -8
	mv a1, sp
	addi a2, sp, 4
	jal read_matrix
	lw s6, 0(sp)
	lw s7, 4(sp)
	mv s8, a0
	addi sp, sp, 8
	# Load input matrix
	lw a0, 12(s1)
	addi sp, sp, -8
	mv a1, sp
	addi a2, sp, 4
	jal read_matrix
	lw s9, 0(sp)
	lw s10, 4(sp)
	mv s11, a0
	addi sp, sp, 8
	
	# =====================================
	# RUN LAYERS
	# =====================================
	# 1. LINEAR LAYER:    m0 * input
	mul a0, s3, s10
	slli a0, a0, 2
	jal malloc
	beqz a0, error48
	mv t0, a0
	addi sp, sp, -4
	sw t0, 0(sp)
	mv a0, s5
	mv a1, s3
	mv a2, s4
	mv a3, s11
	mv a4, s9
	mv a5, s10
	mv a6, t0
	jal matmul
	# free input and m0
	mv a0, s5
	jal free
	mv a0, s11
	jal free

	lw t0, 0(sp)
	addi sp, sp, 4
	# 2. NONLINEAR LAYER: ReLU(m0 * input)
	addi sp, sp, -4
	sw t0, 0(sp)
	mv a0, t0
	mul a1, s3, s10
	jal relu
	lw t0, 0(sp)
	addi sp, sp, 4
	# 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
	addi sp, sp, -8
	sw t0, 0(sp)

	mul a0, s6, s10
	slli a0, a0, 2
	jal malloc
	beqz a0, error48
	mv t1, a0

	sw t1, 4(sp)
	mv a0, s8
	mv a1, s6
	mv a2, s7
	lw t0, 0(sp)
	mv a3, t0
	mv a4, s3
	mv a5, s10
	mv a6, t1
	jal matmul
	lw t0, 0(sp)
	lw t1, 4(sp)
	addi sp, sp, 8

	# free t0
	addi sp, sp, -4
	sw t1, 0(sp)
	mv a0, t0
	jal free
	# free m1
	mv a0, s8
	jal free
	lw t1, 0(sp)
	addi sp, sp, 4

	# =====================================
	# WRITE OUTPUT
	# =====================================
	# Write output matrix
	addi sp, sp, -4
	sw t1, 0(sp)
	lw a0, 16(s1)
	mv a1, t1
	mv a2, s6
	mv a3, s10
	jal write_matrix
	lw t1, 0(sp)
	addi sp, sp, 4

	# =====================================
	# CALCULATE CLASSIFICATION/LABEL
	# =====================================
	# Call argmax
	addi sp, sp, -4
	sw t1, 0(sp)
	mv a0, t1
	mul a1, s6, s10
	jal argmax
	mv t2, a0
	lw t1, 0(sp)
	addi sp, sp, 4
	# Print classification
	bnez s2, end
	addi sp, sp, -4
	sw t1, 0(sp)
	mv a1, t2
	jal print_int
	# Print newline afterwards for clarity
	li a1, '\n'
	jal print_char
	lw t1, 0(sp)
	addi sp, sp, 4
end:
	# free t1
	mv a0, t1
	jal free
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	lw s5, 24(sp)
	lw s6, 28(sp)
	lw s7, 32(sp)
	lw s8, 36(sp)
	lw s9, 40(sp)
	lw s10, 44(sp)
	lw s11, 48(sp)
	addi sp, sp, 52
	ret


error35:
	li a1, 35
	j exit2
error48:
	li a1, 48
	j exit2

