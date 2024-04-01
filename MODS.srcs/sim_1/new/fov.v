`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2024 16:17:43
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
    input signed [15:0] player_x,
    input signed [15:0] player_y,
    input [7:0] player_angle, // Scaled 0-255 for 0-360 degrees
    input signed [15:0] object_x,
    input signed [15:0] object_y,
    output reg signed [15:0] rel_x,
    output reg signed [15:0] rel_y
);

// Sin and Cos LUTs (8-bit signed, scaled -128 to 127 for sin, 0 to 255 for angle)
reg signed [7:0] sin_lut[255:0];
reg signed [7:0] cos_lut[255:0];
reg signed [15:0] trans_x;
reg signed [15:0] trans_y;
reg signed [15:0] sin_theta;
reg signed [15:0] cos_theta;

// Initialize LUTs with precomputed sin and cos values
initial begin
    sin_lut[0] = 0;
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[
    sin_lut[64] = 127;
    sin_lut[128] = 0;
    sin_lut[192] = -128; // etc.
    
    cos_lut[0] = 127;
    cos_lut[64] = 0;
    cos_lut[128] = -128;
    cos_lut[192] = 0; // etc.
    // Populate the rest of your LUTs...
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
