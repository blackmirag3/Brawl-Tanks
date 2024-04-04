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
module shooting (input clk, FIRE_TRIGGER, [2:0] dir, [2:0] opp_dir,
                 input RX_DONE_B_EN, RX_DONE_HIT, [18:0] received_b_en, [18:0] received_hit,
                 input [15:0] user_pos, [15:0] opp_pos,
                 output reg [2:0] FIRED = 0, output reg TX_START_B_EN = 0, TX_START_HIT = 0,
                 output reg [18:0] transmit_b_en, transmit_hit,
                 output reg [39:0] b_x_cen, b_y_cen);

    wire user_x_cen, user_y_cen, clk_1khz, clk_25Mhz, clk_100hz;
    
    reg [31:0] shot_delay = 0, reload_delay = 0;
    reg can_fire = 1;
    reg begin_reload = 0;
    reg [4:0] user_bullet_en = 0;
    
    assign user_x_cen = user_pos[7:0];
    assign user_y_cen = user_pos[15:8];
    
    slow_clock c0 (.CLOCK(clk), .m(49999), .SLOW_CLOCK(clk_1khz));
    
    always @ (posedge clk_1khz)
    begin
        if (FIRE_TRIGGER && can_fire && FIRED < 5) begin
            FIRED <= FIRED + 1;
            can_fire <= 0;
            
            case (FIRED)
                3'b000 : begin
                    user_bullet_en[0] <= 1;
                end
                3'b001 : begin
                    user_bullet_en[1] <= 1;
                end
                3'b010 : begin
                    user_bullet_en[2] <= 1;
                end
                3'b011 : begin
                    user_bullet_en[3] <= 1;
                end
                3'b100 : begin
                    user_bullet_en[4] <= 1;
                    begin_reload <= 1;
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
                user_bullet_en <= 0;
                FIRED <= 0;
            end
        end
    end

endmodule
