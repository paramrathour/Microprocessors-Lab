ORG 0H

MOV P1, #0FH

START:
	LCALL blinkingLEDs					; Call subroutine
SJMP START

blinkingLEDs: 

	MOV P1, #0FH 						; Configure P1.3-P1.0 (Switches) as input and P1.7-P1.4 (LEDs) as Output

										; Set P1.7-P1.4 (LEDs) as High
    SETB P1.4
    SETB P1.5
    SETB P1.6
    SETB P1.7

    ACALL DELAY5s						; Wait for 5 secs as user gives input via P1.3-P1.0 (Switches) : N

	MOV A, P1 							; Copy P1 bits in A
	ANL A, #0FH 						; Clear upper nibble bits
	MOV R0, #0H 						; i = 0
	
	CJNE A, #0, LOOP
	SJMP breakLOOP
	LOOP:
		
		INC R0							; i = i + 1
										; Set P1.7-P1.4 (LEDs) as LOW, Wait for 1 second
		CLR P1.4
		CLR P1.5
		CLR P1.6
		CLR P1.7
		ACALL DELAY1s
										; Set P1.7-P1.4 (LEDs) as HIGH, Wait for 1 second
		SETB P1.4
		SETB P1.5
		SETB P1.6
		SETB P1.7
		ACALL DELAY1s
		
		CJNE A, 00H, LOOP 			    ; i < N

breakLOOP:
	
RET

DELAY1s:								; Counts 1 second

										; 4 (Routine) + 3 (NOP) + (1 + 167 * (3 + 39 * (3 + 2 * 152))) = 2000000 ; 2000000 * 0.5 * 10^{-6} = 1
	NOP
	NOP
	NOP
	MOV R7, #167						
	LOOP1:
		MOV R6, #39
		LOOP2:
			MOV R5, #152
			LOOP3:	
			DJNZ R5, LOOP3
		DJNZ R6, LOOP2
	DJNZ R7, LOOP1


RET

DELAY5s:								; Counts 5 seconds

	ACALL DELAY1s
	ACALL DELAY1s
	ACALL DELAY1s
	ACALL DELAY1s
	ACALL DELAY1s

RET

END