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

//the main function
int main(){
    volatile int* pixel_ctrl_ptr = (int*) 0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen();
    draw_line(0, 0, 150, 150, 0x001F);   // this line is blue
    draw_line(150, 150, 319, 0, 0x07E0); // this line is green
    draw_line(0, 239, 319, 239, 0xF800); // this line is red
    draw_line(319, 0, 0, 239, 0xF81F);   // this line is a pink color
    return 0;
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
			