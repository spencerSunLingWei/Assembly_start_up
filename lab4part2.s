/* lab4part2 */

          .text                   // executable code follows
          .global _start                  

_start:       
	  MOV     R5, #0          // initialize R5 as the final result
          MOV     R3, #TEST_NUM   // R3 is a pointer to the test numbers

MAIN:     LDR     R1, [R3], #4    // Load the test number into R1
	  CMP     R1, #0          // check end list
	  BEQ     END             // if it is zero, no need for the sub_ones
	  BL      ONES            // get the longest string in R0 from the sub_ones
	  CMP     R5, R0          // compare the R5 & R0
	  MOVLT   R5, R0          // keep the best result in R5
	  B       MAIN            // keep looping the main function
END:      B       END

ONES:     MOV     R0, #0          // R0 will hold the result for each subroutine
LOOP:     CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     END_ONES           
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R2      
          ADD     R0, #1          // count the string length so far
          B       LOOP            
END_ONES: MOV     PC, LR          //return to the main function 

TEST_NUM: .word   0xf000000f
		  .word   0xff00000f
		  .word	  0xfff0000f
		  .word   0xffff000f
		  .word   0x0000000f
		  .word   0x0000010f
		  .word   0x1000000f
		  .word   0x0001000f
		  .word   0x0010000f
		  .word   0xfffff00f
		  .word   0x0              //end of the list
	  .end         
