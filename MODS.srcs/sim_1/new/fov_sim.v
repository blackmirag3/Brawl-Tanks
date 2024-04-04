`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2024 23:16:37
// Design Name: 
// Module Name: fov_sim
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

module fov_sim(
    );
    reg CLOCK = 0;
    
    wire [15:0] x_out, y_out;
    wire [2:0] angle_out;
    reg [7:0] x_in = 100, y_in = 100, x2_in = 0, y2_in = 0;
    reg [7:0] angle = 0;
    
    FOV test(
    .clk(CLOCK),
    .player_angle(angle), //3 bit unsigned
    .object_angle(4),
    .player_x(x_in), //8 bit unsigned
    .player_y(y_in),
    .object_x(x2_in),
    .object_y(x2_in),
    .object_x_relative(x_out), //16 bit unsigned
    .object_y_relative(y_out),
    .object_angle_relative(angle_out)
    );

    always begin
        #1 CLOCK = ~CLOCK;
    end
    always @ (posedge CLOCK) begin
        angle <= angle + 1;
    end
endmodule
