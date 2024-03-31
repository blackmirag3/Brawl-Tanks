`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2024 01:56:35 AM
// Design Name: 
// Module Name: temp_tank
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module temp_tank (input clk, RX_DONE, btnU, btnD, btnL, btnR, btnC, GAME_START, GAME_END, FIRE_TRIGGER,
                input [15:0] received_data, [12:0] x, [12:0] y,
                output reg [15:0] oled_cam, reg [15:0] to_transmit, output reg TX_START = 0, 
                output reg USER_READY = 0, OPP_READY = 0, NEW_GAME = 1,
                output hit_opp);
//                output [31:0] opp_data);

    wire clk_25Mhz, clk_30hz, clk_50hz;
    
    reg WAIT = 0;
//    reg reset_state = 0;
    reg [31:0] SPEED_COUNT = 0;
//    reg signed [2:0] dx = 0, dy = 0;
    
    reg [12:0] user_x_min = 45, user_x_max = 50, user_y_min = 58, user_y_max = 63;
    reg [12:0] init_x_min = 45, init_x_max = 50, init_y_min = 58, init_y_max = 63;
    reg [12:0] opp_x_min = 45, opp_x_max = 50, opp_y_min = 0, opp_y_max = 5;
    
    reg [12:0] x_min = 0, x_max = 95, y_min = 0, y_max = 63;
    wire can_left, can_right, can_down, can_up;

    reg [15:0] user_col = 16'b11111_000000_11111;
    reg [15:0] opp_col = 16'b00000_111111_00000;

    reg [12:0] b1_x_min = 200, b1_x_max = 200, b1_y_min = 200, b1_y_max = 200;
    reg fired = 0, can_fire = 1, dir = 0;
    wire bullet_collide, hit;

//    wire [31:0] opp_data, b_data;    
//    assign opp_data = {opp_x_min[7:0], opp_x_max[7:0], opp_y_min[7:0], opp_y_max[7:0]};
//    assign b_data = {b1_x_min[7:0], b1_x_max[7:0], b1_y_min[7:0], b1_y_max[7:0]};

    slow_clock c0 (.CLOCK(clk), .m(32'd1666666), .SLOW_CLOCK(clk_30hz));
    slow_clock c1 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c2 (.CLOCK(clk), .m(32'd999999), .SLOW_CLOCK(clk_50hz));
    
    check_movement u0 (.user_x_min(user_x_min), .user_x_max(user_x_max), .user_y_min(user_y_min), .user_y_max(user_y_max),
                        .opp_x_min(opp_x_min), .opp_x_max(opp_x_max), .opp_y_min(opp_y_min), .opp_y_max(opp_y_max), 
                        .can_up(can_up), .can_down(can_down), .can_left(can_left), .can_right(can_right));
    
    bullet_collision b0 (.clk(clk_50hz), .dir(dir), .opp_data({opp_x_min[7:0], opp_x_max[7:0], opp_y_min[7:0], opp_y_max[7:0]}),
                         .bullet_data({b1_x_min[7:0], b1_x_max[7:0], b1_y_min[7:0], b1_y_max[7:0]}),
                         .hit(hit), .collided(bullet_collide));
    
    assign hit_opp = hit;
    
    always @ (posedge clk_50hz)
    begin
        if (FIRE_TRIGGER && fired == 0 && can_fire) begin
            can_fire <= 0;
            fired <= 1;
            dir <= 1;
            b1_x_min <= user_x_min + 1;
            b1_x_max <= user_x_max - 1;
            b1_y_min <= user_y_min - 4;
            b1_y_max <= user_y_min - 1;
        end
        
        if (fired) begin
            b1_y_max <= b1_y_max - 1;
            b1_y_min <= b1_y_min - 1;
            if (bullet_collide) begin
                fired <= 0;
                dir <= 0;
                b1_x_min <= 200;
                b1_x_max <= 200;
                b1_y_min <= 200;
                b1_y_max <= 200;
            end
        end
        
        if (FIRE_TRIGGER == 0) can_fire <= 1;
    end
    
    always @ (posedge clk_30hz)
    begin
        TX_START <= 0;
        if (GAME_START == 1 && GAME_END == 0) begin
            
            NEW_GAME <= 0;
            
            user_x_min = user_x_min + (btnR * can_right) - (btnL * can_left);
            user_x_max = user_x_max + (btnR * can_right) - (btnL * can_left);
            user_y_min = user_y_min + (btnD * can_down) - (btnU * can_up);
            user_y_max = user_y_max + (btnD * can_down) - (btnU * can_up);
    
            // collision with opp tank
            
            // 16 - bit transfer data. data[15:8] = user y max pos, data[7:0] = user x max pos 
            // with respect to the user's coordinates
            to_transmit <= {user_y_max[7:0], user_x_max[7:0]};
                
            if (btnR || btnL || btnU || btnD) TX_START <= 1;
        end
        else if (GAME_END == 1 && USER_READY == 1) begin
        
//            reset_state <= 1;
            USER_READY <= 0;
            
            user_x_min = init_x_min;
            user_x_max = init_x_max;
            user_y_min = init_y_min;
            user_y_max = init_y_max;
            
            to_transmit <= {user_y_max[7:0], user_x_max[7:0]};
            TX_START <= 1;
            
        end
        else begin
            if (btnC && USER_READY == 0) begin
            
                TX_START <= 1;
                to_transmit <= 16'b1010101010101010;
                USER_READY <= 1;
                NEW_GAME <= 1;
                
            end
        end
    end
    
    always @ (posedge clk_25Mhz)
    begin
        // 30 Hz - 30 pixels per second
//        SPEED_COUNT <= SPEED_COUNT == 833332 ? 0 : SPEED_COUNT + 1;
    
        if (RX_DONE == 0) begin
            WAIT <= 1;
        end
        if (RX_DONE == 1 && WAIT == 1) begin
            WAIT <= 0;
            if (GAME_START == 1) begin
                opp_x_min <= 95 - received_data[7:0];
                opp_y_min <= 63 - received_data[15:8];
                opp_x_max <= opp_x_min + 5;
                opp_y_max <= opp_y_min + 5;
            end
            else begin
                OPP_READY <= received_data == 16'b1010101010101010 ? 1 : 0;
            end
        end
        
        if (x >= user_x_min && x <= user_x_max && y >= user_y_min && y <= user_y_max) begin
            oled_cam <= user_col;
        end
        else if (x >= opp_x_min && x <= opp_x_max && y >= opp_y_min && y <= opp_y_max) begin
            oled_cam <= opp_col;
        end
        else if (x >= b1_x_min && x <= b1_x_max && y >= b1_y_min && y <= b1_y_max) begin
            oled_cam <= 16'b11111_000000_00000;
        end
        else begin
            oled_cam <= 0;
        end
        
        if (GAME_END == 1) begin
            OPP_READY <= 0;
        end
        
    end

endmodule
