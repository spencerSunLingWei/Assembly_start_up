/*lab4part3*/

          		.text                   // executable code follows
          		.global _start     
             
_start:       
		  	MOV     R5, #0          // initialize R5 for longest 1's
		  	MOV     R6, #0          // initialize R6 for longest 0's
		  	MOV     R7, #0          // initialize Ry for longest alternating 1's & 0's
			MOV     R8, #0xFFFFFFFF // R8 is all ones
          		MOV     R3, #TEST_NUM   // R3 is a pointer to the test numbers		  
			MOV     SP, #0x40000000 // stack pointer initialization

//main function
MAIN:     		LDR     R1, [R3], #4    // Load the test number into R1
			PUSH    {R1} 
		  	CMP     R1, #0          // to check end of the list
		  	BEQ     END             // if it is zero, no need for looping
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
			ADD     R0, #1		// ex: 101, two steps of changes, three elements
		  	CMP     R7, R0          // compare the R5 & R0
		  	MOVLT   R7, R0 
		  	B       MAIN            // keep looping the main function
END:      		B       END

//longest 1's
ONES:     		MOV     R0, #0          // R0 will hold the result for each subroutine
LOOP_ONES:      	CMP     R1, #0          // loop until the data contains no more 1's
          		BEQ     END_ONES           
          		LSR     R2, R1, #1      // perform SHIFT, followed by AND
          		AND     R1, R2      
          		ADD     R0, #1          // count the string length so far
          		B       LOOP_ONES            
END_ONES: 		LDR     R1, [SP] 
			MOV     PC, LR          //return to the main function 

//longest 0's
ZEROS:    		EOR     R1, R8          // flip 0 & 1 in R1
               		B       ONES            // do the sub_ones

//longest 1's & 0's
ALTERNATE:      	ASR     R2, R1, #1      // shift to the right 1 position
			EOR     R1, R2          // change to 1 with the change 1-0 or 0-1
			B       ONES

TEST_NUM: 		.word  0x00000B51 
			.word  0xFFFFFFFF 
			.word  0x0000000F
			.word  0xAAAAAAAA
		             		  

          		.end  