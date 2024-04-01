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
    test fov(CLOCK, 255, 100, 100, 0, -100, x_out, y_out);
    always begin
            #1 CLOCK = ~CLOCK;
        end
endmodule
