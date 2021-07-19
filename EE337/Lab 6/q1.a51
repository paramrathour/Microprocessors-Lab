SW1 equ P1.0  							; Switch 1
LCD_data equ P2    						; LCD Data port
LCD_rs   equ P0.0  						; LCD Register Select
LCD_rw   equ P0.1  						; LCD Read/Write
LCD_en   equ P0.2  						; LCD Enable


ORG 0000H							    ; This is a directive.
									    ; Sets current address to 0000H
LJMP START							    ; For skipping the interrupt area

ORG 000BH								; Interrupt Routine
	INC R1
	CLR TCON.4							; Stop Timer
	MOV TH0, #00H 						; Load THL
	MOV TL0, #00H
	SETB TCON.4							; Start Timer
	RETI

ORG 0100H							    ; Sets current address to 0100H

START:

	MOV	P1, #1							; Switch 1 used as input

	MOV TMOD, #11H						; Configure Timers 0 and 1 with Mode 1
	MOV IE, #82H						; Enables interrupt for Timer 0

	ACALL LCD_INIT

REPEAT:
	;-------------------------------- i) ------------------------------------
	RepeatTillSwitchOFF: JB SW1, RepeatTillSwitchOFF
	MOV A, #80H				   		    ; Put cursor on first column
	ACALL LCD_Command	 				; Send command to LCD
	MOV   DPTR, #My_String1			    ; Load DPTR with string1 Addr
	ACALL LCD_SendString	   			; Call text strings sending routine

	MOV A, #0C0H			   		    ; Put cursor on first column
	ACALL LCD_Command	 				; Send command to LCD
	MOV   DPTR, #My_String2			    ; Load DPTR with string2 Addr
	ACALL LCD_SendString	   			; Call text strings sending routine

	ACALL DELAY2s
	SETB P1.4

	;-------------------------------- ii) -----------------------------------
	MOV R1, #0
	SETB TCON.4							; Start Timer

  	RepeatTillSwitchON: JNB SW1, RepeatTillSwitchON

	CLR P1.4
	CLR TCON.4							; Stop Timer

	;------------------------------- iii) -----------------------------------
	;Interrupt handler

	;-------------------------------- iv) -----------------------------------
	ACALL LCD_Clear
	
	MOV A, #80H				   		    ; Put cursor on first column
	ACALL LCD_Command	 				; Send command to LCD
	MOV   DPTR, #My_String3			    ; Load DPTR with string3 Addr
	ACALL LCD_SendString	   			; Call text strings sending routine

	MOV A, #0C0H			   		    ; Put cursor on first column
	ACALL LCD_Command	 				; Send command to LCD
	MOV   DPTR, #My_String4			    ; Load DPTR with string4 Addr
	ACALL LCD_SendString	   			; Call text strings sending routine

	MOV B, R1							; Print R1
	ACALL PRINTB

	MOV A, #32							; Space " " character
	ACALL LCD_SendData					; Send space

	MOV B, TH0							; Print TH0
	ACALL PRINTB
	MOV B, TL0							; Print TL0
	ACALL PRINTB
	ACALL DELAY5s

	ACALL LCD_Clear

	;-------------------------------- v) ------------------------------------
	SJMP REPEAT
;-------------------------------- Print B -----------------------------------
PRINTB:
										; Print Upper Nibble
	MOV A, B
	SWAP A
	ANL A, #0FH
	ACALL PRINT1Digit
										; Print Lower Nibble
	MOV A, B
	ANL A, #0FH
	ACALL PRINT1Digit

	RET
;-------------------------------- Print 1 Digit -----------------------------------
PRINT1Digit:
	
	CJNE A, #10, NotEqual
NotEqual:
	JNC PrintLetter
	ADD A, #48							; 48 for ASCII
	SJMP DONE
PrintLetter: 
	ADD A, #55							; 65 for ASCII but - 10 as A is hexadecimal number
DONE:
	ACALL LCD_SendData					; Send digit
	
	RET	
;--------------------------- 0.02 second TIMER ------------------------------

TIMER1:				; 0.02 - 2 * 0.5 * 10^{-6} seconds
	NOP
	MOV TL1, #0D0H
	MOV TH1, #63H
	SETB TR1

	RepeatTillOverflow: JNB TF1, RepeatTillOverflow
	
	CLR TR1
	CLR TF1

	RET

;--------------------------- 1 second DELAY ------------------------------
DELAY1s:			 ; Counts 1 seconds (actually 1 + 9 * 0.5 * 10^{-6} seconds) Including ACALL machine cycle

	PUSH 0
	PUSH 1

	MOV R0, #50
	LOOP: ACALL TIMER1
	DJNZ R0, LOOP

	POP 1
	POP 0
	RET	
;--------------------------- 2 second DELAY ------------------------------
DELAY2s:			 ; Counts 2 seconds (actually 2 * (1 + 9 * 0.5 * 10^{-6}) seconds) Including ACALL machine cycle

	ACALL DELAY1s
	ACALL DELAY1s
	RET	
;--------------------------- 5 second DELAY ------------------------------
DELAY5s:			 ; Counts 5 seconds (actually 5 * (1 + 9 * 0.5 * 10^{-6}) seconds) Including ACALL machine cycle

	ACALL DELAY1s
	ACALL DELAY1s
	ACALL DELAY1s
	ACALL DELAY1s
	ACALL DELAY1s
	RET	
;------------------------LCD Initialisation routine----------------------------------------------------
LCD_INIT:
		 ACALL DELAY
         MOV   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         CLR   LCD_rs         ;Selected command register
         CLR   LCD_rw         ;We are writing in instruction register
         SETB  LCD_en         ;Enable H->L
		 ACALL DELAY
         CLR   LCD_en
	     ACALL DELAY

         MOV   LCD_data,#0CH  ;Display on, Curson off
         CLR   LCD_rs         ;Selected instruction register
         CLR   LCD_rw         ;We are writing in instruction register
         SETB  LCD_en         ;Enable H->L
		 ACALL DELAY
         CLR   LCD_en
		 ACALL DELAY

         MOV   LCD_data,#01H  ;Clear LCD
         CLR   LCD_rs         ;Selected command register
         CLR   LCD_rw         ;We are writing in instruction register
         SETB  LCD_en         ;Enable H->L
		 ACALL DELAY
         CLR   LCD_en
		 ACALL DELAY

         MOV   LCD_data,#06H  ;Entry mode, auto increment with no shift
         CLR   LCD_rs         ;Selected command register
         CLR   LCD_rw         ;We are writing in instruction register
         SETB  LCD_en         ;Enable H->L
		 ACALL DELAY
         CLR   LCD_en
		 ACALL DELAY
         
         RET                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 LCD_Command:
 		 ACALL DELAY
         MOV   LCD_data,A     ;Move the command to LCD port
         CLR   LCD_rs         ;Selected command register
         CLR   LCD_rw         ;We are writing in instruction register
         SETB  LCD_en         ;Enable H->L
		 ACALL DELAY
         CLR   LCD_en
		 ACALL DELAY
    
         RET  
;-----------------------data sending routine-------------------------------------		     
 LCD_SendData:
		 ACALL DELAY
         MOV   LCD_data,A     ;Move the command to LCD port
         SETB  LCD_rs         ;Selected data register
         CLR   LCD_rw         ;We are writing
         SETB  LCD_en         ;Enable H->L
		 ACALL DELAY
         CLR   LCD_en
		 ACALL DELAY
         RET                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
LCD_SendString:
	ACALL DELAY
	PUSH 0e0h
	LCD_SendString_Loop:
 	 	 CLR   A                 ;clear Accumulator for any previous data
         MOVC  A,@A+DPTR         ;load the first character in accumulator
         JZ    EXIT              ;go to exit if zero
         ACALL LCD_SendData      ;send first char
         INC   DPTR              ;increment data pointer
         SJMP  LCD_SendString_Loop    ;jump back to send the next character
EXIT:    POP 0e0h
		 ACALL DELAY
         RET                     ;End of routine
;------------------------------------ LCD Clear -----------------------------------------
LCD_Clear:
	 ACALL DELAY
     MOV   LCD_data,#01H  ;Clear LCD
     CLR   LCD_rs         ;Selected command register
     CLR   LCD_rw         ;We are writing in instruction register
     SETB  LCD_en         ;Enable H->L
	 ACALL DELAY
     CLR   LCD_en
	 ACALL DELAY
    
RET  
;---------------------- delay routine-----------------------------------------------------
DELAY:	 
	PUSH 0
	PUSH 1
	MOV R1, #200
	LOOP1:	 DJNZ R1, LOOP1
	POP 1
	POP 0 
	RET
;------------- ROM text strings---------------------------------------------------------------
ORG 300h

My_String1:
	DB   "Toggle SW1", 00H
My_String2:
	DB   "if LED glows", 00H
My_String3:
	DB   "Reaction Time", 00H
My_String4:
	DB   "Count is ", 00H
END