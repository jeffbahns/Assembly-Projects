.data
outbuf: 	.space 250
string: 	.asciiz "%d"
arg1: 		.word -15
arg2: 		.word 15
arg3: 		.asciiz "JEFF"
.text

##########################################################################
################### REFERENCE TABLE FOR REGISTERS ########################
# $s0 used as counter 'i'
li $s0, 0
# $s1 holds '%' b/c it's used alot
li $s1, '%'
# $s2 holds offset for outbuf
li $s2, 0
# $s3 holds offset for $sp 
li $s3, 0
# $s4 holds offset for %s string arg
li $s4, 0
# $t0 is constantly repurposed, mostly used for loading things
# $t1 holds pointer of string[i] byte
# $t2 is where string byte is loaded
# $s5 is testing for non %
# %s6 tests for percents with non functional following
# %s7 tests for % functions
##########################################################################


##########################################################################
#################### GENERAL NOTES/TASKS #################################
# 1. If code commented => still testing
# 2. Format = def sprintf(outbuf, string, arg1, arg2, arg3)
# 3. NEED DONE:
# 	[X(?)] %d
# 	[] %u
# 	[] %b
# 	[X] %c
# 	[X] %s
# 	[X] %else
# 	[X] non-percent appending to outbuf
##########################################################################


# main gets the party started
li $v0, 11
j main
sprintf:
	# grabbing shit from the stack
	
	start:
		lw $t0, 16($sp)
		lw $t1, 12($sp)
		# loading string[i]
		add $t1, $t1, $s0
		lb $t2, 0($t1)
	
		# if null>exit, if '%'>switch, if neither>go to else
		beq $t2, 0, EXIT
		beq $t2, $s1, switch
	
		# if not percent, store to outbuf
		add $t0, $t0, $s2
		sw $t2, 0($t0)
		addi $s2, $s2, 4
		addi $s0, $s0, 1
		
		move $a0, $t2
		#syscall
		#addi $s5, $s5, 1
		j start
	
	switch: # determine which kindof % the byte is, and send it accordingly
		addi $t1, $t1, 1
		lb $t2, 0($t1)
		li $t6, 'd'
		li $t7, 'u'
		li $t3, 'b'
		li $t4, 'c'
		li $t5, 's'
		beq $t6, $t2, d
		beq $t7, $t2, u
		beq $t3, $t2, bee
		beq $t4, $t2, c
		beq $t5, $t2, s
		beq $t2, 0, EXIT
		
		else: # if not branched anywhere, falls here
			add $t0, $t0, $s2
			sw $t2, 0($t0)
			addi $s2, $s2, 4
			addi $s0, $s0, 2
			
			move $a0, $t2
			#syscall
			#addi $s6, $s6, 1
			
			j start
		d: # %d
			add $t7, $sp, $s3
			lw $t8, 0($t7)
			lw $t9, 0($t8)
			add $t0, $t0, $s2
			addi $s2, $s2, 4
			sw $t9, 0($t0)
			addi $s0, $s0, 2
			j start
		u: # %u
			addi $s7, $s7, 1
			addi $s0, $s0, 2
			j start
		bee: # %b
			addi $s7, $s7, 1
			addi $s0, $s0, 2
			j start
		c: # %c
			add $t7, $sp, $s3
			lw $t8, 0($t7)
			lb $t9, 0($t8)
			
			add $t0, $t0, $s2
			sw $t9, 0($t0)
			addi $s3, $s3, 4
			addi $s2, $s2, 4
			
			move $a0, $t9
			#syscall
			
			addi $s0, $s0, 2
			j start
		s: # %s  string[$s4]  sp[$s3]
			add $t7, $sp, $s3
			lw $t8, 0($t7)
			add $t8, $t8, $s4
			lb $t9, 0($t8)
			
			beq $t9, 0, exit_s_loop
			
			s_loop:	
				add $t0, $t0, $s2
				sw $t9, 0($t0)
				sub $t0, $t0, $s2
				addi $s2, $s2, 4
				addi $s4, $s4, 1
				addi $s7, $s7, 1
				move $a0, $t9
				#syscall
				j s
			exit_s_loop:
				addi $s0, $s0, 2
				addi $s3, $s3, 4
				addi $s4, $zero, 0
				j start

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
	jal sprintf
EXIT:
	# ignore this shit. just output testing to make sure im doing things correctly
	la $t7, outbuf
	li $v0, 1
	looper:
		
		lb $a0, 0($t7)
		beq $a0, 0, exiter
		addi $t7, $t7, 4
		syscall
		j looper
	exiter:
		##
