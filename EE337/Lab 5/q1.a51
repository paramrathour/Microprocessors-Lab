ORG 0000H			; This is a directive.
					; Sets current address to 0000H
LJMP COMPLEMENT		; For skipping the interrupt area
ORG 0100H			; Sets current address to 0100H
	
COMPLEMENT:
					; Total Number of Machine Cycles 40000 - 17 = 39983 = 9C2FH
	MOV 050H, #9CH	; MSB
	MOV 051H, #2FH 	; LSB
	
					; 2's complement = 1's complement + 1
	MOV A, 51H
	XRL A, #0FFH	; 1's complement of LSB in R1
	MOV R1, A
	
	MOV A, 50H
	XRL A, #0FFH	; 1's complement of MSB in R0
	MOV R0, A
					
	MOV A, R1
	ADD A, #1		; Add 1
	MOV R1, A
	JNC READY		; IF carry generated add 1 to MSB ELSE done

	MOV A, R0
	ADD A, #1
	MOV R0, A
					; 52H,53H contains 2's complement of given number
READY: 
	MOV 52H, R0
	MOV 53H, R1
	
START:

    SETB P1.4
    SETB P1.5
    SETB P1.6
    SETB P1.7
	
	ACALL DELAY1s

	CLR P1.4
	CLR P1.5
	CLR P1.6
	CLR P1.7

	ACALL DELAY1s

	LJMP START

;--------------------------- 0.02 second TIMER ------------------------------

TIMER:				; 0.02 - 2 * 0.5 * 10^{-6} seconds
	NOP
	MOV TMOD, #01
	MOV TH0, 52H	;= #63H	; Timer should have 25536 (63C0H) machine cycles
	MOV TL0, 53H	;= #D1H ; Taking into consideration other instructions in TIMER (1+2+2+2+1+1+1) Routine Calls (4) DJNZ (2)
	SETB TR0		; Total 17 extra instructions increase, So reduce that much 63C0H + 17 = 63D1H

	REPEAT: JNB TF0, REPEAT
	
	CLR TR0
	CLR TF0

	RET

DELAY1s:			 ; Counts 1 seconds (actually 1 + 9 * 0.5 * 10^{-6} seconds) Including ACALL machine cycle1	

	PUSH 0
	PUSH 1

	MOV R0, #50
	LOOP: ACALL TIMER
	DJNZ R0, LOOP

	POP 1
	POP 0
	RET	
END