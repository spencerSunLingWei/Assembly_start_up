/*lab4part4*/
			.text                   // executable code follows
          	.global _start     

_start:		MOV     R5, #0          // initialize R5 for longest 1's
		  	MOV     R6, #0          // initialize R6 for longest 0's
		  	MOV     R7, #0          // initialize Ry for longest alternating 1's & 0's
			MOV     R10, #0xFFFFFFFF // R8 is all ones
          	MOV     R3, #TEST_NUM   // R3 is a pointer to the test numbers		  
			MOV     SP, #0x40000000 // stack pointer initialization

//main function
MAIN:     		LDR     R1, [R3], #4    // Load the test number into R1
				PUSH    {R1} 
		  		CMP     R1, #0          // to check end of the list
		  		BEQ     DIS_STAGE   	// if it is zero, no need for looping, go display result
		  		// longest 1's
		  		BL      ONES            // get the longest string in R0 from the sub_ones
		  		CMP     R5, R0          // compare the R5 & R0
		  		MOVLT   R5, R0          // keep the best result in R5
		  		// longest 0's
		  		BL      ZEROS           // get the longest string in R0 from the sub_zeros
		  		CMP     R6, R0          // compare the R5 & R0
		  		MOVLT   R6, R0 
		  		// longest 1&0's
		  		BL      ALTERNATE       // get the longest string in R0 from the sub_alternate				
				CMPS    R0,#0
				BEQ     CASE
				ADD     R0, #1			// ex: 101, two steps of changes, three elements
CASE:           CMP     R7, R0          // compare the R5 & R0
		  		MOVLT   R7, R0 
		  		B       MAIN            // keep looping the main function
DIS_STAGE:  	B       DISPLAY			// display the result

//longest 1's
ONES:     		MOV     R0, #0          // R0 will hold the result for each subroutine
LOOP_ONES:      CMP     R1, #0          // loop until the data contains no more 1's
          		BEQ     END_ONES           
          		LSR     R2, R1, #1      // perform SHIFT, followed by AND
          		AND     R1, R2      
          		ADD     R0, #1          // count the string length so far
          		B       LOOP_ONES            
END_ONES: 		LDR     R1, [SP] 
				MOV     PC, LR          //return to the main function 

//longest 0's
ZEROS:    		EOR     R1, R10         // flip 0 & 1 in R1
               	B       ONES            // do the sub_ones

//longest 1's & 0's
ALTERNATE:      	ASR     R2, R1, #1      // shift to the right 1 position
			EOR     R1, R2          // change to 1 with the change 1-0 or 0-1
			B       ONES

/* Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4 */
DISPLAY:    		//address for HEX0-3
					LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            
			//display R5 to HEX0-1	
					MOV     R1, #0
					MOV     R0, R5          // display R5 on HEX1-0
            		BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            		MOV     R9, R1          // save the tens digit in R9
            		BL      SEG7_CODE       
            		MOV     R4, R0          // R4 = ones after seg7
            		MOV     R0, R9          // R0 = tens digit
            		BL      SEG7_CODE       
            		LSL     R0, #8		// R0 = tens after seg7 times 16
					ORR     R4, R0			
            
		    	//display R6 to HEX2-3
					MOV     R1, #0
            		MOV     R0, R6          // display R6 on HEX2-3
            		BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            		MOV     R9, R1          // save the tens digit in R9
            		BL      SEG7_CODE       
            		LSL     R0, #16
					ORR     R4, R0          // R4 = ones after seg7
            		MOV     R0, R9          // R0 = tens digit
            		BL      SEG7_CODE       
            		LSL     R0, #24		// R0 = tens after seg7 times 24*2
					ORR     R4, R0		
			
			//display R5 & R6
					STR     R4, [R8]        // display the numbers from R6 and R5
			
			//address for HEX5-6
					LDR     R8, =0xFF200030 // base address of HEX5-HEX4
            
			//display R6 to HEX2-3
           			MOV     R1, #0
					MOV     R0, R7          // display R7 on HEX4-5
            		BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            		MOV     R9, R1          // save the tens digit in R9
            		BL      SEG7_CODE       
					MOV     R4, R0          // R4 = ones after seg7
            		MOV     R0, R9          // R0 = tens digit
            		BL      SEG7_CODE       
            		LSL     R0, #8 		// R0 = tens after seg7 times 16
					ORR     R4, R0	
			
			//display R7
            		STR     R4, [R8]        // display the number from R7
					B		END

/*tens git in R1, ones digit in R0*/
DIVIDE:     MOV    R2, #0
CONT:       CMP    R0, #10
            BLT    DIV_END
            SUB    R0, #10
            ADD    R2, #1
            B      CONT
DIV_END:    MOV	   R1,R2
	    	MOV    PC, LR

/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit patterm to be written to the HEX display
 */
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
			
TEST_NUM: 	//.word 0x00000B51
			//.word  0xFFFFFFFF 
			//.word  0x0000000F
			//.word  0xAAAAAAAA
			.word  0x00000000
		             		  
END:        .end  