.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 48
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 64
# - If you receive an fread error or eof,
#   this function terminates the program with error code 66
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 65
# ==============================================================================
read_matrix:
	addi sp, sp, -32
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)			# s3 stores the file descripter
	sw s4, 20(sp)			# s4 stores the number of elements in the matrix
	sw s5, 24(sp)			# s5 stores the pointer to the matrix in memory
	sw s6, 28(sp)

	mv s0, a0
	mv s1, a1
	mv s2, a2
open_file:
	mv a1, s0
	li a2, 0
	jal fopen
	li t0, -1
	beq a0, t0, fopen_error
	mv s3, a0
read_rows:
	mv a1, s3
	jal read_word
	sw a0, 0(s1)
	mv s4, a0
read_cols:
	mv a1, s3
	jal read_word
	sw a0, 0(s2)
	mul s4, s4, a0
allocate_space:
	slli a0, s4, 2
	jal malloc
	beqz a0, malloc_error
	mv s5, a0

	mv s6, s5
read_mat_loop:
	beqz s4, end
	mv a1, s3
	jal read_word
	sw a0, 0(s6)
	addi s6, s6, 4
	addi s4, s4, -1
	j read_mat_loop

end:
	mv a1, s3
	jal fclose
	bnez a0, fclose_error
	mv a0, s5
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	lw s5, 24(sp)
	lw s6, 28(sp)
	addi sp, sp, 32
	ret


# Arguments: a1: file descripter
# Returns: a0: the word been read
read_word:
	addi sp, sp, -8
	sw ra, 4(sp)
	mv a2, sp
	li a3, 4
	jal fread
	li t0, 4
	bne a0, t0, fread_error
	lw a0, 0(sp)
	lw ra, 4(sp)
	addi sp, sp, 8
	ret


malloc_error:
	li a1, 48
	j exit2
fopen_error:
	li a1, 64
	j exit2
fread_error:
	li a1, 66
	j exit2
fclose_error:
	li a1, 65
	j exit2

