.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 32
# ==============================================================================
relu:
	bge zero, a1, error
loop:
	beq a1, zero, return
	lw t0, 0(a0)
	bge t0, zero, remain
	sw zero, 0(a0)
remain:
	addi a0, a0, 4
	addi a1, a1, -1
	j loop
error:
	li a1, 32
	j exit2
return:
	ret
