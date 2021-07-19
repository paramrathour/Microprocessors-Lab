ORG 0000H
LJMP START

START: 

MOV 60H, #3				; Dimension of square matrix (say matrix A is n*n)
MOV 61H, #5         	; Generated from here https://www.random.org integers/?num=9&min=1&max=10&col=3&base=10&format=html&rnd=new
MOV 62H, #6
MOV 63H, #1
MOV 64H, #4
MOV 65H, #10
MOV 66H, #6
MOV 67H, #1
MOV 68H, #6
MOV 69H, #2

MOV R3, 60H				; R3 stores Dimension of square matrix
MOV R4, #61H			; R4 storing address of first element
						; I want R4 to store address of first element - (n+1). So, below loop
MOV 07H, R3				; This loop decreases R4 value by n+1
DEC R4
INIT:
DEC R4
DJNZ R7, INIT
						; From line 26-56, we check A[R6][R7] and A[R7][R6] for (R7 in n to 1) and R6 in (R7 to 1)
MOV 07H, R3				
LOOP1:
MOV 06H, R7				
LOOP2:
MOV A, 06H				; If R6 equals R7 no need to check as A[R6][R7] = A[R7][R6]
CJNE A, 07H, CONTINUE
LJMP SKIP
CONTINUE:
						; Calculates A[R7][R6]
MOV B, R3				; B takes number of columns
MOV 00H, R4				; Initialise R0 with R4
MOV A, R7				; Calculate number of times to increment R0 to get A[R7][R6]
MUL AB					; = n * R7 + R6
ADD A, R6
ADD A, R0				; increment R0: n * R7 + R6 times
MOV R0, A
MOV 01H, @ R0			; Use value stored in R0 to get address of A[R7][R6]

 						; Calculates A[R6][R7]
MOV B, R3			 	; B takes number of columns
MOV 00H, R4				; Initialise R0 with R4	
MOV A, R6 				; Calculate number of times to increment R0 to get A[R6][R7]
MUL AB 					; = n * R6 + R7
ADD A, R7 		
ADD A, R0 				; increment R0: n * R6 + R7 times
MOV R0, A 		
MOV 02H, @ R0 			; Use value stored in R0 to get address of A[R6][R7]

MOV A, R1				; If A[R6][R7] not equal to A[R7][R6], matrix is not symmetric
CJNE A, 02H, NOTSYMMETRIC
SKIP:
DJNZ R6, LOOP2			; Decrement R6 and Jump if Not Zero
DJNZ R7, LOOP1			; Decrement R6 and Jump if Not Zero
SETB PSW.5				; Sets PSW.5 to 1 as matrix was symmetric
SJMP HERE
NOTSYMMETRIC: 
JBC PSW. 5, HERE 		; Jump if Bit Set and Clear Bit		; Matrix was not symmetric, so clears PSW.5 if it is 1
HERE: SJMP HERE
END