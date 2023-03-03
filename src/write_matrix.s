.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 64
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 67
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 65
# ==============================================================================
write_matrix:
	addi sp, sp, -24
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)

	mv s0, a1
	mv s1, a2
	mv s2, a3
open_file:
	mv a1, a0
	li a2, 1
	jal fopen
	li t0, -1
	beq a0, t0, fopen_error
	mv s3, a0
write_rows:
	addi sp, sp, -4
	sw s1, 0(sp)
	mv a1, s3
	mv a2, sp
	li a3, 1
	li a4, 4
	jal fwrite
	li t0, 1
	bne a0, t0, fwrite_error
write_cols:
	sw s2, 0(sp)
	mv a1, s3
	mv a2, sp
	li a3, 1
	li a4, 4
	jal fwrite
	li t0, 1
	bne a0, t0, fwrite_error
	addi sp, sp, 4

	mul s4, s1, s2
loop:
	beqz s4, end
	mv a1, s3
	mv a2, s0
	li a3, 1
	li a4, 4
	jal fwrite
	li t0, 1
	bne a0, t0, fwrite_error
	addi s0, s0, 4
	addi s4, s4, -1
	j loop
end:
	mv a1, s3
	jal fclose
	bnez a0, fclose_error
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	addi sp, sp, 24
	ret


fopen_error:
	li a1, 64
	j exit2
fwrite_error:
	li a1, 67
	j exit2
fclose_error:
	li a1, 65
	j exit2
