; 190070049
; RAM allocation
CUR_ST  DATA 40H
DgtCode DATA 41H
KeyCode DATA 42H
KeyNo	DATA 43H
KeyIndx	DATA 44H
KeyBuf	DATA 50H
STACKST EQU  6FH
; Assume a 24 MHZ crystal
; Counts for a 25 ms delay are:
TH0COUNT EQU 3CH
TL0COUNT EQU 0B0H
;F0 in PSW will be used to store the answer from tests
org 0000H
ljmp Init
ORG 0003H
ljmp X0_INTR		; jump to ext interrupt 0 handler
ORG 000BH
ljmp T0_INTR		; Jump to timer 0 interrupt handler
ORG 0013H
ljmp X1_INTR		; Jump to ext interrupt 1 handler
ORG 001BH
ljmp T1_INTR		; Jump to timer 1 interrupt handler
ORG 0023H
ljmp Ser_INTR		; Jump to Serial IO handler
org 0030H
T0_INTR: CLR TR0	; Stop the timer
MOV TH0, #TH0COUNT	; Re-load counts for 25 ms delay
MOV TL0, #TL0COUNT
SETB TR0		; Restart T0
SETB ET0		; Re-enable interrupts from T0
LJMP FSM		; Now manage the FSM

ORG 0060H
FSM: PUSH ACC
PUSH PSW
PUSH DPH
PUSH DPL

ACALL DO_TEST		; Peform the test for this state
ACALL DO_ACTION		; Perform the action based on test answer
ACALL SET_NEXT		; Set current state = next state
			; and return, cleaning up as we go
POP DPL
POP DPH
POP PSW
POP ACC
;RET					; Use ret during testing
RETI

DO_TEST:
MOV A, CUR_ST		; Fetch the current state
MOV DPTR, #Test_Tab	; Table of test numbers for states
MOVC A, @A + DPTR	; Get the test number for this state
MOV DPTR, #Test_Jmp	; Jump table for tests
ADD A, ACC		; A = 2A: each entry is 2 bytes
jmp @A + DPTR		; Jump to the selected test
; Note: selected test will do ret.
DO_ACTION:
MOV DPTR, #Yes_Actions
JB F0, Sel_Action	; If test answer = yes, DPTR is correct
MOV DPTR, #No_Actions   ; If Test returned no, modify DPTR
Sel_Action:		; Now look up the action to be taken
MOV	A, CUR_ST	; Fetch the current state
MOVC A, @A + DPTR	; and look up the action number
ADD A, ACC		; A = 2A : offset in Action jump table
			; because each entry is 2 bytes
MOV DPTR, #Action_jmp	; Jump table for actions
JMP @A + DPTR		; Jump to the selected action
; Note: selected action will do ret
					
SET_NEXT:
MOV DPTR, #Yes_Next	; Array of next states for yes answer
JB F0, Do_Next		; If answer was yes, DPTR is correct
MOV DPTR, #No_Next	; Else correct the DPTR to no answer
Do_Next:
MOV A, CUR_ST		; get the current state
MOVC A, @A+DPTR		; get the next state
MOV CUR_ST, A		; and save it as current state
RET

Test_Tab:    DB 0, 1, 1, 1
Yes_Actions: DB 1, 2, 0, 0
NO_Actions:  DB 0, 0, 0, 0
Test_Jmp:
AJMP AnyKey
AJMP TheKey
Action_Jmp:
AJMP DoNothing
AJMP FindKey
AJMP ReportKey
Yes_Next: DB 1, 2, 2, 2
No_Next:  DB 0, 0, 3, 0
AnyKey:
	MOV P0, #0FH 	; column bits have been put in input mode by writing ‘1’s to them and all row lines are driven to ‘0’
	MOV A, P0		; read the port
	ANL A, #0FH 	; AND with 0FH as we check only columns (lower nibble)
	CJNE A, #0FH, KeyPressed
  KeyNotPressed:
	CLR F0 			; Clear F0 if KeyNotPressed
	SJMP AnyKeyDONE
  KeyPressed:
	SETB F0 		; Set F0 if KeyPressed
  AnyKeyDONE:
	RET

TheKey:
					; FindKey first
	MOV P0, #0FH 	; column bits have been put in input mode by writing ‘1’s to them and all row lines are driven to ‘0’
	MOV A, P0 		; read the port, to identify the column
	ORL A, #0F0H	; force the upper bits of the read byte to ‘1’
	MOV P0, A 		; write it back to the port
	MOV A, P0		; Get KeyCode
	
	CJNE A, KeyCode, CurrentlyNotPressed
  CurrentlyPressed:
  	SETB F0 		; Set F0 if CurrentlyPressed
  	SJMP TheKeyDONE
  CurrentlyNotPressed:
  	CLR F0 			; Clear F0 if CurrentlyNotPressed
  TheKeyDONE:
	RET

DoNothing:
	RET

FindKey:
	MOV P0, #0FH 	; column bits have been put in input mode by writing ‘1’s to them and all row lines are driven to ‘0’
	MOV A, P0 		; read the port, to identify the column
	ORL A, #0F0H	; force the upper bits of the read byte to ‘1’
	MOV P0, A 		; write it back to the port
	MOV KeyCode, P0	; read the port now, only the row and column bits corresponding to the pressed switch will be ‘0’ and write key code OF pressed key
	RET

ReportKey:
	SETB PSW.4 		; Select Bank 2 for registers
	MOV A, #KeyBuf 	; Get to current location 
	ADD A, KeyIndx	; 50H + KeyIndxk
	MOV R0, A
	MOV @R0, KeyCode; store KeyCode at correct location using R0
	
	INC KeyIndx 	; increment KeyIndx for next ReportKey
	MOV A, KeyIndx
	CJNE A, #8, ReportKeyDone	; If KeyIndx becomes 8 we should go back to 0 (to maintain circular queue)
	MOV KeyIndx, #0

  ReportKeyDone:
	CLR PSW.4 		;  Deselect Bank 2 for registers
	RET

X0_INTR:		; ext interrupt 0 handler
RETI
X1_INTR:		; ext interrupt 0 handler
RETI
T1_INTR:		; Timer 1 handler
RETI
Ser_INTR:		; Serial IO handler
RETI
ORG 0200H
Init:
MOV SP, #STACKST	; SP to top of 8051 memory
MOV CUR_ST, #00		; Initialize current state to Idle
CLR TR0			; Stop the timer (if running)
MOV TH0, #TH0COUNT	; Load T0 counts for 25 ms delay
MOV TL0, #TL0COUNT
SETB ET0		; Enable interrupts from T0
SETB EA			; Enable interrupts globally
SETB TR0		; Start T0 timer
MOV KeyIndx, #00H	; Initialize index in key buffer
;TST1: acall T0_INTR	; This is for testing only
;sjmp TST1		; Test ISR by calling it in SW
L1: sjmp L1		; This represents main program
END