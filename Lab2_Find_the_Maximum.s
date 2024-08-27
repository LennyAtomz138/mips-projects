# 26 SEP 2018, CSE 3666, Find the Maximum, Due: 10 OCT 2018 by 2359

# IOT store variables in RAM:
.data

	# The following two strings are used in print_array function:
	nl:			.asciiz "\n"		#ASCII for a new line
	separator:	.asciiz ":"		#string that seprates index from number 

	name:		.asciiz "CSE3666: Lab 2: Leonard Adams III (lla14001)\n\n"

	msg1:		.asciiz "The function returned "
	msg2:		.asciiz "\nThe maximum value is "
	msg3:		.asciiz "\nThe address of the word is "

	.align 2					# important for words
	buffer:	.space 4096		# allocate space for 1K words

# IOT store instructions in Memory:
.text				# Code segment
	.globl	main		# declare main to be global so that it may be referenced by other files

# Declare the main procedure:
main:
 	
 	# Store $s0 into Stack[0]:
	addi	$sp, $sp, -4	# allocate space on the stack for $s0
	sw	$s0, ($sp)	# save $s0

	# 2^10 = 1024; 4096/16 = 256; 4096/4 = 1024; 2^8 = 256...
	# How do these relate to next instruciton?
	# Set $s0 to 16-bit immediate (sign-extended) of the value 16:
	li	$s0, 16		# specify the size of the array, must be less than 1024

	la	$a0, name	# load the address of "name" into $a0
	li	$v0, 4		# system call, type 4, print a string, *$a0
	syscall			# Instruct OS to print name to screen

	# Function call process.
	# 1) Load size of buffer (4096) into argument register $a0.
	# 2) Move $s0 contents into $a1 for use within init_array function.
	# 3) Jump And Link to the procedure init_array
	la	$a0, buffer	# buffer of 4096 bytes stored in $a0
	move	$a1, $s0		# buffer of 16 bytes is now stored in $a1	
	jal	init_array	# initialize the array with random values

	la	$s4, buffer	# storing base address in $s4 ***NOTE***
	
	la	$a0, buffer	
	move	$a1, $s0		# buffer is now in $a1
	jal	print_array 	# call print. You can comment it out.

	# Call your find_max function.
	# You need to prepare the arguments to the function.
	add	$a0, $s4, $0	# $a0 gets base address		*** NOTE all between asterisks
	add	$a1, $s0, $0	# $a1 gets number of array elements
	addi	$a2,  $0, 1	# $a2 gets i, starting at 1
	add	$a3,  $0, $0	# $a3 gets maxi, initialized to 0
	jal	find_max 	# call find_max
	add	$t0, $v0, $0	# saving maxi to $t0
	add	$t1, $s4, $0	# saving base address to $t1 ***
	
	# Add code to print the results
	# print the returned value
	la	$a0, msg1	# print mssage 1 -> "The function returned "
	li	$v0, 4
	syscall
	# Print integer result
	add	$a0, $t0, $0	# print integer in $t0 (maxi)
	li	$v0, 1		# syscall 1 = print decimal
	syscall
	
	# Print the maximum value
	la	$a0, msg2	# print mssage 2 -> "\nThe maximum value is "
	li	$v0, 4
	syscall
	sll	$t2, $t0, 2	# $t2 now holds offset of the array that points to max
	add	$t1, $t1, $t2	# $t1 gets address of max element
	lw	$t3, ($t1)	# $t3 gets maxi value
	la	$a0, ($t3)	# print integer in maxi
	li	$v0, 1		# syscall 1 = print decimal
	syscall 
	

	# Print the address of the value (in hex).
	la	$a0, msg3	# print mssage 3 -> "\nThe address of the word is "
	li	$v0, 4
	syscall
	la	$a0, ($t3)
	li	$v0, 34
	syscall

	la	$a0, nl		# print end of line
	li	$v0, 4
	syscall

	# Restore  $s0. You can check $sp here to make sure the stack is maintained correctly. 
	lw	$s0, ($sp)	# load $s0
	addi	$sp, $sp, 4	# restore $sp

Exit:	
	li	$v0, 10		# System call, type 10, standard exit
	syscall			# ...and call the OS

# Your implementation of find_max:
	#-------------------------------#
	# $a0 = base address of array
	# $a1 = size of array
	# $a2 = counter i (starts at 1)
	# $a3 = index maxi (starts at 0)
	#-------------------------------#
find_max: 
	add	$t0, $a0, $0		# $t0 = base address
	add	$t1, $a1, $0		# $t1 = size of array (16 in shell code)
	add	$t2, $a2, $0		# $t2 = i, starts at 1
	add	$t3, $a3, $0		# $t3 = maxi, starts at 0

fmLOOP:
	sll	$t6, $t3, 2		# $t6 gets maxi offset
	add	$t6, $t0, $t6	# put address of maxi in $t6
	lw	$t5, ($t6)		# $t5 gets maxi of array
	sll	$t6, $t2, 2		# $t6 gets i*4, the offset
	add	$t6, $t0, $t6	# put new address in $t6
	lw	$t7, ($t6)		# $t7 gets i element in array
	slt	$t8, $t7, $t5	# $t8 gets 1 if (maxi element < i element) 
	#----------# LINE 95 CAN CHANGE TO sltu TO FIND_MAXU #-----------#
	bne	$t8, $0, false	# maxi element is < i element
	add	$t3, $t2, $0		# setting new maxi to i
false:	addi	$t2, $t2, 1	# increment i
	slt	$t4, $t2, $t1	# $t4 gets 1 when i < array.length
	bne	$t4, $0, fmLOOP	# loop until i = array.length
fmDONE:	add	$v0, $t3, $0	# setting return value to maxi
    jr $ra      			# return to calling routine

# Your implementation of find_maxu:
find_maxu: 
	#------------------------------------------#
	# $a0 = base address of array
	# $a1 = size of array
	# $a2 = counter i (starts at 0)
	# $a3 = index maxi (starts at 0)
	#------------------------------------------#
	add	$t0, $a0, $0	# $t0 = base address
	add	$t1, $a1, $0	# $t1 = size of array (16 in shell code)
	add	$t2, $a2, $0	# $t2 = i, starts at 1
	add	$t3, $a3, $0	# $t3 = maxi, starts at 0

fmUnsignedLOOP:
	sll	$t6, $t3, 2	# $t6 gets maxi offset
	add	$t6, $t0, $t6	# put address of maxi in $t6
	lw	$t5, ($t6)	# $t5 gets maxi of array
	sll	$t6, $t2, 2	# $t6 gets i*4, the offset for ith element
	add	$t6, $t0, $t6	# put new address in $t6
	lw	$t7, ($t6)	# $t7 gets ith element in array
	sltu	$t8, $t7, $t5	# $t8 gets 1 if maxi element < i element
	bne	$t8, $0, unsignedFalse	# maxi element is < i element so skip next instruction
	add	$t3, $t2, $0	# setting new maxi to i
unsignedFalse:
	addi	$t2, $t2, 1	# increment i
	slt	$t4, $t2, $t1	# $t4 gets 1 when i < array.length
	bne	$t4, $0, fmUnsignedLOOP	# loop until i = array.length
	add	$v0, $t3, $0	# setting return value to maxi
	jr	$ra
      
##### No need to change anything below

# void init_array(int *p, int n)
init_array:
	li	$t0, 214013
	li	$t1, 2531011
	li	$t3, 12345		# seed for random sequence
	b	ll_lpinit_test	# Branch to label ll_lpinit_test

ll_lpinit:
	mul	$t3, $t3, $t0	# $t3 = 12345 * 214013 returns HUGE number -> -1652976811
	addu	$t3, $t3, $t1	# $t3 = -1652976811 + 2531011 -> -1650445800
	# sra = Shift Right Arithmetic
	# sra $t1, $t2, 10 -> Set $t1 to result of
	# sign-extended shifting $t2 right by the 
	# number of bits specified by immediate,
	# which in this case is 10 bits.
	sra	$t4, $t3, 16		# $t4 = $t3 shifted right by 16 bits -> -25184
						# So sra $t4, -1650445800, 16 -> -25184
						
	sw	$t4, ($a0)		# *p = rand();
	addi	$a0, $a0, 4		# p ++

	addi	$a1, $a1, -1		# n --
ll_lpinit_test:
	# bne = Branch if Not Equal
	# bne $t1, $t2, label -> Branch to lable if $t1 and $t2 are not equal.
	# While $a1 is NOT equal to 0, pass over this instruction. 
	# Once $a1 is equal to 0, branch to label ll_lpinit.
	# Note that $a1 = 16--the limit of the array size--at first.
	bne	$a1, $zero, ll_lpinit   # if n is not 0 goto loop

	# Return to the caller (main, in this case):
	jr	$ra


# void print_array(int *p, int n)
print_array:
	addi	$sp, $sp, -12
	sw	$s0, ($sp)
	sw	$s1, 4 ($sp)
	sw	$s2, 8 ($sp)

	move	$s0, $a0	#$s0 is the address of the words in the array
	move	$s1, $a1	#$s1 is the number of words in the array
	li	$s2, 0		#index or counter

	b	ll_lpprint_test

ll_lpprint:
	move	$a0, $s2
	li	$v0, 1		
	syscall			# print index

	la	$a0, separator
	li	$v0, 4		
	syscall			# print :

	lw	$a0, ($s0)	# print the number in hex
	li	$v0,34
	syscall			

	la	$a0, separator
	li	$v0, 4		
	syscall			# print :

	lw	$a0, ($s0)	# print the number
	li	$v0, 1		
	syscall			

	la	$a0, separator
	li	$v0, 4		
	syscall			# print :

	lw	$a0, ($s0)	# print the number as unsigned
	li	$v0, 36
	syscall			

	la	$a0, nl	
	li	$v0, 4	
	syscall			# print nl

	addi	$s0, $s0, 4		# p ++
	addi	$s2, $s2, 1		# i ++

ll_lpprint_test:
	bne	$s2, $s1, ll_lpprint   # if (i != n) goto loop

	lw	$s0, ($sp)
	lw	$s1, 4 ($sp)
	lw	$s2, 8 ($sp)
	addi	$sp, $sp, 12 

	jr	$ra
