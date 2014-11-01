.data
array0: .word 1, -15, 100, 12, 37, 44, -6, -20, 104

.text
j main

POSNEG: 
	beq $t0, $a1, EXIT		# $t0 is loop counter, (i=0) 
	
	# gets me array[i]
	li $t1, 4			# $t1 first is offset multiplier = 4
	mult $t0, $t1			# i * 4
	mflo $t1			# $t1 becomes offset
	add $t2, $a0, $t1		# $t2 is pointer, to array[i]
	lw $t1, 0($t2)			# $t1 lastly holds array[i] value, (multipurposed!)
	
	# finds array[i] % 2 
	li $t3, 2			# $t3 = modulus helper
	div $t1, $t3
	mfhi $t3
	
	addi $t0, $t0, 1		# i++
	
	# array[i] % 2 == 0?
	beqz $t3, POSCHECK		# if remainder is == 0: go to check for positives
	bltz  $t3  NEGCHECK		# if remainder is == 1: go to check for negatives

	j POSNEG
	
	POSCHECK:
		bltz $t1, POSNEG
		add $v0, $v0, $t1
		j POSNEG

	NEGCHECK:
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

# psuedo nesty nests
# for i < 8:
	# if array0[i] negative:
		# if array0[i] odd:
			# negtotal += array0[i]
	# if array0[i] positive:
		# if array0[i]:
			# postotal += array0[i]
