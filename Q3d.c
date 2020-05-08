#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
	
volatile int *HEX_3_0_ptr = (int *) 0xFF200020;
volatile int *HEX_5_4_ptr = (int *) 0xFF200030;
volatile int *LEDR_ptr = (int *) 0xFF200000;
volatile int *Interval_timer_base_ptr = (int *) 0xFF202000;
volatile int *KEY_ptr = (int *) 0xFF200050;

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
	
	bool key_0_pressed = false;
	bool key_1_pressed = false;
	bool key_2_pressed = false;
	bool key_3_pressed = false;
	
	bool skip = true;
	bool correct_way = true;
	while(1){
		
		*(Interval_timer_base_ptr + 2) = count_down_number & 0xFFFF; //set up the lower count down value;
		*(Interval_timer_base_ptr + 3) = count_down_number >> 16; //set up the higher count down value;
		*(Interval_timer_base_ptr + 1) = 6; //start, cont = 1

		//delay loop
		int value = *Interval_timer_base_ptr;
		while( value%2 != 1){
			value = *Interval_timer_base_ptr;
		}
		
		//check key if pressed  
		int KEY_value = *KEY_ptr;

		if(KEY_value == 0b0001){
			key_0_pressed = true;
		}
		else if(KEY_value == 0b0010){
			key_1_pressed = true;
		}
		else if(KEY_value == 0b0100){
			key_2_pressed = true;
		}
		else if(KEY_value == 0b1000){
			key_3_pressed = true;
		}

		//check key if released
		KEY_value = *KEY_ptr;
		if(key_0_pressed == true && KEY_value == 0b0000){
			key_0_pressed = false;

			if(skip == true) skip = false;
			else skip = true;
		}
		else if(key_1_pressed == true && KEY_value == 0b0000){
			key_1_pressed = false;
			
			*(Interval_timer_base_ptr + 1) = 0b1000; //stop=1, START = 0, cont = 0
			count_down_number = count_down_number /2;
		}
		else if(key_2_pressed == true && KEY_value == 0b0000){
			key_2_pressed = false;
			
			*(Interval_timer_base_ptr + 1) = 0b1000; //stop=1, START = 0, cont = 0
			count_down_number = count_down_number *2;
		}
		else if(key_3_pressed == true && KEY_value == 0b0000){
			key_3_pressed = false;

			if(correct_way == true) correct_way = false;
			else correct_way = true;
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
	
		if(skip == true){
			if(correct_way == true){
				char temp = seg7[0];
				for(int i=0; i<19; i++){
					seg7[i] = seg7[i+1];
				}
				seg7[19] = temp;
			}
			else{
				char temp = seg7[19];
				for(int i=19; i>0; i--){
					seg7[i] = seg7[i-1];
				}
				seg7[0] = temp;
			}
		}
	}
}