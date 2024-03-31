`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2024 01:04:04 AM
// Design Name: 
// Module Name: bullet_collision
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


module bullet_collision (input clk, dir, [31:0] opp_data, [31:0] bullet_data, output reg hit, reg collided);

    wire [7:0] opp_x_min, opp_x_max, opp_y_min, opp_y_max;
    assign opp_x_min = opp_data[31:24];
    assign opp_x_max = opp_data[23:16];
    assign opp_y_min = opp_data[15:8];
    assign opp_y_max = opp_data[7:0];
    
    wire [7:0] b_x_min, b_x_max, b_y_min, b_y_max;
    assign b_x_min = bullet_data[31:24];
    assign b_x_max = bullet_data[23:16];
    assign b_y_min = bullet_data[15:8];
    assign b_y_max = bullet_data[7:0];

    always @ (posedge clk)
    begin
        if (dir == 1) begin
            hit <= ((opp_y_max - b_y_min <= 1) && (opp_x_min - b_x_min <= 4 || b_x_min - opp_x_min <= 4));
            collided <= (hit || (b_y_min == 0));
        end
    end

endmodule
