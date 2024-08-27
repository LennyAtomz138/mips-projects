# 19 SEP 2018 CSE 3666 Lenny Adams
# This code has been modified to resolve Part II of CSE 3666 Lab 1.

# IOT store variables in RAM (Data Segment):
.data

	# "\n" isASCII for a new line. asciiz with z means 0 
	# (not character '0') is placed after the last character. 
	newline:		.asciiz "\n"
	
	# The next variable (symbol) should starts at an address that is a multiple of 4.			
				.align 2	
						
	name:		.asciiz "CSE3666: Lab 0: YOUR NAME \n\n\n"
	
	# The next variable (symbol) should starts at an address that is a multiple of 4.
				.align 2
				
	msg1:		.asciiz "\nThe string you just typed is\n"
	
	# The next variable (symbol) should starts at an address that is a multiple of 4.
				.align 2
	
	# Reserve space for a variable (array). Not initialized.						
	buf:			.space 128			

	# The next variable (symbol) should starts at an address that is a multiple of 4.
				.align 2
				
	reserved:	.space 20	

# IOT store instructions in Memory (Code Segment):
.text
# IOT declare main to be a global label:
.globl	main			

# Define the main procedure:
main:	

	# Read in integer #1:
	la $a0, buf
	li $a1, 10
	li $v0, 5		# Syscall 5 = Read Integer ($v0 contains read integer)
	syscall
	
	# Move read integer to $s0:
	add $s0, $v0, $zero
	
	# Read in integer #2:
	li $v0, 5		# Syscall 5 = Read Integer ($v0 contains read integer)
	syscall
	
	# Move read integer to $s2:
	add $s2, $v0, $zero
	
	# Question 11 of Part II is below:
	
	# Load the starting address of 'buf' into $t0:
	la $t0, buf
	# Calculate the offset of word buf[$s0] (4 times value in $s0):
	sll $t1, $s0, 2
	# Calculate the address of buf[$s0], stored in $s1:
	add $s1, $t1, $t0
	# Store $s2 (the second integer) in buf[$s0}:
	sw $s2, 0($s1) 
	
	# Question 12 of Part II is below:
	
	# Print value $s0 (integer #1) in decimal (Syscall 1 = Print Integer):
	li $v0, 1
	la $a0, ($s0)
	syscall
	
	# Print newline (Syscall 4 = Print String):
	li $v0, 4
	la $a0, newline
	syscall
	
	# Print value $s1 (the address) in hexadecimal (Syscall 34 = Print Int in Hexadecimal):
	# Displayed value is 8 hexadecimal digits, left-padding with zeroes if necessary.
	li $v0, 34
	la $a0, ($s1)
	syscall
	
	# Print newline (Syscall 4 = Print String):
	li $v0, 4
	la $a0, newline
	syscall
	
	# Print value $s2 (integer #2) in hexadecimal (Syscall 34 = Print Int in Hex)):
	li $v0, 34
	la $a0, ($s2)
	syscall
	
# Define the Exit label:
Exit:	
	li	$v0,10		# System call, type 10, standard exit
	syscall
	
## Answer to Question 13 from CSE 3666 Lab 1:
##
## The buffer 'buf' starts at 0x10010044.
## You can find the location of the word you write to memory by viewing the
## address locations listed within the Data Segment (and Registers list) in
## the Execution Tab.  
