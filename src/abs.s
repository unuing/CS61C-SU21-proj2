.globl abs

.text
# =================================================================
# FUNCTION: Given an int return its absolute value.
# Arguments:
# 	a0 (int) is input integer
# Returns:
#	a0 (int) the absolute value of the input
# =================================================================
abs:
    srai t0, a0, 31
    xor t1, a0, t0
    sub a0, t1, t0
    ret
