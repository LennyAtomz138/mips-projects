#	Lab 3 #	Recursive Fibonacci function

.data				#data segment
	name:	.asciiz 		"CSE3666: Lab 3: Your Name(Your NetID)\nEnter an integer:"
	msg0:	.asciiz 		"F(%d) cannot be computed.\n"
	msg1:	.asciiz 		"F(%d) = (%d)\n"		

	.align 2
	buffer:	.space 8		# reserve space for two words 
	n_in:	.space 4		# get input from the user

	.text				# Code segment
	.globl	main			# declare main to be global

main:		
	la	$a0, name
	jal	printf			# call printf function

	li	$s0, 49
	li	$v0, 5			# read an integer
	syscall

	# Check if user input is negative
	addi $s7, $0, 46
	sgt  $s5,$v0, $s7
	bne  $s5, $0, Error
	slti $s5, $v0, 1		# If user input is negative, $s5 = 1, elseif user input is positive, $s5 = 0
	bne  $s5, $0, Error	# If $s5 = 1, user input is negative, so branch to Neg procedure

	# If user input is not negative, it should make it through this point
	move	$s0, $v0			# save the user input
	
	la	$s1, buffer		# buffer

	#call jal
	addi	$a0, $s0, -1
	move	$a1, $s1			# set the 2nd argument	
	jal 	Fibonacci2
l_ok:
	la	$a0, msg1
	move	$a1, $s0	
	move	$a2, $v0
	jal	printf

Exit:	
	li	$v0,10			# System call, type 10, standard exit
	syscall				# ...and call the OS

Error:
	add $a1, $v0, $0		# Put user's negative input into $s6 for use
	la  $a0, msg0
	jal	printf			# Print "F(%d) cannot be computed.\n"
	j 	Exit				# Jump to Exit program

# Fibonacci2(n, p)
# Used registers	
Fibonacci2:
	addi	$sp, $sp, -12	# Make space for 3 items (3*4 = 12)
	sw	$a0, 0($sp)		# Store $a0 into S[0]
	sw  $a1, 4($sp)		# Store $a1 into S[1]
	sw	$ra, 8($sp)		# Preserve Return Address
	slti	$t0, $a0, 2		# If ($a0<2) return $t0 = 1; else return $t0 = 0
	beq	$t0, $0, Else	# While ($t0 = 0) Branch to Else;
	addi	$v0, $a0, 0		# $v0 = $a0
	j	ExitLoop			
	
Else:
	addi	$a0, $a0, -1		# Store a-1 in $a0
	jal Fibonacci2
	addi	$a1, $v0, 0		# Move $v0 to $s1
	addi	$a0, $a0, -1		# Store a-2 in $a0
	jal Fibonacci2
	
	add $s2, $v0, $0	# Store p[0] in $s3 register for use in overflow check
	# Conduct overflow check
	addu $v0, $v0,$a1	# $s1 = $s1 + $v0
	xor  $s3, $v0, $s2	# XOR used here
	slt  $s4, $s3, $s2	# If result is negative, there's a problem
	bne  $s4, $0, Error	# Branch to error message if result is negative	
	
ExitLoop:
	lw 	$a0, 0($sp)
	lw	$a1, 4($sp)
	lw	$ra, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra
