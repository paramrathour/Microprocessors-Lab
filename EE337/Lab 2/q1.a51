ORG 0000H
LJMP START

START: 

MOV 50H, #63H		; 143 in decimal		; Let this value be n

MOV A, 50H

MOV B, #10			; (A mod 10) gives one's digit in decimal notation
DIV AB
MOV R1, B			; R1 is one's digit
					; Now, A = floor(n / 10)
MOV B, #10			; (A mod 10) gives ten's digit in decimal notation
DIV AB
MOV R2, B			; R2 is ten's digit
					; Now, A = floor(floor(n / 10) / 10)
MOV B, #10			; (A mod 10) gives hundred's digit in decimal notation
DIV AB
MOV R3, B			; R3 is hundred's digit

MOV A, R2
SWAP A              ; Ten's digit in most significant nibble
ADD A, R1			; One's digit in least significant nibble

MOV 53H, A 			; 53H Done
MOV 52H, R3			; 52H Done

HERE: SJMP HERE
END