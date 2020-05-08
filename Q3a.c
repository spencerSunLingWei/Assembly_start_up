#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
	
volatile int*	HEX_3_0_ptr = (int *) 0xFF200020;
volatile int*	HEX_5_4_ptr = (int *) 0xFF200030;

char seg7[] = {	0x79, //E
			   	0x39, //C
				0x79, //E
				0x5b, //2
				0x66, //4
				0x4f  //3
			  };

char seg7_dark[] = {	0x00, //E
			   	0x00, //C
				0x00, //E
				0x00, //2
				0x00, //4
				0x00  //3
			  };

int main(){
	int value = 0;
	while(1){
		if (value>=100000){	//display light ECE243
			*HEX_3_0_ptr = seg7[5] | 
						seg7[4]<<8 |
						seg7[3]<<16 |
						seg7[2]<<24 ;
			*HEX_5_4_ptr = seg7[1] | 
						seg7[0]<<8 ;
		}
		else{	//clear dark ECE243
			*HEX_3_0_ptr = seg7_dark[5] | 
						seg7_dark[4]<<8 |
						seg7_dark[3]<<16 |
						seg7_dark[2]<<24 ;
			*HEX_5_4_ptr = seg7_dark[1] | 
						seg7_dark[0]<<8 ;
		}
		
		value++;
		if(value == 200000){
			value = 0;
		}
	}
}