										; This subroutine writes characters on the LCD
LCD_data equ P2    						; LCD Data port
LCD_rs   equ P0.0  						; LCD Register Select
LCD_rw   equ P0.1  						; LCD Read/Write
LCD_en   equ P0.2  						; LCD Enable


ORG 0000H							    ; This is a directive.
									    ; Sets current address to 0000H
LJMP START							    ; For skipping the interrupt area
ORG 0100H							    ; Sets current address to 0100H

START:

	SETB P1.0
	SETB P1.1
	SETB P1.2
										; LCD initialisation
	ACALL DELAY
	ACALL LCD_INIT
	ACALL DELAY

ALWAYS:

	MOV A, P1 							; Copy P1 bits in A
	ANL A, #07H 						; Clear upper nibble bits, Now A is storing P2P1P0
										; Duty Cycle = (100 - (A + 1) * 10) %
										; Time Period = 2 seconds
	ADD A, #1
	MOV R0, A
	
	MOV A, #10
	SUBB A, R0
	MOV R0, A
	MOV B, #2
	MUL AB
	MOV R3, A 							; R3 stores 2 MSB's of tttt
	
	MOV B, #10
	MOV A, R0
	MUL AB
	MOV R1, A 							; R1 stores Duty Cycle in %

	MOV A, #100
	SUBB A, R1
	MOV R2, A 							; R2 stores (1 - Duty Cycle) in %
	
;--------------------------------- LCD -------------------------------------

    SETB P1.4
	SETB P1.5
	SETB P1.6
	SETB P1.7 
	
	MOV TMOD, #01						; Setting up Timer so that LCD doesn't take additional delay
	MOV TL0, #0D1H
	MOV TH0, #63H
	SETB TR0

	
	MOV A, #80H				   		    ; Put cursor on first row
	ACALL LCD_Command	 				; Send command to LCD
	ACALL DELAY
	MOV   DPTR,#My_String1			    ; Load DPTR with sring1 Addr
	ACALL LCD_SendString	   			; Call text strings sending routine

	MOV A, R1
	MOV B, #10
	DIV AB								; MSB of Duty Cycle %
	ADD A, #30H							; Convert to ASCII
	ACALL LCD_SendData					; Send digit	
	ACALL DELAY

	MOV A, B							; LSB of Duty Cycle %
	ADD A, #30H							; Convert to ASCII
	ACALL LCD_SendData					; Send digit
	ACALL DELAY

	MOV A, #0C0H				 	    ; Put cursor on second row
	ACALL LCD_Command					; Send command to LCD	
	ACALL DELAY

	MOV   DPTR,#My_String2				; Load DPTR with sring1 Addr	
	ACALL LCD_SendString	   			; Call text strings sending routine
	ACALL DELAY

	
	MOV A, R3

	MOV B, #10
	DIV AB
	MOV R4, A
	MOV R5, B

	MOV R6, #0
	MOV R7, #0
	
	MOV A, R4
	ADD A, #30H							; Convert to ASCII
	ACALL LCD_SendData					; Send MSB of Pulse Width
	ACALL DELAY

	MOV A, R5
	ADD A, #30H							; Convert to ASCII
	ACALL LCD_SendData					; Send 2nd MSB of Pulse Width
	ACALL DELAY

	MOV A, R6
	ADD A, #30H							; Convert to ASCII
	ACALL LCD_SendData					; Send 3rd MSB of Pulse Width
	ACALL DELAY

	MOV A, R7
	ADD A, #30H							; Convert to ASCII
	ACALL LCD_SendData					; Send 4th MSB of Pulse Width
	ACALL DELAY

REPEATLCD: JNB TF0, REPEATLCD
	
	CLR TR0
	CLR TF0
;--------------------------------- PWM -------------------------------------   
	
	DEC R1
    MOV R0, 01H							; DelayHigh = 2 seconds * R1 / 100 = 0.02 * R1 seconds
	LoopH: ACALL TIMER					; TIMER duration is 0.02 seconds
    DJNZ R0, LoopH

	CLR P1.4
	CLR P1.5
	CLR P1.6
	CLR P1.7

	;DEC R2
    MOV R0, 02H							; DelayLow = 2 seconds - DelayHigh = 2 seconds * R2 / 100 = 0.02 * R2 seconds
    LoopL: ACALL TIMER					; TIMER duration is 0.02 seconds
    DJNZ R0, LoopL

	LJMP ALWAYS

;--------------------------- 0.02 second TIMER ------------------------------

TIMER:				; 0.02 - 2 * 0.5 * 10^{-6} seconds
	NOP
	MOV TMOD, #01
	MOV TL0, #0D1H
	MOV TH0, #63H
	SETB TR0

	REPEAT: JNB TF0, REPEAT
	
	CLR TR0
	CLR TF0

	RET

;------------------------LCD Initialisation routine----------------------------------------------------
LCD_INIT:
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
         MOV   LCD_data,A     ;Move the command to LCD port
         SETB  LCD_rs         ;Selected data register
         CLR   LCD_rw         ;We are writing
         SETB  LCD_en         ;Enable H->L
		 ACALL DELAY
         CLR   LCD_en
         ACALL DELAY
		 ACALL DELAY
         RET                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
LCD_SendString:
	PUSH 0e0h
	LCD_SendString_Loop:
	 	 CLR   A                 ;clear Accumulator for any previous data
	         MOVC  A,@A+DPTR         ;load the first character in accumulator
	         JZ    EXIT              ;go to exit if zero
	         ACALL LCD_SendData      ;send first char
	         INC   DPTR              ;increment data pointer
	         SJMP  LCD_SendString_Loop    ;jump back to send the next character
EXIT:    POP 0e0h
         RET                     ;End of routine

;---------------------- delay routine-----------------------------------------------------
DELAY:	 
	PUSH 0
	PUSH 1
	MOV R1, #42
	LOOP1:	 DJNZ R1, LOOP1
	POP 1
	POP 0 
	RET
;------------- ROM text strings---------------------------------------------------------------
ORG 300h
My_String1:
     DB   "Duty Cycle:", 00H
My_String2:
	DB   "Pulse width:", 00H

END