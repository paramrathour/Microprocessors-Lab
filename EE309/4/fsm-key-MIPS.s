.data
TestTab:	.word AnyKey, TheKey
ActTab: 	.word DoNothing, FindKey, ReportKey
Cur_St:		.byte 0x00
Key_Code:	.byte 0x7E
Key_Index:	.byte 0
Key_Buffer:	.space 16
In_Dest:	.byte 0
Out_From:	.byte 0
Periph:		.space 4
Port_Address: .word 0x40000000
# State Diagram Data
Test_No:	.byte 0, 1, 1, 1
Yes_Act:	.byte 1, 2, 0, 0
No_Act:		.byte 0, 0, 0, 0
Yes_Next:	.byte 1, 2, 2, 2
No_Next:	.byte 0, 0, 3, 0

.text
.globl main

main:
	li $t4, 0x04 					# Stores 4
	li $t6, 0x01 					# Stores 1
	li $t7, 0x0F 					# Stores 0x0F
	li $t8, 0x08 					# Stores 8
FSM:

DO_TEST:
	lb $t0, Cur_St					# Fetch the current state
	la $t1, Test_No					# Table of test numbers for states

	add $t2, $t0, $t1				# Get the test number for this state
	lb $t3, ($t2)
	mul $t1, $t3, $t4				# Multiply index by 4 as words are stored (4 bytes = 1 word)

	la $t2, TestTab					# Jump table for tests

	add $t3, $t1, $t2				# Calculate address of jump address for test
	lw $t2,($t3)
	jalr $t2						# Jump to the selected test
	nop

DO_ACTION:
	la $t1, Yes_Act					# IF Test answer = YES
	bne $t5, $0, Sel_Action
	nop
	la $t1, No_Act					# ELSE Test answer = NO
  Sel_Action:						# Now, get jump address as in DO_TEST
  	lb $t0, Cur_St					# Fetch the current state
  	add $t2, $t0, $t1				
  	lb $t3, ($t2)
  	mul $t1, $t3, $t4

  	la $t2, ActTab

  	add $t3, $t1, $t2
  	lw $t2,($t3)
	jalr $t2
  	nop

SET_NEXT:
	la $t1, Yes_Next				# Array of next states for YES answer
	bne $t5, $0, Do_Next
	nop
	la $t1, No_Next
  Do_Next:							# get the next state and save
  	lb $t0, Cur_St					# Fetch the current state
	add $t2, $t0, $t1
	lb $t0, ($t2)
	sb $t0, Cur_St
	nop

	j FSM

AnyKey:
	sw $t7, Port_Address			# column bits have been put in input mode by writing ‘1’s to them and all row lines are driven to ‘0’
	lw $t1, Port_Address			# read the port, to identify the column
	and $t2, $t1, $t7 				# AND with 0x0F as we check only columns (lower nibble)
	bne $t2, $t7, KeyPressed
	nop
  KeyNotPressed:
	move $t5, $0					# Clear $t5 if KeyNotPressed
	j AnyKeyDONE
  KeyPressed:
	move $t5, $t6 					# Set $t5 if KeyPressed
  AnyKeyDONE:
	jr $ra

TheKey:
									# FindKey first
	sw $t7, Port_Address			# column bits have been put in input mode by writing ‘1’s to them and all row lines are driven to ‘0’
	lw $t1, Port_Address			# read the port, to identify the column
	or $t2, $t1, $t7				# force the upper bits of the read byte to ‘1’
	sw $t2, Port_Address			# write it back to the port
	lw $t1, Port_Address
	lb $t2, Key_Code				# Get KeyCode
	bne $t1, $t2, KeyPressed
	nop
  CurrentlyPressed:
  	move $t5, $t6 					# Set $t5 if CurrentlyPressed
  	j TheKeyDONE
  CurrentlyNotPressed:
  	move $t5, $0 					# Clear $t5 if CurrentlyNotPressed
  TheKeyDONE:
	jr $ra

DoNothing:
	jr $ra

FindKey:
	sw $t7, Port_Address			# column bits have been put in input mode by writing ‘1’s to them and all row lines are driven to ‘0’
	lw $t1, Port_Address			# read the port, to identify the column
	or $t2, $t1, $t7				# force the upper bits of the read byte to ‘1’
	sw $t2, Port_Address			# write it back to the port
	lw $t2, Port_Address			# read the port now, only the row and column bits corresponding to the pressed switch will be ‘0’
	sb $t2, Key_Code				# write pressed key in Key_Code
	jr $ra

ReportKey:
	la $t1, Key_Buffer 				# Get to current location 
	lb $t2, Key_Index 				# Get current Key_Index
	add $t3, $t1, $t2	 			# Key_Buffer + Key_Index

	lb $t1, Key_Code
	sw $t1, ($t3)					# store KeyCode at correct location
	
	add $t3, $t2, $t6 				# increment Key_Index for next ReportKey

	bne $t3, $t8, ReportKeyDone		# If Key_Index becomes 0x8 we should go back to 0 (to maintain circular queue)
	nop
	lb $0, Key_Index

  ReportKeyDone:
	jr $ra