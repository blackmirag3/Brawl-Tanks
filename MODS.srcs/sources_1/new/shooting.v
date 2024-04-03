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


module shooting (input clk, bullet_speed, left_mouse, [2:0] dir, [15:0] user_pos,
                 output reg [2:0] FIRED = 0,
                 output reg [39:0] b_x_cen, b_y_cen);

    wire user_x_cen, user_y_cen, clk_1khz;
    reg [31:0] timer = 0;
    
    assign user_x_cen = user_pos[7:0];
    assign user_y_cen = user_pos[15:8];
    
    slow_clock c0 (.CLOCK(clk), .m(49999), .SLOW_CLOCK(clk_1khz));
    
    always @ (posedge clk_1khz)
    begin
    
    end

endmodule
