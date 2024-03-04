`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2024 10:08:11
// Design Name: 
// Module Name: slow_clock_sim
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


module slow_clock_sim(

    );
    reg CLOCK = 0;
    wire clock_6dot25, clock_25;
    reg [31:0] divider_6dot25 = 7, divider_25 = 1;
    slow_clock clk_6dot25(CLOCK, divider_6dot25, clock_6dot25);
    slow_clock clk(CLOCK, divider_25, clock_25);
    always begin
        #5 CLOCK = ~CLOCK;
    end
endmodule
