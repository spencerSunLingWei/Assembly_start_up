.text
.global _start

_start: 	LDR R6, =0xFF200040 	//SW address in R6
			LDR	R7, =0xFF200020
			MOV	R4, #0				//keep record past values for displaying 3-0
			MOV	R5, #0				//keep record past values for displaying 4-5
			
MAIN:		LDR	R0, [R6]			//Read SW value to R0
			MOV R1, #0				//final value being display in R1
			MOV	R3, #0				//R3 is a counter to 3
			
CAMPARE:	CMP	R3, #3				
			BEQ	DISPLAY
			
			PUSH {R2}
			MOV R2, R0
			ANDS R2, #0b1
			POP	{R2}
			
			BNE	HAVENUMBER
			
SHIFT:			ADD R3, #1
				LSR R0, #1
				B	CAMPARE
			
HAVENUMBER:		CMP	R3, #0
				ADDEQ	R1, #1
				
				CMP	R3, #1
				ADDEQ	R1, #2
				
				CMP	R3, #2
				ADDEQ	R1, #4
				
				B SHIFT
				
DISPLAY:	CMP	R1, #0
			BEQ	DISPLAY_0
			
			CMP	R1, #1
			BEQ	DISPLAY_1
			
			CMP	R1, #2
			BEQ	DISPLAY_2
			
			CMP	R1, #3
			BEQ	DISPLAY_3
			
			CMP	R1, #4
			BEQ	DISPLAY_4
			
			CMP	R1, #5
			BEQ	DISPLAY_5
			
DISPLAY_0:	MOV	R0, #0x3f
			ORR	R4, R0
			STR	R4,[R7]
			B	MAIN

DISPLAY_1:	MOV	R0, #0x06
			LSL	R0, #8
			ORR	R4, R0
			STR	R4,[R7]
			B	MAIN
			
DISPLAY_2:	MOV	R0, #0x5b
			LSL	R0, #16
			ORR	R4, R0
			STR	R4,[R7]
			B	MAIN
			
DISPLAY_3:	MOV	R0, #0x4f
			LSL	R0, #24
			ORR	R4, R0
			STR	R4,[R7]
			B	MAIN

DISPLAY_4:	PUSH {R7}	
			LDR	R7, =0xFF200030
			MOV	R0, #0x66
			ORR	R5, R0
			STR	R5,[R7]
			POP {R7}
			B	MAIN
			
DISPLAY_5:	PUSH {R7}	
			LDR	R7, =0xFF200030
			MOV	R0, #0x6d
			LSL	R0, #8
			ORR	R5, R0
			STR	R5,[R7]
			POP {R7}
			B	MAIN

			
SEG7: 	.byte	0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x67
		.end