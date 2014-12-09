##################################################################################################
#################### GENERAL NOTES/TASKS #########################################################
# 1. If code commented => still testing
# 2. Format = def sprintf(outbuf, string, arg1, arg2, arg3)
# 3. NEED DONE:
# 	[Xip] %d
# 	[Xip] %u
# 	[Xx] %b
# 	[Xx] %c
# 	[Xx] %s
# 	[Xx] %else
# 	[Xx] non-percent appending to outbuf
##################################################################################################

.data
outbuf: 	.space 250

#string: 	.asciiz "%b"
#arg1: 		.word 28
#arg2: 		.asciiz "American"
#arg3: 		.asciiz "A"

string: 	.asciiz "T1: %d%% of all %ss like the %c letter"
arg1: 		.word 87
arg2: 		.asciiz "American"
arg3: 		.asciiz "A"

#string: 	.asciiz "T2: %d signed = %u unsigned = %bb binary"
#arg1: 		.word -28
#arg2: 		.word 28
#arg3: 		.word 28

#string: 	.asciiz "T3: %c %= %bb %= %s"
#arg1: 		.asciiz "!"
#arg2: 		.asciiz "!"
#arg3: 		.asciiz "How about that?"

print1:		.asciiz "\""
print2:		.asciiz "\" has " 
print3:		.asciiz " letters."
.text
##################################################################################################
################### REFERENCE TABLE FOR REGISTERS ################################################
#
# Initializing these values at zero is more of a formality
#
li $s0, 0								# $s0 used as counter 'i'
li $s1, '%'								# $s1 holds '%' b/c it's used alot
li $s2, 0								# $s2 holds offset for outbuf
li $s3, 0								# $s3 holds offset for $sp
li $s4, 0								# $s4 holds offset for %s string arg
# $t0 is constantly repurposed, mostly used for loading things
# $t1 holds pointer of string[i] byte
# $t2 is where string byte is loaded
##################################################################################################

j main									# start at main()
sprintf:								# my pride and joy
	start:								# start is where loads and inital checks begin
		lw $t0, 16($sp)						# load our outbuf into $t0
		lw $t1, 12($sp)						# load format string into $t1
		add $t1, $t1, $s0					# points to string[i] (string[$s0]) $s0=string offset
		lb $t2, 0($t1)						# loads string[i] into $t2 to be checked
		beq $t2, 0, END						# if string[i] null, program exits
		beq $t2, $s1, switch					# if string[i]==% go to switch 
		add $t0, $t0, $s2					# finds the correct address in outbuf, $s2=outbuf offset
		sw $t2, 0($t0)						# stores our string[i] in that address
		addi $s0, $s0, 1					# updates $s0, which is string offset
		addi $s2, $s2, 4					# updates the outbuf offset value
		li $v0, 11						# loads 11 into $v0 (code for printing characters)
		move $a0, $t2						# moves character to $a0 for printing
		syscall							# issues system call, to print char
		addi $s5, $s5, 1					# character counter
		j start							# goes back to start, to restart checks
	switch: 							# determine which kindof % the byte is, and send it accordingly
		addi $t1, $t1, 1					# goes to string[i+1]
		lb $t2, 0($t1)						# loads string[i+1] into $t2
		li $t6, 'd'						# loads 'd' for checks
		li $t7, 'u'						# loads 'u' for checks
		li $t3, 'b'						# loads 'b' for checks
		li $t4, 'c'						# loads 'c' for checks
		li $t5, 's'						# loads 's' for checks
		beq $t6, $t2, d						# if string[i+1] == 'd', go to 'd' label
		beq $t7, $t2, u						# if string[i+1] == 'u', go to 'u' label
		beq $t3, $t2, bin					# if string[i+1] == 'b', go to 'bin' label
		beq $t4, $t2, c						# if string[i+1] == 'c', go to 'c' label
		beq $t5, $t2, s						# if string[i+1] == 's', go to 's' label
		beq $t2, 0, END						# if string[i+1] == 0, string is over ???? 
		else: 							# if not branched anywhere, falls here
			add $t0, $t0, $s2				# updates outbuf for correct addressing
			sw $t2, 0($t0)					# stores string[i+1] in outbuf address
			addi $s0, $s0, 2				# updates string offset 
			addi $s2, $s2, 4				# updates outbuf offset
			li $v0, 11					# loads 11 into $v0 (code for printing characters)
			move $a0, $t2					# moves character into $a0 for printing
			syscall						# issues system call, to print char
			addi $s5, $s5, 1				# character counter
			j start						# goes back to start, to restart checks
		d: 							# string[i+1] == 'd', comes here
			add $t7, $sp, $s3				# $t7 is pointer to correct argument in stack
			lw $t8, 0($t7)					# loads address of argument into $t8
			lb $t9, 0($t8)					# loads the number from that address, into $t9
			add $t0, $t0, $s2				# updates outbuf for correct addressing
			sw $t9, 0($t0)					# stores number into correct offset address
			addi $s0, $s0, 2				# updates string offset
			addi $s2, $s2, 4				# updates outbuf offset
			addi $s3, $s3, 4				# updates stack offset (how I find the correct arg)
			li $v0, 1					# loads 1 into $v0 (code for printing integers)
			move $a0, $t9					# moves number into $t9, for printing
			syscall						# issues system call, to print integer
			#addi $s5, $s5, 2				# update outbuf counter
			j start						# goes back to start, to restart checks
		u: 							# string[i+1] == 'u', comes here
			add $t7, $sp, $s3				# finds correct argument in stack
			lw $t8, 0($t7)					# loads address of argument into $t8
			lb $t9, 0($t8)					# loads the number from that address, into $t9
			add $t0, $t0, $s2				# updates outbuf for correct addressing
			addi $s0, $s0, 2				# updates string offset
			addi $s2, $s2, 4				# updates outbuf offset
			addi $s3, $s3, 4				# updates stack offset (how I find the correct arg)
			abs $t9, $t9					# takes absolute value of our number
			li $v0, 1					# loads 1 into $v0 (code for printing integers)
			move $a0, $t9					# moves $t9 to $a0 for printing
			syscall						# issues system call, to print integer
			#addi $s5, $s5, 2				# update outbuf counter
			j start						# goes back to start, to restart checks
		bin:							# string[i+1] == 'b', comes here
			add $t7, $sp, $s3				# finds correct argument in stack
			lw $t8, 0($t7)					# loads correct address of argument into $t8
			lb $t9, 0($t8)					# loads number from the address into $t9
			li $t4, 0					# 0 ??
			li $t5, 1					# 1 into mask
			li $t6, 0					# counter for loop
			sll $t5, $t5, 31				# shift mask left to create 32 bit mask
			bin_loop:					# loop that finds each bin digit
				and $t8, $t9, $t5			# ands our number and the mask
				beq $t8, 0, bin_store			# if and-ed number is == 0, store it
				li $t8, 1				# other wise, store 1
			bin_store:					# branch that stores each binary digit
				add $t0, $t0, $s2			# updates outbuf for correct addressing
				sw $t8, 0($t0)				# stores $t8 into outbuf
				sub $t0, $t0, $s2			# resets the outbuf address
				addi $s2, $s2, 4			# updates outbuf offset	
				li $v0, 1				# loads 1 into $v0 (code for printing integers)
				move $a0, $t8				# move $t8 to $a0 for printing
				syscall					# issues system call, to print integer
				#addi $s5, $s5, 1			# update outbuf counter
				li $t8, 0				# reset $t8
				srl $t5, $t5, 1				# shift our mask over once
				addi $t6, $t6, 1			# counter decreased 
				bne $t6, 32, bin_loop			# keep looping until looped 32 times
			addi $s0, $s0, 2				# updates string offset
			addi $s3, $s3, 4				# updates stack offset (how I find the correct arg)
			addi $s4, $zero, 0				# argument offset back to zero, so can be used again					
			j start						# goes back to start, to restart checks	
		c: 							# string[i+1] == 'c', comes here
			add $t7, $sp, $s3				# $t7 is pointer to correct argument in stack
			lw $t8, 0($t7)					# loads address of argument into $t8
			lb $t9, 0($t8)					# loads character into $t9
			add $t0, $t0, $s2				# updates outbuf for correct addressing
			sw $t9, 0($t0)					# stores $t9 character into outbuf address
			addi $s0, $s0, 2				# updates string offset
			addi $s2, $s2, 4				# updates outbuf offset
			addi $s3, $s3, 4				# updates stack offset (how I find the correct arg)
			li $v0, 11					# loads 11 into $v0 (code for printing characters)
			move $a0, $t9					# moves $t9 into $a0 for printing		
			syscall						# issues system call, to print char
			addi $s5, $s5, 1				# update outbuf counter
			j start						# goes back to start, to restart checks
		s: 							# string[i+1] == 's', comes here
			add $t7, $sp, $s3				# finds correct argument in stack
			lw $t8, 0($t7)					# loads argument into $t8
			add $t8, $t8, $s4				# finds correct argument[i]
			lb $t9, 0($t8)					# loads argument[i] into $t9
			beq $t9, 0, exit_s_loop				# if argument[i] == null, leave loop
			s_loop:						# s_loop copies each string character into outbuf
				add $t0, $t0, $s2			# updates outbuf for correct addressing
				sw $t9, 0($t0)				# stores $t9 into outbuf
				sub $t0, $t0, $s2			# resets the outbuf address
				addi $s2, $s2, 4			# updates outbuf offset	
				addi $s4, $s4, 1			# updates argument offset
				addi $s5, $s5, 1			# update outbuf counter
				li $v0, 11				# loads 11 into $v0 (code for printing characters)
				move $a0, $t9				# moves $t9 into $a0 for printing
				syscall					# issues system call, to print char
				j s					# back to 's' to continue grabbing string[i]
			exit_s_loop:					# done with string, must do exit sequence
				addi $s0, $s0, 2			# updates string offset
				addi $s3, $s3, 4			# updates stack offset (how I find the correct arg)
				addi $s4, $zero, 0			# argument offset back to zero, so can be used again
				j start					# goes back to start, to restart checks
	END:								# for any ending procedures, and returning
		move $v1, $s5						# move outbuf counter to $v1
		addi $sp, $sp, 24					# return $sp
		jr $ra							# return to main
main:									# starting place
	addi $sp, $sp, -24						# 24 stack spaces, for arguments and $ra
	sw $ra, 20($sp)							# $ra saved at 20
	la $t0, outbuf							# load outbuf in $t0
	sw $t0, 16($sp)							# outbuf saved at 16
	la $t0, string							# load format string in $t0
	sw $t0, 12($sp)							# format string saved at 12
									# arguments are set up in a way, so they can sequentially be accessed of the stack.
	la $t0, arg3 							# load 3rd argument in $t0
	sw $t0, 8($sp)							# 3rd argument saved at 8
	la $t0, arg2							# load 2nd argument in $t0
	sw $t0, 4($sp)							# 2nd argument saved at 4
	la $t0, arg1							# load 1st argument in $t0
	sw $t0, 0($sp)							# 1st argument saved at 0
	li $v0, 4							# loads $v0 for printing string
	la $a0, print1							# loads $a0 with 1st print statement
	syscall								# issues system call for printing
	jal sprintf							# begin sprintf
	li $v0, 4							# loads $v0 for printing string
	la $a0, print2							# loads $a0 with 2nd print statement
	syscall								# issues system call for printing
	li $v0, 1							# loads $v0 for printing integer
	move $a0, $v1							# moves returned outbuf counter into $a0
	syscall								# issues system call for printing
	li $v0, 4							# loads $v0 for printing string
	la $a0, print3							# loads $a0 with 3rd print statement
	syscall								# issues system call for printing
