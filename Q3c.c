#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
	
volatile int *HEX_3_0_ptr = (int *) 0xFF200020;
volatile int *HEX_5_4_ptr = (int *) 0xFF200030;
volatile int *LEDR_ptr = (int *) 0xFF200000;
volatile int *Interval_timer_base_ptr = (int *) 0xFF202000;
volatile int *Edge_capture_ptr = (int *) 0xFF20005C;

int count = 0; 
char seg7[] = {	
				0x3E, //U
				0x00, //_
				0x5c, //O
				0x71, //F
				0X00, //_
				0x78, //T
				0x00, //_
				0x79, //E
			   	0x39, //C
				0x79, //E
			   	0x40, //-
				0x5b, //2
				0x66, //4
				0x4f, //3
				0x00, //_
				0x00, //_
				0x00, //_
				0x00, //_
				0x00, //_
				0x00, //_
			  };
		

int main(){
	//set up the delay loop
	int count_down_number = 50000000;
	*(Interval_timer_base_ptr + 2) = count_down_number & 0xFFFF; //set up the lower count down value;
	*(Interval_timer_base_ptr + 3) = count_down_number >> 16; //set up the higher count down value;
	*(Interval_timer_base_ptr + 1) = 6; //start, cont = 1
	
	int twice_capture = 0;
	
	while(1){

		//delay loop
		int value = *Interval_timer_base_ptr;
		while( value%2 != 1){
			value = *Interval_timer_base_ptr;
		}
		
		//consider for key inturpts
		if( *Edge_capture_ptr != 0){
			*Edge_capture_ptr = 0xFFFFFFFF; //enable reset edge capture
			
			twice_capture++;
			if(twice_capture == 2){
				twice_capture = 0;
			}
		}
		
		//display loop	
		*HEX_3_0_ptr = seg7[5] | 
						seg7[4]<<8 |
						seg7[3]<<16 |
						seg7[2]<<24 ;
		*HEX_5_4_ptr = seg7[1] | 
						seg7[0]<<8 ;

		//change counter value
		*Interval_timer_base_ptr = 0;	//reset
		if(twice_capture == 0){
			char temp = seg7[0];
			for(int i=0; i<19; i++){
				seg7[i] = seg7[i+1];
			}
			seg7[19] = temp;
		}
	}
}