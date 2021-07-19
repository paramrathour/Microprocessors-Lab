.MODEL COMPACT
ORG 100H
.DATA
S1 DB "Indian Institute of Technology Bombay",0
LEN EQU $-s1
S2 DB LEN DUP(?),0

.CODE
MAIN:


LEA SI, S1 						; Put address of source string here (Default is S1)
LEA DI, S2 						; Put address of destination string here (Default is S2)
MOV AX, 5 						; Put n value here
MOV SP, 0xDF20 					; Q1.a)
PUSH DI
PUSH SI
PUSH AX
CALL MOVER  

STOP: JMP STOP

MOVER:
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SS
	PUSH BP
	PUSH SI
	PUSH DI
	PUSH DS
	PUSH ES
	    
    CLD
	MOV BP, SP
	MOV CX, [BP+20]			; Q1.b)
	MOV SI, [BP+22]
	MOV DI, [BP+24]
	REP MOVSB

	POP ES
	POP DS
	POP DI
	POP SI
	POP BP
	POP SS
	POP DX
	POP CX
	POP BX
	
	RET 6					; Q1.c)