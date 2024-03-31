`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2024 08:10:38 PM
// Design Name: 
// Module Name: health_logic
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


module health_logic (input clk, hit, GAME_START, RX_DONE, RESET, NEW_GAME, [15:0] user_hit,
                     output GAME_END, USER_WIN, reg TX_START = 0, [6:0] hp_bar,
                     output reg [15:0] opp_hit);

    wire clk_25Mhz, clk_1khz;
    
    reg can_damage = 1;
    reg WAIT = 0, delay = 0, reset_delay = 0;
    reg [15:0] prev_user_hit = 0;
    reg [3:0] user_hp = 7, opp_hp = 7;
    
    slow_clock c1 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c2 (.CLOCK(clk), .m(32'd49999), .SLOW_CLOCK(clk_1khz));
    
    assign GAME_END = user_hp == 0 || opp_hp == 0;
    assign USER_WIN = user_hp > 0 && opp_hp == 0;
    
    assign hp_bar[6] = user_hp == 7;
    assign hp_bar[5] = user_hp >= 6;
    assign hp_bar[4] = user_hp >= 5;
    assign hp_bar[3] = user_hp >= 4;
    assign hp_bar[2] = user_hp >= 3;
    assign hp_bar[1] = user_hp >= 2;
    assign hp_bar[0] = user_hp >= 1;
    
    always @ (posedge clk_1khz)
    begin
        TX_START <= 0;
        if (GAME_START) begin
            TX_START <= 1;
            opp_hit <= 0;
            if (hit == 1 && can_damage == 1) begin
                can_damage <= 0;
                opp_hit <= 16'haaaa;
                opp_hp <= opp_hp == 0 ? 0 : opp_hp - 1;
            end
            
            if (hit == 0) can_damage <= 1;
        end
        
        if (NEW_GAME) begin
            opp_hp <= 7;
        end
        
        if (delay) reset_delay <= 1;
    end
    
    always @ (posedge clk_25Mhz)
    begin
        
        if (RX_DONE == 0) begin
            WAIT <= 1;
        end
        if (RX_DONE == 1 && WAIT == 1) begin
            WAIT <= 0;
//            user_hp <= (user_hit == 16'haaaa && user_hit != prev_user_hit && user_hp > 0) ? user_hp - 1 : user_hp;
            prev_user_hit <= user_hit;
        end
        
        if (NEW_GAME) begin
            user_hp <= 7;
        end
    end
    
endmodule
