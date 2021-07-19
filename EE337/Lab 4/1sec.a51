ORG 0H
	
	START:
	

	
	DELAY1s:								; Counts 1 second

		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
											; 4 + 3 + (1 + 167 * (3 + 39 * (3 + 2 * 152))) = 2000000
		MOV R7, #167						; 2000000 * 0.5 * 10^{-6} = 1
		LOOP1:
			MOV R6, #39
			LOOP2:
				MOV R5, #152
				LOOP3:	
				DJNZ R5, LOOP3
			DJNZ R6, LOOP2
		DJNZ R7, LOOP1

END
