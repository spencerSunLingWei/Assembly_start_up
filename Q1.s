.text
.global _start

_start: 	LDR		R12, =0xFF203020		//volatile int *pixel_ctrl_ptr = 0xFF203020;
			BL		MAIN

// Question 1(a)

WAIT_FOR_SYNC:	MOV		R0, #1				
				STR		R0, [R12]			//*pixel_ctrl_ptr = 1;
WHILE_WFS:		LDR		R1, [R12, #12]		
				ANDS	R1, #0b1
				BNE		WHILE_WFS			//while( (*(pixel_ctrl_ptr+3) * &0x1 ) != 0)
				MOV		PC, LR
				
//	Question 1(b)

PLOT_PIXEL:		LDR		R3, [R12, #4]		//int back_buffer = *(pixel_ctrl_ptr +1)

				LSL		R1, #10				//y<<10
				LSL		R0, #1				//x<<1
				ADD		R1, R0				//y<<10 + x<<1
				
				STRH	R2, [R3, R1]		//*(back_buffer + y<<10 + x<<1) = color;
				MOV		PC, LR

//	Question 1(c)

CLEAR_SCREEN:	PUSH 	{R4-R7, LR}
					
				MOV		R4, #0				//x=0
FOR_Y:			MOV		R5, #0				//y=0
					
FOR_PLOT:		MOV		R0, R4				
				MOV		R1, R5
				LDR		R2, =0x0000			
				BL		PLOT_PIXEL			//plot_pixel(x,y,0);
				
				ADD		R5, #1
				CMP		R5, #240
				BLT		FOR_PLOT			//for(y=0; y<240; y++)
				
				ADD		R4, #1
				CMP		R4, #320
				BLT		FOR_Y				//for(x=0; x<320; x++)
				
				POP		{R4-R7, PC}
					
//	Question 1(d)

DRAW_LINE:		PUSH 	{R4-R7, LR}

				MOV		R4, R0				//R4=x0
				MOV		R5, R1				//R5=x1
				MOV		R6, R2				//R6=y
				MOV		R7, R3				//R7=color
				
				CMP		R4, R5
				BGT		END_LINE
				
LOOP_LINE:		MOV		R0, R4
				MOV		R1, R6
				MOV		R2, R7
				BL		PLOT_PIXEL			//plot_pixel(x,y,color);
				
				ADD		R4, #1
				CMP		R4, R5
				BLE		LOOP_LINE			//for(x=x0; x<=x1; x++) 

END_LINE:		POP		{R4-R7, PC}

// Question 1(e)

MAIN:			BL		CLEAR_SCREEN		//clear_screen();
		
				MOV		R4, #100			//x_0 = 100;
				MOV		R5, #220			//x_1 = 220;
				MOV		R6, #0				//y = 0;
				MOV		R7, #1				//y_dir = 1;
				
				MOV		R0, R4
				MOV		R1, R5
				MOV		R2, R6
				LDR		R3, =0xFFFF			
				BL		DRAW_LINE			//draw_line(x_0, x_1, 0, 0xFFFF);
					
WHILE_MAIN:		BL		WAIT_FOR_SYNC		//wait_for_sync();
				
				MOV		R0, R4
				MOV		R1, R5
				MOV		R2, R6
				LDR		R3, =0x0000		
				BL		DRAW_LINE			//draw_line(x_0, x_1, y, 0x0000);

				ADD		R6, R7
				CMP		R6, #1				//y==0?
				MOVEQ	R7, #1				//y_dir = -y_dir
				CMP		R6, #239			//Y==239?
				MOVEQ	R7, #-1				//y_dir = -y_dir
				
				MOV		R0, R4
				MOV		R1, R5
				MOV		R2, R6
				LDR		R3, =0xFFFF			
				BL		DRAW_LINE			//draw_line(x_0, x_1, 0, 0xFFFF);

				B		WHILE_MAIN


				
			


