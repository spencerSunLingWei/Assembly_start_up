//lab5part1




			.text                   // executable code follows
			.global _start        
          
_start:    	MOV 	R0, #0
			LDR 	R6, =0xFF200050 	// KEY address in R6
			LDR		R5, =0xFF200020 	// HEX address in R5
			
//check which key is being pressed
KEY_DIVISION:	LDR		R4, [R6]			// load key value
 				CMP		R4, #0b0001
				BEQ     KEY0_PRESSED
				CMP     R4, #0b0010
				BEQ		KEY1_PRESSED
				CMP		R4, #0b0100
				BEQ     KEY2_PRESSED
				CMP		R4, #0b1000
				BEQ		KEY3_PRESSED
				B		KEY_DIVISION

//key 0
KEY0_PRESSED:	LDR		R4, [R6]	
			    CMP		R4, #0
				BEQ		KEY0_RELEASED
				B		KEY0_PRESSED
KEY0_RELEASED:	MOV		R3, #0
				MOV		R0, #0
				BL		SEG7_CODE
				STR		R2, [R5]
				B		KEY_DIVISION		

//key 3
KEY3_PRESSED:	LDR		R4, [R6]	
			    CMP		R4, #0
				BEQ		KEY3_RELEASED
				B		KEY3_PRESSED
KEY3_RELEASED:	MOV		R0, #10
				BL		SEG7_CODE
				MOV		R3, #1         			//bool R3 == true 
				STR		R2, [R5]
				B		KEY_DIVISION		

//key 1
KEY1_PRESSED:	LDR		R4, [R6]	
			    CMP		R4, #0
				BEQ		KEY1_RELEASED
				B		KEY1_PRESSED
KEY1_RELEASED:	CMP		R3, #1
				BEQ		FLAG_KEY1
				BNE		KEY1_CONTINUED	
FLAG_KEY1:		MOV     R3, #0 					//bool R3 == false 
				MOV		R0, #0
				BL		SEG7_CODE
				STR		R2, [R5]
				B		KEY_DIVISION
KEY1_CONTINUED: ADD     R0, #1
				BL		SEG7_CODE     			
				STR		R2, [R5]
				CMP		R0, #9
				BEQ		KEY1_SET
				B		KEY_DIVISION
KEY1_SET:		MOV		R0, #-1
				B		KEY_DIVISION
				
//key 2
KEY2_PRESSED:	LDR		R4, [R6]	
			    CMP		R4, #0
				BEQ		KEY2_RELEASED
				B		KEY2_PRESSED
KEY2_RELEASED:	CMP		R3, #1
				BEQ		FLAG_KEY2
				BNE		KEY2_CONTINUED	
FLAG_KEY2:		MOV     R3, #0 					//bool R3 == false 
				MOV		R0, #0
				BL		SEG7_CODE
				STR		R2, [R5]
				MOV		R0, #10
				B		KEY_DIVISION
KEY2_CONTINUED: SUB		R0, #1
				BL		SEG7_CODE     			
				STR		R2, [R5]
				CMP		R0, #0
				BEQ		KEY2_SET
				B		KEY_DIVISION
KEY2_SET:		MOV		R0, #10
				B		KEY_DIVISION	
				
//seg 7 display
SEG7_CODE:  MOV     R1, #BIT_CODES  
			ADD     R1, R0         	
            LDRB    R2, [R1]       	
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
			.byte 	0b00000000