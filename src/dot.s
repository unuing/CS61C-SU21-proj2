.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 32
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 33
# =======================================================
dot:
	bge zero, a2, error32
	bge zero, a3, error33
	bge zero, a4, error33
	li t0, 0		# int sum = 0;
	li t1, 0		# int i = 0;
	slli a3, a3, 2
	slli a4, a4, 2		# calculate the stride in bytes
loop:
	bge zero, a2, return	# if (length <= 0) { break; }
	lw t2, 0(a0)		# int ai = *a;
	lw t3, 0(a1)		# int bi = *b;
	mul t2, t2, t3
	add t0, t0, t2		# sum += ai * bi;
	add a0, a0, a3		# a++;
	add a1, a1, a4		# b++;
	addi a2, a2, -1		# length--;
	j loop
error32:
	li a1, 32
	j exit2
error33:
	li a1, 33
	j exit2
return:
	mv a0, t0
	ret
