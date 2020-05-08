#include <stdbool.h>
#include <math.h>
#include <stdlib.h>
	
//global variable declaration
volatile int pixel_buffer_start;

//helpper function declaration
void plot_pixel(int x, int y, short int line_color);
void clear_screen();
void draw_line(int x_0, int y_0, int x_1, int y_1, short int line_color);
void swap(int *a , int *b);
void wait_screen(volatile int* pixel_ctrl_ptr);

//the main function
int main(){
    volatile int* pixel_ctrl_ptr = (int*) 0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen();
	
	bool is_plus = true;
	int y = 0;
	while(1){
		draw_line(30, y, 300, y, 0xFFFF);
		wait_screen(pixel_ctrl_ptr);
		draw_line(30, y, 300, y, 0x0000);
		y = (is_plus) ? (y+1) : (y-1);
		if(y==240){
			is_plus = false;
		}
		if(y==0){
			is_plus = true;
		}
	}
    return 0;
}

//waiting for the screen to finish drawing
void wait_screen(volatile int* pixel_ctrl_ptr){
    *pixel_ctrl_ptr = 1;
    register int status;
	status = *(pixel_ctrl_ptr + 3);
    while((status & 0x01) == 1){
        status = *(pixel_ctrl_ptr + 3);
    }
}

//helper function to plot one pixel with a color
void plot_pixel(int x, int y, short int line_color){
	*(short int*)(pixel_buffer_start + (y<<10) + (x<<1)) = line_color;
}

//helper function to clear the screen to black color
void clear_screen(){
	for(int x=0; x<320; x++){
		for(int y=0; y<240; y++){
			plot_pixel(x, y, 0x0000);
		}
	}
}	

//helper function for drawing a line
void draw_line(int x_0, int y_0, int x_1, int y_1, short int line_color){
    bool is_steep = abs(y_1 - y_0) > abs(x_1 - x_0);

    if (is_steep){
        swap(&x_0, &y_0);
        swap(&x_1, &y_1);
    }
    if (x_0 > x_1){
        swap(&x_0, &x_1);
        swap(&y_0, &y_1);
    }

    int delta_x = x_1 - x_0;
    int delta_y = abs(y_1 - y_0);
    int error = - (delta_x / 2);
    int y = y_0;
    int y_step = (y_0 < y_1) ? 1 : -1;
	
    for(int x = x_0; x <= x_1; x++){
        if(is_steep){
            plot_pixel(y,x,line_color);
        }
        else{
            plot_pixel(x,y,line_color);
        }

        error += delta_y;

        if(error >= 0){
            y += y_step;
            error -= delta_x;
        }
    }
}

//helper function to swap the memory of a and b
void swap(int *a, int *b){
    int temp = 0;
    temp = *a;
    *a = *b;
    *b = temp;
}
			