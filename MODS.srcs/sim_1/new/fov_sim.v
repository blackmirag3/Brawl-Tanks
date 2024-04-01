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
    reg [15:0] x_out, y_out;
    reg [7:0] x_in = 100, y_in = 100, x2_in = -100, y2_in = -100;
    reg [7:0] angle = 0;
    test fov(CLOCK, angle, x_in, y_in, x2_in, x2_in, -100, x_out, y_out);
    always begin
        #1 CLOCK = ~CLOCK;
    end
    always @ (posedge CLOCK) begin
        angle <= angle + 1;
    end
endmodule
