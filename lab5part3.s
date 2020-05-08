//lab5part3

.text
.global _start

_start:		
			LDR 	R8, =0xFFFEC600
			LDR		R7, =20000000
			STR		R7, [R8]
			MOV		R7, #0b011
			STR		R7, [R8,#8]
			
			MOV     R3, #0
			MOV     R4, #0
			MOV     R11, #0
			MOV     R12, #0
			LDR 	R6, =0xFF200020
			LDR		R9, =0xFF20005C // Edge capture
			
MAIN:		LDR		R10, [R9]
			CMP		R10, #0
			BEQ		GO
			LDR		R10, =0xFFFFFFFF
			STR		R10,[R9]
			ADD 	R11, #1
			CMP		R11, #2
			BEQ		SET_RUN
			
SET_RUN:	MOV		R11, #0
			CMP		R12, #0
			BEQ		HIGH
			BNE		LOW
HIGH:		MOV		R12, #1
			B		GO
LOW:		MOV		R12, #0
			B		GO
			
GO:			CMP		R12, #0
			BEQ		MAIN
			B		DO_DELAY

//displaying
DISPLAY:	MOV		R0, R3
			BL		SEG7_CODE
			MOV		R5, R2
			MOV		R0, R4
			BL		SEG7_CODE
			LSL		R2, #8
			ORR		R5, R2
			STR		R5, [R6]
				
			ADD		R3, #1
			CMP		R3, #10
			BEQ		RESET_R3
			BNE		MAIN
RESET_R3: 	MOV		R3, #0
			ADD		R4, #1
			CMP		R4, #10
			BEQ		RESET_R4
			B		MAIN
RESET_R4:	MOV 	R4, #0
			B		MAIN

//Delay loop			
DO_DELAY: 	LDR		R7, [R8, #0xC]
			CMP		R7, #0
			BEQ		DO_DELAY
			STR		R7, [R8,#0xC]
			B		DISPLAY
			
//seg 7 display
SEG7_CODE:  MOV     R1, #BIT_CODES  
			ADD     R1, R0         	
            LDRB    R2, [R1]       	
            MOV     PC, LR              
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
			.byte	0b00000000