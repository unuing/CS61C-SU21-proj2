.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 32
# =================================================================
argmax:
	bge zero, a1, error
	lw t0, 0(a0)		# int max = arr[0];
	li t1, 0		# int pmax = 0;
	li t2, 1		# int i = 1;
loop:
	bge t2, a1, return
	slli t3, t2, 2
	add t3, a0, t3		# int *p = arr + i;
	lw t3, 0(t3)
	bge t0, t3, continue	# if (*p <= max) { continue; }
	mv t0, t3
	mv t1, t2		# else { max = *p; pmax = i; }
continue:
	addi t2, t2, 1		# i++;
	j loop
error:
	li a1, 32
	j exit2
return:
	mv a0, t1
	ret
