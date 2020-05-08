#include <stdbool.h>
#include <math.h>
#include <stdlib.h>
#define N 8

//global variable declaration
volatile int pixel_buffer_start;

//helpper function declaration
void plot_pixel(int x, int y, short int line_color);
void clear_screen();
void draw_line(int x_0, int y_0, int x_1, int y_1, short int line_color);
void swap(int *a , int *b);
void wait_screen();

//the main function
int main(void){
    volatile int * pixel_ctrl_ptr = (int *) 0xFF203020;

    // declare other variables
    int color_box[N];
    int dx_box[N];
    int dy_box[N];
    int x_box[N];
    int y_box[N];
    int prev_x_box[N];
    int prev_y_box[N];
    int prevv_x_box[N];
    int prevv_y_box[N];
    bool bool_x_box[N];
    bool bool_y_box[N];
    short int color[8] = {0xFFFF, 0xF800, 0x07E0, 0x001F, 0x4521, 0x7777, 0x4421, 0x6600};

    // initialize location and direction of rectangles
    for(int i=0; i<N; i++){
        color_box[i] = color[rand()%8];
        dx_box[i] = rand()%2 *2 -1;
        dy_box[i] = rand()%2 *2 -1;;
        x_box[i] = rand()%316+1;
        y_box[i] = rand()%236+1;
        bool_x_box[i] = true;
        bool_y_box[i] = true;
        prev_x_box[i] = 1;
        prev_y_box[i] = 1;
        prevv_x_box[i] = 1;
        prevv_y_box[i] = 1;
    }

    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the
    // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_screen();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer

    clear_screen();
    while (1){
        /* Erase any boxes and lines that were drawn in the last iteration */
        for(int i=0; i<N; i++){
            int number = 0;
            for (int j=0; j<3; j++){
                draw_line(prevv_x_box[i]+number, prevv_y_box[i], prevv_x_box[i]+number, prevv_y_box[i]+3, 0x0000);
                number++;
            }
            draw_line(prevv_x_box[i], prevv_y_box[i], prevv_x_box[(i+1)%N], prevv_y_box[(i+1)%N], 0x0000);
        }

        for(int i=0; i<N; i++){
            int number = 0;
            for (int j=0; j<3; j++){
                draw_line(x_box[i]+number, y_box[i], x_box[i]+number, y_box[i]+3, color_box[i]);
                number++;
            }
            draw_line(x_box[i], y_box[i], x_box[(i+1)%N], y_box[(i+1)%N], color_box[i]);

            prevv_x_box[i] = prev_x_box[i];
            prevv_y_box[i] = prev_y_box[i];
            prev_x_box[i] = x_box[i];
            prev_y_box[i] = y_box[i];
        }

        for(int i=0; i<N; i++){
            if(bool_x_box[i] == true){
                x_box[i]+=dx_box[i];
            }
            else if(bool_x_box[i] == false){
                x_box[i]-=dx_box[i];
            }

            if(bool_y_box[i] == true){
                y_box[i]+=dy_box[i];
            }
            else if(bool_y_box[i] == false){
                y_box[i]-=dy_box[i];
            }

            if(dx_box[i]==1 && x_box[i]==317){
                bool_x_box[i] = false;
            }
            if(dx_box[i]==1 && x_box[i]==0){
                bool_x_box[i] = true;
            }
            if(dy_box[i]==1 && y_box[i]==237){
                bool_y_box[i] = false;
            }
            if(dy_box[i]==1 && y_box[i]==0){
                bool_y_box[i] = true;
            }

            if(dx_box[i]==-1 && x_box[i]==317){
                bool_x_box[i] = true;
            }
            if(dx_box[i]==-1 && x_box[i]==0){
                bool_x_box[i] = false;
            }
            if(dy_box[i]==-1 && y_box[i]==237){
                bool_y_box[i] = true;
            }
            if(dy_box[i]==-1 && y_box[i]==0){
                bool_y_box[i] = false;
            }
        }

        wait_screen();
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}






//waiting for the screen to finish drawing
void wait_screen(){
    volatile int * pixel_ctrl_ptr = (int *) 0xFF203020;
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

