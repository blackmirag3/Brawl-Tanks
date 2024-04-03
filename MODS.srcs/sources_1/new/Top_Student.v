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
    
    wire clk_6p25Mhz, clk_12p5Mhz, clk_25Mhz, slow_clk, clk_1000hz;
    wire fb, send_pixel, sample_pixel;
    wire [15:0] oled_data;
    wire [12:0] pixel_index, x, y;
    
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire left, middle, right, m_event;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
        
    slow_clock c0 (.CLOCK(clk), .m(32'd7), .SLOW_CLOCK(clk_6p25Mhz));
    slow_clock c1 (.CLOCK(clk), .m(32'd3), .SLOW_CLOCK(clk_12p5Mhz));
    slow_clock c3 (.CLOCK(clk), .m(32'd49999999), .SLOW_CLOCK(slow_clk));
    
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
    
    reg [15:0] green_c = 16'b00000_111111_00000; 
    reg [15:0] red_c = 16'b11111_000000_00000; 
    reg [15:0] blue_c = 16'b00000_000000_11111;
    reg [15:0] white_c = 16'b11111_111111_11111;
                 
                        
    wire [3:0] direction;    // clockwise from 12oClock, 1-8 positions
    wire [2:0] movement; // 0:no movement, 1:forward, 2:backward, 3:left, 4:right
    slow_clock c2 (.CLOCK(clk), .m(32'd49999), .SLOW_CLOCK(clk_1000hz));
    slow_clock c4 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    
    tankdirection tank_direction (.debounce(clk), .state(direction), .btnR(btnR), .btnL(btnL),
                                  .RightMouse(right), .clk(clk_1000hz)); //led[15:5]
    tankMovement tank_movement_status (.debounce(clk), .btnR(btnR), .btnL(btnL), 
                                       .btnU(btnU), .btnD(btnD),
                                       .RightMouse(right), .clk(clk_1000hz),
                                       .movement(movement)); //led[4:0]
    wire isUsedC;
    reg isUsed_C;
    reg [31:0] five_seconds = 32'd5000, count = 0;
    debouncer debounce_C (.btn(btnC), .clk(clk), .signal(isUsedC));  
      
    //x,y of 5 diff bullet
    wire [12:0] bullet1_x, bullet1_y, bullet2_x, bullet2_y, bullet3_x, bullet3_y, bullet4_x, bullet4_y, bullet5_x, bullet5_y; 
    
    //x,y centre of tank
    wire [12:0] centre_x, centre_y;
    wire [4:0] fired; //to let screen know that a bullet is still travelling
    reg [4:0] shoot = 5'b00000; 
    
    always@(posedge clk_1000hz)
    begin
        if(btnC == 1 && isUsed_C == 0 && count == 0)begin
            shoot <= (shoot == 5'b11111) ? 5'b11111 : (shoot << 1) + 1;
            end 
        if(shoot == 5'b11111 && count != five_seconds)begin
            count <= count + 1;
            seg[6:0] <= 7'b0000000;
            an[3:0] <= 4'b0000;
            end
        if(count == five_seconds)begin
            shoot <= 5'b00000;
            count <= 0;
            seg[6:0] <= 7'b1111111;
            an[3:0] <= 4'b1111;
            end
        isUsed_C <= isUsedC;  
    end                                   
                                       
    bullet bullet1(.clock(clk), .btnC(shoot[0]), .centre_x(centre_x), .centre_y(centre_y),
                    .direction(direction), 
                    .fired(fired[0]), 
                    .bullet_x(bullet1_x), .bullet_y(bullet1_y));
                    
    bullet bullet2(.clock(clk), .btnC(shoot[1]), .centre_x(centre_x), .centre_y(centre_y),
                    .direction(direction), 
                    .fired(fired[1]), 
                    .bullet_x(bullet2_x), .bullet_y(bullet2_y));
                    
    bullet bullet3(.clock(clk), .btnC(shoot[2]), .centre_x(centre_x), .centre_y(centre_y),
                    .direction(direction), 
                    .fired(fired[2]), 
                    .bullet_x(bullet3_x), .bullet_y(bullet3_y));    
                    
    bullet bullet4(.clock(clk), .btnC(shoot[3]), .centre_x(centre_x), .centre_y(centre_y),
                    .direction(direction), 
                    .fired(fired[3]), 
                    .bullet_x(bullet4_x), .bullet_y(bullet4_y));
                    
    bullet bullet5(.clock(clk), .btnC(shoot[4]), .centre_x(centre_x), .centre_y(centre_y),
                    .direction(direction), 
                    .fired(fired[4]), 
                    .bullet_x(bullet5_x), .bullet_y(bullet5_y));
                                       
    tankPosition position(.clock(clk),
                          .x(x), .y(y), 
                          .bullet1_x(bullet1_x), .bullet1_y(bullet1_y),
                          .bullet2_x(bullet2_x), .bullet2_y(bullet2_y),
                          .bullet3_x(bullet3_x), .bullet3_y(bullet3_y),
                          .bullet4_x(bullet4_x), .bullet4_y(bullet4_y),
                          .bullet5_x(bullet5_x), .bullet5_y(bullet5_y),
                          .fired(fired),
                          .direction(direction),
                          .movement(movement),
                          .oled_data(oled_data),
                          .centre_x(centre_x), .centre_y(centre_y));
                    
endmodule