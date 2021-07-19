ORG 0000H
LJMP START

START: 

MOV 40H, #0aH         ; Values generated using https://www.random.org/integers/?num=20&min=0&max=50&col=1&base=16&format=html&rnd=new
MOV 41H, #26H
MOV 42H, #2aH
MOV 43H, #31H
MOV 44H, #00H
MOV 45H, #09H
MOV 46H, #27H 
MOV 47H, #29H 
MOV 48H, #05H 
MOV 49H, #22H 
MOV 4AH, #0aH 
MOV 4BH, #08H 
MOV 4CH, #1eH 
MOV 4DH, #05H 
MOV 4EH, #30H 
MOV 4FH, #29H 
MOV 50H, #32H 
MOV 51H, #18H 
MOV 52H, #16H 
MOV 53H, #21H 

MOV R7, #13H          ; R7 is counter for looping 20 times

MOV R0, #40H		  ; R0 contains 40H. This is used to loop through array
MOV A, @ R0           ; Accumulator contains the value pointed by R0
MOV 01H, @ R0		  ; R1 contains greatest number

INC R0
MOV 02H, @ R0		  ; R2 contains second greatest number

SUBB A, 02H           ; Exchanging R1 and R2 if R1 < R2
JNC AGreater
MOV 02H, R1
MOV 01H, @ R0
AGreater: 

LOOP:				  ; Will iterate R7 times
INC R0
MOV 06H, @ R0		  ; R6 contains value pointed by R0

MOV A, R1             ; Now A contains greatest number
SUBB A, 06H			  ; If current value > greatest number	
JNC R1Greater
MOV 02H, R1
MOV 01H, R6           ; A is smaller. Copy R6 in A
SJMP Done

R1Greater:
MOV A, R2             ; Now A contains second greatest number
SUBB A, 06H           ; If current value > second greatest number
JNC R2Greater
MOV 02H, R6

R2Greater:
Done:
DJNZ R7, LOOP         ; Loop Back

MOV 70H, R1		      ; Greatest number
MOV 71H, R2			  ; Second greatest number

HERE: SJMP HERE
END