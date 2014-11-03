.data
array0: .word 1, -15, 100, 12, 37, 44, -6, -20, 104

.text
j main
	POSNEG:
	beq $t0, $a1, EXIT 		# $t0 is loop counter, (i=0)
	# gets me array[i]
	sll $t1, $t0, 2			# $t1 is the offset ('i' shifted left twice)
	add $t2, $a0, $t1 		# $t2 is pointer, to array[i]
	lw $t1, 0($t2) 			# $t1 lastly holds array[i] value, (multipurposed!)
	# finds array[i] % 2
	li $t3, 2			# $t3 = modulus helper
	div $t1, $t3
	mfhi $t3
	addi $t0, $t0, 1		# i++
	# array[i] % 2 == 0?
	beqz $t3, POSCHECK 		# if remainder is == 0: go to check for positives
	bltz $t3 NEGCHECK 		# if remainder is == 1: go to check for negatives
	j POSNEG
	POSCHECK:			# takes even array values and checks for being positive
		bltz $t1, POSNEG
		add $v0, $v0, $t1
		j POSNEG
	NEGCHECK:			# takes odd array values and checks for being negative
		bgtz $t1, POSNEG
		add $v1, $v1, $t1
		j POSNEG
	EXIT:
		jr $ra
##################################################
main:
	la $a0, array0
	li $a1, 9
	jal POSNEG
