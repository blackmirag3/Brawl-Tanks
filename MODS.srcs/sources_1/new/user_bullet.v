`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 04:18:36 AM
// Design Name: 
// Module Name: user_bullet
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


module user_bullet (input bullet_speed, FIRE, RST, [2:0] dir, [15:0] user_pos, [15:0] opp_pos,
                    output reg [7:0] b_x_cen = 200, b_y_cen = 200,
                    output reg collided, HIT);

    reg [7:0] rst_x = 200, rst_y = 200;

endmodule
