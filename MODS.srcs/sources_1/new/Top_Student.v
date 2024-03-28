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


module Top_Student (input clk, btnC, btnU, btnL, btnR, btnD, RX,
                    inout PS2Clk, PS2Data,
                    output [7:0] JC, reg [15:0] led, 
                    output reg [6:0] seg = 7'b1111111, output reg [3:0] an, output reg dp = 1,
                    output TX);
    
    reg [31:0] test = 0;
    
    wire clk_6p25Mhz, clk_12p5Mhz, clk_25Mhz, slow_clk;
    wire fb, send_pixel, sample_pixel;
    reg [15:0] oled_data;
    wire [12:0] pixel_index, x, y;
    
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire left, middle, right, m_event;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    wire RX_DONE, TX_START, TX_BIT;
    wire [15:0] camera, user_pos_data, opp_pos_data;
    wire [15:0] ready_screen;
    
    ready_check (.clk(clk), .x(x), .y(y), .oled_screen(ready_screen));
    
//    assign led[7] = ~RX_DONE;
//    assign led[5] = TX_START;
//    assign TX = TRANSMITTING ? TX_BIT : 1;
    
    transmitter t0 (.clk(clk), .START(TX_START), .transmit_data(user_pos_data), .TRANSMIT_BIT(TX));
    receiver r0 (.clk(clk), .RECEIVE_BIT(RX), .RX_DONE(RX_DONE), .received(opp_pos_data));
    temp_tank tank (.clk(clk), .RX_DONE(RX_DONE), .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR),
                    .opp_tank(opp_pos_data), .x(x), .y(y), .oled_cam(camera), .new_user_pos(user_pos_data), .TX_START(TX_START));
    
    slow_clock c0 (.CLOCK(clk), .m(32'd7), .SLOW_CLOCK(clk_6p25Mhz));
    slow_clock c1 (.CLOCK(clk), .m(32'd3), .SLOW_CLOCK(clk_12p5Mhz));
    slow_clock c2 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
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
                                      
    always @ (posedge clk)
    begin
        oled_data <= ready_screen;
        
        if (RX_DONE == 0) begin
            led[7] <= 1;
        end
        if (led[7] == 1) begin
            test <= test == 99999 ? 0 : test + 1;
            led[7] <= test == 99999 ? 0 : 1;
        end
    end
                        
endmodule