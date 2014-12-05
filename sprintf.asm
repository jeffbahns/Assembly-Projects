.data
outbuf:		.space 250
string:		.asciiz "hi"
arg1:		.asciiz "Argument1"
arg2:		.asciiz "Agrument 2"
arg3:		.asciiz "Argument 3"


.text
##########################################################################
################### REFERENCE TABLE FOR REGISTERS ########################
# $s0 used as counter 'i'
li $s0, 0
# $s1 holds '%' b/c it's used alot
li $s1, '%'
# $s2 holds offset for outbuf
# $t0 is constantly repurposed, mostly used for loading things 
# $t1 holds location of string[i]
# $t2 is where string[i] is loaded
##########################################################################

##########################################################################
#################### GENERAL NOTES/TASKS #################################
# 1. If code commented => still testing
# 2. Format = def sprintf(outbuf, string, arg1, arg2, arg3)
# 3. NEED DONE:
#	[] %d
#	[] %u
#	[] %b
#	[] %c
#	[] %s
#	[] %else
##########################################################################

# main gets the party started
j main

sprintf:
	# grabbing shit from the stack
	lw $t0, 16($sp)
	lw $t1, 12($sp)
	#lw $t2, 8($sp)
	#lw $t3, 4($sp)
	#lw $t4, 0($sp)
	
	# loading string[i]
	add $t1, $t1, $s0
	lb $t2, 0($t1)
	
	# initial % checkk, either goes to branch or goes back to sprintf, for next byte
	beq $s0, 9, EXIT
	beq $t2, $s1, switch
	addi $s0, $s0, 1
	j sprintf
	
	switch:	# determine which kindof % the byte is, and send it accordingly
		addi $t1, $t1, 1
		lb $t2, 0($t1)
		li $t0, 'd'
		li $t1, 'u'
		li $t3, 'b'
		li $t4, 'c'
		li $t5, 's'
		beq $t0, $t2, d
		beq $t1, $t2, u
		beq $t3, $t2, bee
		beq $t4, $t2, c
		beq $t5, $t2, s
		beq $t2, 0, null
		
		null:	# if byte == 0, or 'null'
			addi $s0, $s0, 2
			j sprintf
		else:	# if not branched anywhere, falls here
			addi $s6, $s6, 1
			addi $s0, $s0, 2
			j sprintf
		d:	# %d
			addi $s7, $s7, 1
			addi $s0, $s0, 2
			j sprintf
		u:	# %u
			addi $s7, $s7, 1
			addi $s0, $s0, 2
			j sprintf
		bee:	# %b
			addi $s7, $s7, 1
			addi $s0, $s0, 2
			j sprintf
		c:	# %c
			addi $s7, $s7, 1
			addi $s0, $s0, 2
			j sprintf
		s:	# %s
			addi $s7, $s7, 1
			addi $s0, $s0, 2
			j sprintf
			
main:
	# stack saving bidness
	
	# $t0 is used to constantly loading things and storing them.
	# i store everything to the stack directly after loading, and $t0 continually is reused 
	addi $sp, $sp, -24
	sw $ra, 20($sp)
	la $t0, outbuf
	sw $t0, 16($sp)
	la $t0, string
	sw $t0, 12($sp)
	
	# arguments are set up in a way, so they can sequentially be pushed off of the stack.
	la $t0, arg3
	sw $t0, 8($sp)
	la $t0, arg2
	sw $t0, 4($sp)
	la $t0, arg1
	sw $t0, 0($sp)
	#jal sprintf
	
EXIT:
	# ignore this shit. just output testing to make sure im doing things correctly
	la $t7, outbuf
	li $v0, 11
	
	lb $a0, 0($t7)
	#syscall
	lb $a0, 4($t7)
	#syscall
	lb $a0, 8($t7)
	#syscall
	lb $a0, 12($t7)
	#syscall
	la $t7, string
	lb $a0, 2($t7)
	syscall
