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


module Top_Student (input clk, btnC, btnD, [15:0] sw, ps2_clk, ps2_data, output [7:0] JC);
    
    wire clk_6p25Mhz, clk_12p5Mhz, clk_25Mhz, clk_1hz;
    wire fb, send_pixel, sample_pixel;
    wire [15:0] oled_data;
    wire [12:0] pixel_index, x, y;
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire left, middle, right, new_event;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    slow_clock c0(.CLOCK(clk), .m(32'd 7), .SLOW_CLOCK(clk_6p25Mhz));
    slow_clock c1(.CLOCK(clk), .m(32'd 3), .SLOW_CLOCK(clk_12p5Mhz));
    slow_clock c2(.CLOCK(clk), .m(32'd 1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c3(.CLOCK(clk), .m(32'd 49999999), .SLOW_CLOCK(clk_1hz));
    
    MouseCtl unit_mouse (.clk(clk_6p25Mhz),
                        .rst(0),
                        .value(0),
                        .setx(0),
                        .sety(0),
                        .setmax_x(0),
                        .setmax_y(0),
                        .xpos(xpos),
                        .ypos(ypos),
                        .zpos(zpos),
                        .left(left),
                        .right(right),
                        .new_event(new_event));
                        
//    paint unit_paint (.mouse_x(xpos),
//                    .mouse_y(ypos),
//                    .mouse_l(left),
//                    .reset(right),
//                    .pixel_index(pixel_index),
//                    .enable(1),
//                    .clk_100M(clk),
//                    .clk_25M(clk_25Mhz),
//                    .clk_12p5M(clk_12p5Mhz),
//                    .clk_6p25(clk_6p25Mhz),
//                    .slow_clk(clk_1hz),
//                    .colour_chooser(oled_data));
                           
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
                        
    task_a a_unit (.clock(clk), .btnC(btnC), .btnD(btnD), .x(x), .y(y), .oled_data(oled_data));
    
    
                        
endmodule