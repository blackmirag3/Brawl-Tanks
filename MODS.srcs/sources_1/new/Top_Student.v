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


module Top_Student (input clk, btnC, btnU, btnL, btnR, btnD, [1:0] RX,
                    inout PS2Clk, PS2Data,
                    output [7:0] JC, reg [15:0] led, 
                    output reg [6:0] seg = 7'b1111111, output reg [3:0] an, output reg dp = 1,
                    output [1:0] TX);
    
    reg [31:0] test = 0;
    
    wire clk_6p25Mhz, clk_12p5Mhz, clk_25Mhz, slow_clk;
    wire fb, send_pixel, sample_pixel;
    reg [15:0] oled_data;
    wire [12:0] pixel_index, x, y;
    
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire left, middle, right, m_event;
    wire m_left, m_right;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    wire RX_DONE_TANK, TX_START_TANK, TX_BIT;
    wire [15:0] camera, user_data, opp_data;
    wire [15:0] ready_screen;
    
    wire [15:0] user_hit, opp_hit;
    wire RX_DONE_HP, TX_START_HP, GAME_END, USER_WIN;
    wire GAME_START, USER_READY, OPP_READY, NEW_GAME;
    
    wire hit;
    wire [6:0] led_hp;
//    wire [31:0] opp_pos_data;
    
    game_state gs (.clk(clk), .x(x), .y(y), .oled_screen(ready_screen),
                   .USER_READY(USER_READY), .OPP_READY(OPP_READY), .GAME_START(GAME_START),
                   .GAME_END(GAME_END), .USER_WIN(USER_WIN), .NEW_GAME(NEW_GAME));
    
    debouncer d0 (.clk(clk), .btn(left), .signal(m_left));
    debouncer d1 (.clk(clk), .btn(right), .signal(m_right));
    
//    assign led[1] = OPP_READY;
//    assign led[2] = USER_READY;
//    assign TX = TRANSMITTING ? TX_BIT : 1;
    
    transmitter t_tank (.clk(clk), .START(TX_START_TANK), .transmit_data(user_data), .TRANSMIT_BIT(TX[0]));
    receiver r_tank (.clk(clk), .RECEIVE_BIT(RX[0]), .RX_DONE(RX_DONE_TANK), .received(opp_data));
    temp_tank tank (.clk(clk), .RX_DONE(RX_DONE_TANK), .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR), .btnC(btnC),
                    .GAME_START(GAME_START), .USER_READY(USER_READY), .OPP_READY(OPP_READY), .NEW_GAME(NEW_GAME), .GAME_END(GAME_END),
                    .received_data(opp_data), .x(x), .y(y), .oled_cam(camera), .to_transmit(user_data), .TX_START(TX_START_TANK),
                    .FIRE_TRIGGER(m_left), .hit_opp(hit));
    
    transmitter t_hp (.clk(clk), .START(TX_START_HP), .transmit_data(opp_hit), .TRANSMIT_BIT(TX[1]));
    receiver r_hp (.clk(clk), .RECEIVE_BIT(RX[1]), .RX_DONE(RX_DONE_HP), .received(user_hit));
    health_logic hp (.clk(clk), .hit(hit), .GAME_START(GAME_START), .RX_DONE(RX_DONE_HP), .user_hit(user_hit),
                     .GAME_END(GAME_END), .USER_WIN(USER_WIN), .TX_START(TX_START_HP), .opp_hit(opp_hit),
                     .NEW_GAME(NEW_GAME), .hp_bar(led_hp));
    
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
        oled_data <= GAME_START == 1 && GAME_END == 0 ? camera : ready_screen;
        led[6:0] <= led_hp;
        
        if (RX_DONE_TANK == 0) begin
            led[9] <= 1;
        end
        if (led[9] == 1) begin
            test <= test == 99999 ? 0 : test + 1;
            led[9] <= test == 99999 ? 0 : 1;
        end
        
        led[10] <= OPP_READY;
        led[11] <= USER_READY;
        
        led[13] <= ~GAME_END;
        led[15] <= m_left;
    end
                        
endmodule