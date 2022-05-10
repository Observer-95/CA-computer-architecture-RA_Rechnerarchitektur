# SKELETON
#
# -------------------------------------------------------------------------------------
# Series 5 - MIPS Programming Part 2 - Countdown Clock with Keyboard Interrupts
# 
# Group members:
# Patrick Stöckli; Hoeun Yu
# 
# Individualised code by:
# Patrick Stöckli
#
# IMPORTANT: Provide instructions how to use the program.
# - Describe which button does what
# - If you added extra stuff, mention it here
# 
# Notes:
# We provide hints and guidance in the comments below and
# strongly encourage you to follow the skeleton.
# However, you are free to change the code as you like.
# 
# -------------------------------------------------------------------------------------

# Declare main as a global function
.globl main 
	
# All memory structures are placed after the .data assembler directive
.data

initial:	.word 20	# this is the initial value of the countdown (seconds), Failsafe initial value
value: 		.word 20  	# this is the current value of the countdown (seconds)

start: 		.asciiz "COUNTDOWN STARTED\n"
hello:		.asciiz "PLEASE ENTER LENGTH OF COUNTDOWN\n"
button:		.asciiz "PRESS ONE OF THE BUTTONS BEWEEN 1 AND 3 (DURATION 4, 8 OR 12 SECONDS)\n"
go: 		.asciiz "PLEASE START THE COUNTDOWN WITH BUTTON b\n"


#	      0     1     2     3     4     5     6     7     8     9
digits: .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

# starting button is b
start_pressed: .byte 0x0

# Helper to enter countdown duration
countdown_chosen: .byte 0x0

# All program code is placed after the .text assembler directive
.text 		

# The label 'main' represents the starting point
main:

# Task e)
	# print some instructions to stdout
	li      $v0, 4       	
	la      $a0, hello  	
	syscall    
	 	
	la      $a0, button  	
	syscall    

	#load value to recognize button inputs and perform interrupts.
	li $t2, 0xFFFF0012
	li $t3, 0x81
	sb $t3, 0($t2)
	
	countdown_wait:
	lb $t2, countdown_chosen
	beq $t2, $zero, countdown_wait
	
	# print some instructions to stdout
	li      $v0, 4       	
	la      $a0, go 	
	syscall    

# *************************************************************************************
# TASK (c): Implement the interrupt handling for a key press that starts the countdown. 
# 1. Set the interrupt bit on the row of buttons you want to use (see demo code).
# 2. Implement the interrupt handler (see section at the bottom).
# 3. Add a waiting loop here and branch out if the "start_pressed" byte is != 0.
# *************************************************************************************	
	li $t0, 0xFFFF0012
	li $t1, 0x84 #load value to recognize button inputs in the third row.
	sb $t1, 0($t0)

	# waiting loop until start key pressed (key 0)
	wait_loop:
	lb $t0, start_pressed
	beq $t0, $zero, wait_loop
	
	# print a start message to stdout
	li      $v0, 4       	
	la      $a0, start  	
	syscall             	
	
	# load entered initial value to preprare the countdown
	lw $t0, initial
	sw $t0, value
# *************************************************************************************
# MAIN CODE FOR COUNTDOWN: Add your implementation from Series 4 here. 
# If you don't have a working code, ask the teaching assistants for help.
# You are not allowed to copy someone else's code.
# 
# You may have to slightly adapt it to work with the interrupt handling, but no 
# major changes should be required. Most of the added functionality can be implemented 
# at the start of the program and in the interrupt  handler.
# *************************************************************************************	
	
	loop:
	
	lw $t0, value  		# register t0 holds the countdown value
	
	# 1. Split the countdown value into its two digits (see get_digits subroutine)
	# 2. Write the digits to the display (see write_digit subroutine)
	# 3. Stall for 1 second
	# 4. Check if countdown runs out and continue looping
	move $a0, $t0 		# Gets the current value of $t0 into $a0
	jal get_digits
	li $a1, 0xFFFF0010 
	move $a0, $v0
	jal write_digit		# Writes the right digit
	
	li $a1, 0xFFFF0011
	move $a0, $v1
	jal write_digit		# Writes the left digit
	
	li $v0, 32		# Set the syscall-code to sleep, sleeps for 1000 ms = 1s
	li $a0, 1000
	syscall
	
	lw $t0, value
	addi $t0, $t0, -1	# decrement the current value by one
	sw $t0, value		# stores the updated value
	bne $t0, $zero, loop	# loops until value reaches zero
	
	
	jal get_digits		# Additional instructions to show 00
	li $a1, 0xFFFF0010 
	move $a0, $v0
	jal write_digit
	

	li $t0, 5		# Number of time blink loops
	
	blink:
	
	# 1. Turn display off
	# 2. Wait
	# 3. Turn display on
	# 4. Loop
	li $a1, 0xFFFF0011	# setting both digits to empty
	sb $zero, ($a1)
	li $a1, 0xFFFF0010
	sb $zero, ($a1)
	
	li $v0, 32		# make sleep-syscall for half a second
	li $a0, 500
	syscall
	
	
	li $a0, 0x3F		# settig both digits to 0.
	sb $a0, 0xFFFF0011
	sb $a0, 0xFFFF0010
	
	li $v0, 32		# make sleep-syscall for half a second
	li $a0, 500
	syscall
	
	
	addi $t0, $t0, -1	# decrement the value of $t0 by 1
	bne $t0, $zero, blink	# 
	
	
	

	# Exit the program by means of a syscall.
	# The code for exit is "10". 
	li $v0, 10 		# sets $v0 to "10" to select exit syscall
	syscall




# This is a helper subroutine. It splits an integer into its two individual digits and
# saves the results in registers v0 and v1.
# Arguments: 
#     a0: an integer value 0 <= x < 100
# Outputs:
#     v0: right digit (10^0)
#     v1: left digit (10^1)
get_digits:
	li $a1, 10	# Loads the value 10 into register $a1
	divu $a0, $a1 	# the input value of $a0 is divided by 10 (which is located in $a1).
			# The operation is unsigned, since all values are positive and 
			# the signed bit would take space away.
	mfhi $v0	# This operation stores the whole number of the division in $v0.
			# For example, if the division is 19/10, 1 is stored.
			# Since we divide through 10, this is the value of the left digit
	mflo $v1	# This operation stores the rest-value of the division in $v1.
			# Since we divide through 10, this is the value of the right digit.
	jr $ra		# Jumps back to the place the subroutine was called from.
	
	
write_digit:

	# 1. Fetch the correct byte pattern depending on digit passed in (see the 
	#    array "digits" defined at the top). 
	#    Hint: You can load an address with the "la" instruction.
	# 2. Save the byte to the memory address in a1. 
	#    Hint: You can store a byte with the "sb" instruction. 
	#          Compare it to the "sw" instruction seen in class.
	# 3. Return.
	li $t3, 0 		# clears the register $t3
	add $t3, $t3, $a0	# loads the input number from $a0 into $t3
	la $t4, digits		# loads the address of the array into $t4
	addu $t3, $t3, $t4	# adds the offset to the array
	lb $t5, 0($t3)		# loads the value from the array into $t5
	sb $t5, ($a1)		# saves the value of $t5 into the address stored in $a1
	jr $ra
	
	

# *************************************************************************************
# Tasks (c), (d), (e): Take a look at the demo code for a simple interrupt handler 
# and adapt/extend it. 
#
# *************************************************************************************

# INTERRUPT HANDLER (only runs when a key is pressed).
# 0x80000180 is an address that signifies the location of the instructions in memory. This address is specific to MARS.
# What follows are the kernel mode instructions.
.ktext 0x80000180 

	# TODO: Don't forget to save your registers
	addi $sp, $sp, -16
	sw  $t0, 0($sp)
	sw  $t1, 4($sp)
	sw  $t2, 8($sp)
	sw  $t3, 12($sp)

 	move $k0, $v0   # Save $v0 value
   	move $k1, $a0   # Save $a0 value


	# Interrupt-code
	li $t0, 0x04 #checks whether a button in the third row was pressed.
	lb $t1, 0xFFFF0012
	sb $t0, 0($t1)
	
	lbu $t0, 0xFFFF0014
	li $t1, 0x84 # Value of the forth button in the third row, which is the starting button
	beq $t0, $t1, reset_clock # Branch if b is pressed
	
	li $t2, 0x01 #checks whether a button in the first row was pressed
	lb $t3, 0xFFFF0012
	sb $t2, 0($t3)
	
	lbu $t2, 0xFFFF0014
	slt $t3, $zero, $t2
	bne $t3, $zero, set_countdown #branch if button 1,2 or 3 greater than zero was pressed.
	
	j exit_interrupt
	
	set_countdown:
	
	jal get_number #Loads the integer fitting to the button pressed
	
	li $t2, 1
	sb $t2, countdown_chosen #update variable to break out of loop in main function.
	

	sw $s1, initial #updates the initial countdown value with the one selected
	
	j exit_interrupt
	
	reset_clock:
	
	li $t0, 1
	sb $t0, start_pressed #udpates variable to break out of loop in main function
	
	lw $t0, initial # restores the value with the initial value to reset countdown
	sw $t0, value

   	exit_interrupt:
   	move $v0, $k0   	# Restore $v0
	move $a0, $k1   	# Restore $a0
	
	
	# TODO: Don't forget to restore registers before return
	lw  $t0, 0($sp)  	
	lw  $t1, 4($sp)
	lw  $t2, 8($sp)
	lw  $t3, 12($sp)
	addi $sp, $sp, 16
	
	eret			# exit the interrupt handler and return to main program
	
	
	
	get_number:
	li $t4, 0x21 #Value of the pressed button, way to find out which button has been pressed
	beq $t2, $t4, get_1
	li $t4, 0x41
	beq $t2, $t4, get_2
	li $t4, 0x81
	beq $t2, $t4, get_3
	
	jr $ra
	
	get_1:
	li $s1, 0x4 #loads the value 1 in the register $s1
	jr $ra
	
	get_2:
	li $s1, 0x8
	jr $ra
	
	get_3:
	li $s1, 0xc
	jr $ra
	
	
