`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2024 15:21:14
// Design Name: 
// Module Name: fov
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


module fov(
input clk,
input reset,
input [7:0] player_angle, //scaled to 256 degrees from 360 degrees
input[7:0] player_x, player_y, enemy_x, enemy_y, pillar_x, pillar_y,
input signed [7:0] object_x,
input signed [7:0] object_y,
output reg [7:0] rel_x, rel_y
//output [7:0] enemy_x_rel, enemy_y_rel, pillar_x_rel, pillar_y_rel
    );
    reg signed [7:0] trans_x;
    reg signed [7:0] trans_y;
    reg signed [7:0] sin_theta;
    reg signed [7:0] cos_theta;

    // Sin and Cos LUTs (8-bit signed, scaled -128 to 127 for sin, 0 to 255 for angle)
    reg [7:0] sin_lut[255:0];
    reg [7:0] cos_lut[255:0];

    // Initialize LUTs with precomputed sin and cos values
    initial begin
        sin_lut[0] = 0;
        sin_lut[64] = 127;
        sin_lut[128] = 0;
        sin_lut[192] = -128;
        
        
        cos_lut[0] = 127;
        cos_lut[64] = 0;
        cos_lut[128] = -128;
        cos_lut[192] = 0;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rel_x <= 0;
            rel_y <= 0;
        end else begin
            // Translate object position to be relative to player position
            trans_x = object_x - player_x;
            trans_y = object_y - player_y;
    
            // Lookup sin and cos values for the player's current angle
            sin_theta = sin_lut[player_angle];
            cos_theta = cos_lut[player_angle];
    
            // Rotate translated position using the lookup values
            // Note: Using 8-bit LUT values extended to 16 bits for calculation
            // The >> 7 operation is to normalize the result of the multiplication
            rel_x <= ((trans_x * cos_theta) - (trans_y * sin_theta)) >>> 7;
            rel_y <= ((trans_x * sin_theta) + (trans_y * cos_theta)) >>> 7;
        end
    end
endmodule
