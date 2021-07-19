OPT equ P0.0  							; Output

ORG 0000H							    ; This is a directive.
									    ; Sets current address to 0000H
LJMP START							    ; For skipping the interrupt area

ORG 001BH								; Interrupt Routine
	INC R1								; R1 stores number of 0.02s delay occurence
	CJNE R1, #100, JUMP					; When R1 = 100 time is 2s
	MOV R1, #0							; Reset R1
	CPL PSW.5							; complement PSW.5
JUMP:
	CLR TCON.6							; Stop Timer
	MOV TH1, #63H						; Load THL for 0.02 seconds
	MOV TL1, #0C0H
	SETB TCON.6							; Start Timer
	RETI

ORG 0100H							    ; Sets current address to 0100H

START:
	MOV TMOD, #11H						; Configure Timers 0 and 1 with Mode 1
	MOV IE, #88H						; Enables interrupt for Timer 1

	CLR PSW.5							; PSW.5 is low for Re and high for Ga
	MOV R1, #0
	SETB TCON.6							; Start Timer

REPEAT:
	JB PSW.5, GaLOOP					; If PSW.5 is 0 then Re else Ga
	
ReLOOP:
	ACALL Re
	CPL OPT
	SJMP REPEAT
	
GaLOOP:
	ACALL Ga
	CPL OPT
	SJMP REPEAT
;--------------------------- 0.02 second TIMER ------------------------------
Re:					; 0.02 - 2 * 0.5 * 10^{-6} seconds
	NOP
	MOV TH0, #0F1H	; Timer should have 3703 (Start from F188H) machine cycles
	MOV TL0, #09BH	; Taking into consideration other instructions
	SETB TR0		; Total 19 extra instructions increase, So reduce that much F188H + 19 = F19BH

	ReREPEAT: JNB TF0, ReREPEAT
	
	CLR TR0
	CLR TF0

	RET

Ga:					; 0.02 - 2 * 0.5 * 10^{-6} seconds
	NOP
	MOV TH0, #0F3H	; Timer should have 3333 (Start from F2FBH) machine cycles
	MOV TL0, #00DH	; Taking into consideration other instructions
	SETB TR0		; Total 18 extra instructions increase, So reduce that much F2FBH + 18 = F30DH

	GaREPEAT: JNB TF0, GaREPEAT
	
	CLR TR0
	CLR TF0

	RET

END