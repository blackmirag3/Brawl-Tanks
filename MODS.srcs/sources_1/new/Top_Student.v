`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME: Sim Jing Jie Ryan 
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input clk, btnC, btnU, btnL, btnR, btnD, [15:0] sw, output [7:0] JC);
    
    wire clk_6p25Mhz;
    wire fb, send_pixel, sample_pixel;
    wire [15:0] oled_data;
    wire [12:0] pixel_index, x, y;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    slow_clock c0 (clk, 32'd7, clk_6p25Mhz);
    
    Oled_Display unit_oled (.clk(clk_6p25Mhz), 
                        .reset(0), 
                        .frame_begin(fb), 
                        .sending_pixels(send_pixel),
                        .sample_pixel(sample_pixel), 
                        .pixel_index(pixel_index), 
                        .pixel_data(oled_data), 
                        .cs(JC[0]), 
                        .sdin(JC[1]), 
                        .sclk(JC[3]), 
                        .d_cn(JC[4]), 
                        .resn(JC[5]), 
                        .vccen(JC[6]),
                        .pmoden(JC[7]));
                        
    //task_d d_unit (.clock(clk), .start(btnC), .up(btnU), .left(btnL), .right(btnR), .speed_sw(sw[0]), .x(x), .y(y), .oled_data(oled_data));
    taskB b_unit(.clk(clk), .sw0(sw[0]), .x(x), .y(y), .oled_data(oled_data), .btnC(btnC), .btnR(btnR), .btnL(btnL));
                
endmodule