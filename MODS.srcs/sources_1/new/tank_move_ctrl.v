`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2024 09:26:30 PM
// Design Name: 
// Module Name: tank_move_ctrl
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


module tank_move_ctrl (input btnR, btnL, btnU, btnD, right_mouse, clk, START, NEW_GAME,
                       input can_right, can_left,
                       output reg [2:0] movement = 0, output reg [2:0] dir_state = 0);
    
    wire isUsedL, isUsedR, clk_1khz;
    reg isUsed_L, isUsed_R;
    debouncer d1 (.btn(btnR), .clk(clk), .signal(isUsedR));
    debouncer d2 (.btn(btnL), .clk(clk), .signal(isUsedL));
    
    slow_clock c0 (.CLOCK(clk), .m(49999), .SLOW_CLOCK(clk_1khz));
    
    always @ (posedge clk_1khz) begin
    
        if (START) begin
            if (btnR == 1 && right_mouse == 1 && can_right == 1 && isUsed_R == 0) begin
                dir_state <= (dir_state == 7) ? 0 : dir_state + 1;
            end
            if (btnL == 1 && right_mouse == 1 && can_left == 1 && isUsed_L == 0) begin
                dir_state <= (dir_state == 0) ? 7 : dir_state - 1;
            end
        
            if (btnU == 1) begin
                movement <= 1;
            end
            else if (btnD == 1) begin
                movement <= 2;
            end
            else if (btnR == 1 && right_mouse == 0) begin
                movement <= 4;
            end
            else if (btnL == 1 && right_mouse == 0) begin
                movement <= 3;
            end
            else begin
                movement <= 0;
            end
        end
        
        if (NEW_GAME) begin
            movement <= 0;
            dir_state <= 0;
        end
        
        
        isUsed_R <= isUsedR;        
        isUsed_L <= isUsedL; 
    end
    
endmodule
