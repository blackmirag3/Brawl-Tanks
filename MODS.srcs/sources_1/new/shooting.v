`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 03:43:00 AM
// Design Name: 
// Module Name: shooting
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

// transmit data for user bullet hitting enemy. maybe use two tx/rx lines. 
// - one transmitting bullet enable and direction its fired
// - one transmit bullet collision and whether there was a hit with tank
module shooting (input clk, FIRE_TRIGGER, GAME_START, NEW_GAME, [2:0] dir, [2:0] opp_dir,
                 input RX_DONE_B, [18:0] received_b,
                 input [15:0] user_pos, [15:0] opp_pos,
                 output reg [2:0] FIRED = 0, output reg TX_START_B = 0,
                 output reg [18:0] transmit_b,
                 output opp_hit,
                 output [39:0] b_x_cen, b_y_cen);

    wire user_x_cen, user_y_cen, clk_1khz, clk_25Mhz, clk_100hz;
    
    reg [31:0] shot_delay = 0, reload_delay = 0;
    reg can_fire = 1, WAIT = 0;
    reg begin_reload = 0, reload = 0;
    reg [4:0] user_bullet_en = 0, opp_bullet_en = 0;
    
    wire [4:0] collision, hits;
    assign opp_hit = hits != 0;
    
    wire [4:0] opp_en, opp_coll;
    assign opp_en = received_b[4:0];
    assign opp_coll = received_b[9:5];
    
    assign user_x_cen = user_pos[7:0];
    assign user_y_cen = user_pos[15:8];
    
    slow_clock c0 (.CLOCK(clk), .m(49999), .SLOW_CLOCK(clk_1khz));
    
    user_bullet b0 (.bullet_speed(clk_100hz), .FIRE(user_bullet_en[0]), .RST(reload), .dir(dir), 
                    .user_pos(user_pos), .opp_pos(opp_pos),
                    .b_x_cen(b_x_cen[7:0]), .b_y_cen(b_y_cen[7:0]),
                    .collided(collision[0]), .HIT(hits[0]));
                    
    user_bullet b1 (.bullet_speed(clk_100hz), .FIRE(user_bullet_en[1]), .RST(reload), .dir(dir), 
                    .user_pos(user_pos), .opp_pos(opp_pos),
                    .b_x_cen(b_x_cen[15:8]), .b_y_cen(b_y_cen[15:8]),
                    .collided(collision[1]), .HIT(hits[1]));

    user_bullet b2 (.bullet_speed(clk_100hz), .FIRE(user_bullet_en[2]), .RST(reload), .dir(dir), 
                    .user_pos(user_pos), .opp_pos(opp_pos),
                    .b_x_cen(b_x_cen[23:16]), .b_y_cen(b_y_cen[23:16]),
                    .collided(collision[2]), .HIT(hits[2]));

    user_bullet b3 (.bullet_speed(clk_100hz), .FIRE(user_bullet_en[3]), .RST(reload), .dir(dir), 
                    .user_pos(user_pos), .opp_pos(opp_pos),
                    .b_x_cen(b_x_cen[31:24]), .b_y_cen(b_y_cen[31:24]),
                    .collided(collision[3]), .HIT(hits[3]));

    user_bullet b4 (.bullet_speed(clk_100hz), .FIRE(user_bullet_en[4]), .RST(reload), .dir(dir), 
                    .user_pos(user_pos), .opp_pos(opp_pos),
                    .b_x_cen(b_x_cen[39:32]), .b_y_cen(b_y_cen[39:32]),
                    .collided(collision[4]), .HIT(hits[4]));
    
    always @ (posedge clk_1khz)
    begin
        TX_START_B <= 0;
        reload <= 0;
        
        if (GAME_START) begin
        
            if (FIRE_TRIGGER && can_fire && FIRED < 5) begin
                FIRED <= FIRED + 1;
                can_fire <= 0;
                TX_START_B <= 1;
                
                case (FIRED)
                    3'b000 : begin
                        user_bullet_en[0] <= 1;
                        transmit_b[4:0] <= 5'b00001;
                    end
                    3'b001 : begin
                        user_bullet_en[1] <= 1;
                        transmit_b[4:0] <= 5'b00011;
                    end
                    3'b010 : begin
                        user_bullet_en[2] <= 1;
                        transmit_b[4:0] <= 5'b00111;
                    end
                    3'b011 : begin
                        user_bullet_en[3] <= 1;
                        transmit_b[4:0] <= 5'b01111;
                    end
                    3'b100 : begin
                        user_bullet_en[4] <= 1;
                        begin_reload <= 1;
                        transmit_b[4:0] <= 5'b11111;
                    end
                endcase
            end
            
            if (can_fire == 0) begin
                shot_delay <= shot_delay == 500 ? shot_delay : shot_delay + 1;
                
                if (FIRE_TRIGGER == 0 && shot_delay == 500) begin
                    can_fire <= 1;
                    shot_delay <= 0;
                end
            end
            
            if (begin_reload) begin
                reload_delay <= reload_delay == 2000 ? reload_delay : reload_delay + 1;
                
                if (reload_delay == 2000) begin
                    reload <= 1;
                    begin_reload <= 0;
                    user_bullet_en <= 0;
                    FIRED <= 0;
                    
                    TX_START_B <= 1;
                    transmit_b <= 0;
                end
            end
            
            if (collision != 0) begin
                TX_START_B <= 1;
                transmit_b[9:5] <= collision;
            end
            
        end
    end
    
    always @ (posedge clk_25Mhz)
    begin
        
        if (RX_DONE_B == 0) WAIT <= 1;
        
        if (RX_DONE_B == 1 && WAIT == 1) begin
            WAIT <= 0;
        end
        
    end

endmodule
