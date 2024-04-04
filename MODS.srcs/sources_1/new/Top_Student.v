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


module Top_Student (input clk, btnC, btnU, btnL, btnR, btnD, [2:0] RX,
                    inout PS2Clk, PS2Data,
                    output [7:0] JC, reg [15:0] led, 
                    output reg [6:0] seg = 7'b1111111, output reg [3:0] an, output reg dp = 1,
                    output [2:0] TX);
    
    reg [31:0] test = 0;
    
    wire clk_6p25Mhz, clk_12p5Mhz, clk_25Mhz, slow_clk;
    wire fb, send_pixel, sample_pixel;
    reg [15:0] oled_data;
    wire [12:0] pixel_index, x, y;
    
    wire left, middle, right, m_event;
    wire m_left;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    wire RX_DONE_TANK, TX_START_TANK, TX_BIT;
    wire [15:0] camera;
    
    wire [18:0] user_data, opp_data;
    wire [2:0] user_move_state, user_dir_state, opp_dir_state;
    wire [7:0] user_x_pos, user_y_pos; 
    wire opp_x_pos, opp_y_pos;
    wire [15:0] ready_screen;
    
    wire [18:0] user_hit, opp_hit;
    wire RX_DONE_HP, TX_START_HP, GAME_END, USER_WIN;
    wire GAME_START, USER_READY, OPP_READY, NEW_GAME;
    
    wire [18:0] user_bullet_data, opp_bullet_data;
    wire RX_DONE_B, TX_START_B;
    
    wire can_up, can_down, can_left, can_right;

    check_movement m0 (.user_x_cen(user_x_pos), .user_y_cen(user_y_pos), .opp_x_cen(opp_x_pos), .opp_y_cen(opp_y_pos),
                       .can_up(can_up), .can_down(can_down), .can_left(can_left), .can_right(can_right));

    wire hit;
    wire [6:0] led_hp;
    
    wire [2:0] bullets_fired;
    wire [39:0] user_b_x, user_b_y, opp_b_x, opp_b_y;
    
//    game_state gs (.clk(clk), .x(x), .y(y), .oled_screen(ready_screen),
//                   .USER_READY(USER_READY), .OPP_READY(OPP_READY), .GAME_START(GAME_START),
//                   .GAME_END(GAME_END), .USER_WIN(USER_WIN), .NEW_GAME(NEW_GAME));
    
    debouncer d0 (.clk(clk), .btn(left), .signal(m_left));
    
    transmitter t_bullet (.clk(clk), .START(TX_START_B), .transmit_data(user_bullet_data), .TRANSMIT_BIT(TX[2]));
    receiver r_bullet (.clk(clk), .RECEIVE_BIT(RX[2]), .RX_DONE(RX_DONE_B), .received(opp_bullet_data));
    
    shooting s_unit (.clk(clk), .FIRE_TRIGGER(m_left), .GAME_START(1), .NEW_GAME(NEW_GAME), .GAME_END(0),
                     .dir(user_dir_state), .opp_dir(opp_dir_state), .TX_START_B(TX_START_B),
                     .RX_DONE_B(RX_DONE_B), .received_b(opp_bullet_data),
                     .user_pos({user_y_pos, user_x_pos}), .opp_pos({opp_y_pos, opp_x_pos}),
                     .FIRED(bullets_fired), .transmit_b(user_bullet_data), .opp_hit(hit),
                     .b_x_cen(user_b_x), .b_y_cen(user_b_y), .ob_x_cen(opp_b_x), .ob_y_cen(opp_b_y));
    
//    assign led[1] = OPP_READY;
//    assign led[2] = USER_READY;
//    assign TX = TRANSMITTING ? TX_BIT : 1;
    
    tank_move_ctrl ctrl_unit (.clk(clk), .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR), .right_mouse(right),
                              .START(1), .NEW_GAME(NEW_GAME), .can_left(can_left), .can_right(can_right),
                              .movement(user_move_state), .dir_state(user_dir_state));
    
    transmitter t_tank (.clk(clk), .START(TX_START_TANK), .transmit_data(user_data), .TRANSMIT_BIT(TX[0]));
    receiver r_tank (.clk(clk), .RECEIVE_BIT(RX[0]), .RX_DONE(RX_DONE_TANK), .received(opp_data));

    tank_move t0 (.clk(clk), .RX_DONE(RX_DONE_TANK), .can_up(can_up), .can_down(can_down), .can_left(can_left), .can_right(can_right), .btnC(btnC),
                  .GAME_START(1), .USER_READY(USER_READY), .OPP_READY(OPP_READY), .NEW_GAME(NEW_GAME), .GAME_END(0),
                  .received_data(opp_data), .to_transmit(user_data), .TX_START(TX_START_TANK), .dir(user_dir_state), .movement(user_move_state),
                  .user_x_cen(user_x_pos), .user_y_cen(user_y_pos), .opp_x_cen(opp_x_pos), .opp_y_cen(opp_y_pos), .opp_dir(opp_dir_state));
    
    temp_cam cam (.clk(clk_25Mhz), .x(x), .y(y), .user_x_cen(user_x_pos), .user_y_cen(user_y_pos), .opp_x_cen(opp_x_pos), .opp_y_cen(opp_y_pos),
                  .user_dir(user_dir_state), .opp_dir(opp_dir_state),
                  .b_x_cen(user_b_x), .b_y_cen(user_b_y), .ob_x_cen(opp_b_x), .ob_y_cen(opp_b_y),
                  .camera(camera));


    transmitter t_hp (.clk(clk), .START(TX_START_HP), .transmit_data(opp_hit), .TRANSMIT_BIT(TX[1]));
    receiver r_hp (.clk(clk), .RECEIVE_BIT(RX[1]), .RX_DONE(RX_DONE_HP), .received(user_hit));
    health_logic hp (.clk(clk), .hit(hit), .GAME_START(1), .RX_DONE(RX_DONE_HP), .user_hit(user_hit[15:0]),
                     .GAME_END(0), .USER_WIN(USER_WIN), .TX_START(TX_START_HP), .opp_hit(opp_hit[15:0]),
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
                        .xpos(0),
                        .ypos(0),
                        .zpos(0),
                        .left(left),
                        .middle(middle),
                        .right(right),
                        .new_event(m_event),
                        .ps2_clk(PS2Clk),
                        .ps2_data(PS2Data));
                                      
    always @ (posedge clk)
    begin
        an <= 4'b1111;
        oled_data <= camera;
        led[6:0] <= led_hp;
        
        
        led[10] <= OPP_READY;
        led[11] <= USER_READY;
        
        led[13] <= ~GAME_END;
        led[15] <= m_left;
        
//        if (GAME_START && GAME_END == 0) begin
            an[3:0] <= 4'b1110;
            case (bullets_fired)
                0 : seg[6:0] <= 7'b0010010;
                1 : seg[6:0] <= 7'b0011001;
                2 : seg[6:0] <= 7'b0110000;
                3 : seg[6:0] <= 7'b0100100;
                4 : seg[6:0] <= 7'b1111001;
                default : begin
                    seg[6:0] <= 7'b0111111;
                    an[3:0] <= 4'b0000;
                end
            endcase
//        end
    end
                        
endmodule