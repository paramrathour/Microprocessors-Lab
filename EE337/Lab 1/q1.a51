ORG 0000H
LJMP START

START: 
MOV 70H, #42        ; Input Number
MOV A, 70H	        ; A stores value at 70H
MOV 71H, #0         ; 71H stores number of 1s in 70H
MOV R1, #8          ; For looping 8 times

LOOP:
RLC A				; Rotate A left with carry
JNC SKIP			; If carry present increment 1s count
INC 71H
SKIP:
DJNZ R1, LOOP       ; Loop Back

HERE: SJMP HERE
END