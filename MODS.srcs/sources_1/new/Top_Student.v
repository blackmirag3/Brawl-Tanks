`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: Siew Shui Hon
//  STUDENT B NAME: Timothy Lau Kah Ming
//  STUDENT C NAME: 
//  STUDENT D NAME: Sim Jing Jie Ryan 
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input clk, btnC, btnU, btnL, btnR, btnD, [15:0] sw, 
                    inout PS2Clk, PS2Data,
                    output [7:0] JC, [15:0] led, 
                    output reg [6:0] seg = 7'b1111111, output reg [3:0] an, output reg dp = 1);
    
    wire clk_6p25Mhz, clk_12p5Mhz, clk_25Mhz, slow_clk, clk_1Khz;
    wire fb, send_pixel, sample_pixel;
    wire [15:0] oled_data;
    wire [12:0] pixel_index, x, y;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire left, middle, right, m_event;
    
    slow_clock c0 (.CLOCK(clk), .m(32'd7), .SLOW_CLOCK(clk_6p25Mhz));
//    slow_clock c1 (.CLOCK(clk), .m(32'd3), .SLOW_CLOCK(clk_12p5Mhz));
//    slow_clock c2 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
//    slow_clock c3 (.CLOCK(clk), .m(32'd49999999), .SLOW_CLOCK(slow_clk));
    slow_clock c4 (.CLOCK(clk), .m(32'd49999), .SLOW_CLOCK(clk_1Khz));
//    wire [3:0] direction;    // clockwise from 12oClock, 1-8 positions
//    wire [2:0] movement; // 0:no movement, 1:forward, 2:backward, 3:left, 4:right
    
//    tankdirection tank_direction(.debounce(clk), .state(direction), .btnR(btnR), .btnL(btnL),
//                                 .RightMouse(right), .clk(clk_1Khz)); //led[15:5]
                                 
//    tankMovement tank_movement_status (.debounce(clk), .btnR(btnR), .btnL(btnL), 
//                                      .btnU(btnU), .btnD(btnD),
//                                      .RightMouse(right), .clk(clk_1Khz),
//                                      .movement(movement)); //led[4:0]
                                      
    wire [7:0] enemy_x_rel, enemy_y_rel, pillar_x_rel, pillar_y_rel;
    wire [2:0] enemy_angle_rel, pillar_angle_rel;
    
    //FOV enemy(clk, 0, 0, 0, 0, 0, 0, enemy_x_rel, enemy_y_rel, enemy_angle_rel);
    //FOV pillar(clk, 0, 0, 0, 0, 0, 0, pillar_x_rel, pillar_y_rel, pillar_angle_rel);
    //camera_FPS cam_1(clk, enemy_x_rel, enemy_y_rel, enemy_angle_rel, pillar_x_rel, pillar_y_rel, x, y, oled_data);
//    camera_top cam_2(.clk(clk_1Khz), .user_dir(direction), .opp_dir(0), .user_x_cen(50),
//                     .user_y_cen(30), .enemy_x(60), .enemy_y(100),
//                     .x(x), .y(y), .camera(oled_data));
//    temp_cam camera_test(.clk(clk_1Khz),.x(x), .y(y), .user_x_cen(50),
//                         .user_y_cen(30), .opp_x_cen(60), .opp_y_cen(100),  .user_dir(direction), .opp_dir(0), 
//                          .camera(oled_data));
    
    
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
                        
    MouseCtl mouse_unit (.clk(clk),
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
                        .middle(middle),
                        .right(right),
                        .new_event(m_event),
                        .ps2_clk(PS2Clk),
                        .ps2_data(PS2Data));     
                        
    always @ (posedge clk_1Khz) begin
    
    end
endmodule