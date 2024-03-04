`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2024 10:07:12
// Design Name: 
// Module Name: slow_clock
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


module slow_clock(input CLOCK, input [31:0] m, output reg SLOW_CLOCK = 0);

    reg [31:0] counter = 0;
    
    always @ (posedge CLOCK) begin
        counter <= (counter == m) ? 0 : counter + 1;
        SLOW_CLOCK <= (counter == 0) ? ~SLOW_CLOCK : SLOW_CLOCK;
    end
    
endmodule

