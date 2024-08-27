#	Lab 4: Recursive Factorial function
#	Due: 7 NOV 2018 by 2359

	.data				#data segment
name:	.asciiz "CSE3666: Lab 4: Lenny Adams(lla14001)\n"
msg0:	.asciiz "%d! cannot be computed.\n"
msg1:	.asciiz "%d! = (%x %x)\n"		
msg2:	.asciiz "%u in decimal.\n"	

	.align 2
buffer: .space 8		# reserve space for two words 
n_in:	.space 4		# get input from the user

	.text			# Code segment
	.globl	main		# declare main to be global

main:		
	la	$a0, name
	jal	printf		# call printf function

	li	$s0, 49
	li	$v0, 5		#read an integer
	syscall
	move	$s0, $v0		#save the user input

	
	la	$s1, buffer	# buffer

	# Call Factorial2
	move	$a0, $s0 	#save n to $s0
	move	$a1, $s1

	# Checks for bad input
	addi	$t0, $0, 21
	sge	$t1, $a0, $t0
	bnez	$t1, noCan
	bltz	$a0, noCan

	jal 	Factorial2
	bne	$v0, $zero, l_ok

	# 0 is returned
noCan:
	la	$a0,msg0		# $a0 := address of message 1
	move	$a1, $s0		# the number
	jal	printf
	j	Terminate
	
l_ok:
	la	$a0, msg1
	move	$a1, $s0		
	lw	$a2, 0($s1)
	lw	$a3, 4($s1)
	jal	printf

	lw	$a2, 0($s1)
	bne	$a2, $0, Terminate
	
	la	$a0, msg2
	lw	$a1, 4($s1)
	jal	printf

Terminate:
	li	$v0,10			# System call, type 10, standard exit
	syscall				# ...and call the OS
# Factorial2(n, p)
#	Saved registers
#	$ra, $a0 = n (user input), $a1(base addr ptr)
#	(do not assume $a1 is not changed)
Factorial2:
	# Save the 3 registers by manipulating stack pointer
	addi	$sp, $sp, -12 	# Make space for the 3 items
	sw	$ra, 8($sp)		# Store $ra into Stack[2]
	sw	$a0, 4($sp)		# Store $a0 into Stack[1]
	sw	$a1, 0($sp)		# Store $a1 into Stack[0]
	
	# Establish the base case
	beq	$a0, 0, Exit1	# if(n==1) -> branch to base case
	
	# r = Factorial2(n - 1, p)
	# 1) Prepare the arguments
	addi	$a0, $a0, -1		# Now $a0 = n - 1
	jal	Factorial2
	# Now test $v0 (r) == 0
	
	# Saving contents for later use
	lw	$ra, 8($sp)
	lw	$a0, 4($sp) 
	lw	$a1, 0($sp)
	
	beq	$v0, $0, Exit0	# Error encountered
	
	# Load $t0 = p[0]
	lw	$t0, 0($a1)
	# Load $t1 = p[1]
	lw	$t1, 4($a1)
	
	# ($t2, $t3) = $t1 * n
	mult	$t1, $a0
	mfhi	$t2
	mflo	$t3
	# ($t4, $t5) = $t0 * n
	mult	$t0, $a0
	mfhi	$t4
	mflo	$t5
	
	# Check: if (t4 != 0) go to Exit0
	# if (t4 != 0) -> Overflow error
	bne	$t4, $0, Exit0
	
	# Compute the new higher half
	# $t6 = $t2 + $t5
	addu	$t6, $t2, $t5
	
	# Check: if (overflow == True) go to Exit 0
	# Implies that an error was encountered
	# if $t6 < 0 -> overflow error
	slti	$t7, $t6, 0	
	bne	$t7, $0, Exit0
	
	# p[0] = $t6
	sw	$t6, 0($a1)
	# p[1] = $t3
	sw	$t3, 4($a1)
	
	addi	$sp,$sp, 12
	j	Exit

Exit1:
	sw	$0, 0($a1)	# p[0] = 0
	addi	$s2, $0, 1	# IOT load 1 into p[1]
	sw	$s2, 4($a1)	# p[1] = 1
	# return value = 1
	addi	$v0, $0, 1	# $v0 = 1
	addi	$sp, $sp, 12	# Fix up the stack pointer
	j	Exit
	
Exit0:
	# return value = 0
	addi	$v0, $0, 0	# $v0 = 0
	
Exit:	
	
	jr $ra
