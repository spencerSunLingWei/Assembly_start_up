#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
	
volatile int *HEX_3_0_ptr = (int *) 0xFF200020;
volatile int *HEX_5_4_ptr = (int *) 0xFF200030;
volatile int *LEDR_ptr = (int *) 0xFF200000;
volatile int *Interval_timer_base_ptr = (int *) 0xFF202000;
volatile int *Edge_capture_ptr = (int *) 0xFF20005C;

int count = 0; 


int main(){
	//set up the delay loop
	int count_down_number = 25000000;
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
		*Interval_timer_base_ptr = 0;	//reset counter
		*LEDR_ptr = 1 << count;			
		
		//change counter value
		if(twice_capture == 0){
			count++;
			if(count == 10){
				count = 0;
			}
		}
		else{
			count--;
			if(count == -1){
				count = 9;
			}
		}
	}
}