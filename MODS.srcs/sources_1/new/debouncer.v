`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.03.2024 16:56:34
// Design Name: 
// Module Name: debouncer
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


module debouncer(
input clock, button,
output reg state
    );
    reg counter;
    always @ (posedge clock) begin
        if (button == 1) state = 1;
        
        else if (counter > 49) begin
            state = 0;
            counter <= 0;
        end
        
        if (state == 1) counter <= counter + 1;
    end
endmodule
