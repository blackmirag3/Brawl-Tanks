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
module shooting (input clk, FIRE_TRIGGER, GAME_START, NEW_GAME, GAME_END, [2:0] dir, [2:0] opp_dir,
                 input RX_DONE_B, [18:0] received_b,
                 input [15:0] user_pos, [15:0] opp_pos,
                 output reg [2:0] FIRED = 0, output reg TX_START_B = 0,
                 output reg [18:0] transmit_b,
                 output opp_hit,
                 output [39:0] b_x_cen, b_y_cen, ob_x_cen, ob_y_cen);

    wire clk_1khz, clk_25Mhz, clk_100hz;
    // 100hz clock is actually 115hz
    wire [7:0] user_x_cen, user_y_cen;
    
    reg [31:0] shot_delay = 0, reload_delay = 0;
    reg can_fire = 1, WAIT = 0;
    reg begin_reload = 0, reload = 0, opp_reset = 0;
    reg [4:0] user_bullet_en = 0, opp_bullet_en = 0, opp_bullet_break = 0;
    
    wire [4:0] collision, hits;
    assign opp_hit = hits != 0;
    
    wire [4:0] opp_en, opp_coll;
    assign opp_en = received_b[4:0];
    assign opp_coll = received_b[9:5];
    
    assign user_x_cen = user_pos[7:0];
    assign user_y_cen = user_pos[15:8];
    
    slow_clock c0 (.CLOCK(clk), .m(32'd49999), .SLOW_CLOCK(clk_1khz));
    slow_clock c1 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c2 (.CLOCK(clk), .m(32'd434782), .SLOW_CLOCK(clk_100hz));
    
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
                    
    opp_bullet ob0 (.bullet_speed(clk_100hz), .FIRE(opp_bullet_en[0]), .BREAK(opp_bullet_break[0]), .RST(opp_reset),
                    .dir(opp_dir), .opp_pos(opp_pos), .b_x_cen(ob_x_cen[7:0]), .b_y_cen(ob_y_cen[7:0]));
                    
    opp_bullet ob1 (.bullet_speed(clk_100hz), .FIRE(opp_bullet_en[1]), .BREAK(opp_bullet_break[1]), .RST(opp_reset),
                    .dir(opp_dir), .opp_pos(opp_pos), .b_x_cen(ob_x_cen[15:8]), .b_y_cen(ob_y_cen[15:8]));
                    
    opp_bullet ob2 (.bullet_speed(clk_100hz), .FIRE(opp_bullet_en[2]), .BREAK(opp_bullet_break[2]), .RST(opp_reset),
                    .dir(opp_dir), .opp_pos(opp_pos), .b_x_cen(ob_x_cen[23:16]), .b_y_cen(ob_y_cen[23:16]));
                    
    opp_bullet ob3 (.bullet_speed(clk_100hz), .FIRE(opp_bullet_en[3]), .BREAK(opp_bullet_break[3]), .RST(opp_reset),
                    .dir(opp_dir), .opp_pos(opp_pos), .b_x_cen(ob_x_cen[31:24]), .b_y_cen(ob_y_cen[31:24]));
                    
    opp_bullet ob4 (.bullet_speed(clk_100hz), .FIRE(opp_bullet_en[4]), .BREAK(opp_bullet_break[4]), .RST(opp_reset),
                    .dir(opp_dir), .opp_pos(opp_pos), .b_x_cen(ob_x_cen[39:32]), .b_y_cen(ob_y_cen[39:32]));
    
    always @ (posedge clk_1khz)
    begin
        TX_START_B <= 0;
        reload <= 0;
        
        if (GAME_START && GAME_END == 0) begin
        
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
                shot_delay <= shot_delay == 225 ? shot_delay : shot_delay + 1;
                
                if (FIRE_TRIGGER == 0 && shot_delay == 225) begin
                    can_fire <= 1;
                    shot_delay <= 0;
                end
            end
            
            if (begin_reload) begin
                reload_delay <= reload_delay == 1800 ? reload_delay : reload_delay + 1;
                
                if (reload_delay == 1800) begin
                    reload <= 1;
                    begin_reload <= 0;
                    reload_delay <= 0;
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
        
        else if (NEW_GAME) begin
            user_bullet_en <= 0;
            reload <= 1;
            FIRED <= 0;
            reload_delay <= 0;
            shot_delay <= 0;
            
            TX_START_B <= 1;
            transmit_b <= 0;
        end
    end
    
    always @ (posedge clk_25Mhz)
    begin
        
        if (RX_DONE_B == 0) WAIT <= 1;
        
        if (RX_DONE_B == 1 && WAIT == 1) begin
            WAIT <= 0;
            opp_reset <= 0;
            
            case (opp_en)
                5'b00000 : begin
                    opp_reset <= 1;
                    opp_bullet_en <= 0;
                end
                5'b00001 : opp_bullet_en[0] <= 1;
                5'b00011 : opp_bullet_en[1] <= 1;
                5'b00111 : opp_bullet_en[2] <= 1;
                5'b01111 : opp_bullet_en[3] <= 1;
                5'b11111 : opp_bullet_en[4] <= 1;
            endcase
            
            if (opp_coll != 0) begin
                if (opp_coll[0]) opp_bullet_break[0] <= 1;
                if (opp_coll[1]) opp_bullet_break[1] <= 1;
                if (opp_coll[2]) opp_bullet_break[2] <= 1;
                if (opp_coll[3]) opp_bullet_break[3] <= 1;
                if (opp_coll[4]) opp_bullet_break[4] <= 1;
            end
            else begin
                opp_bullet_break <= 0;
            end
        end
        
    end

endmodule
