`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2024 12:37:35 AM
// Design Name: 
// Module Name: receiver
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


module receiver (input clk, RECEIVE_BIT, output reg RX_DONE = 1, reg [15:0] received = 0);

    wire clk_500khz;
    reg [15:0] buffer = 0;
    reg [31:0] COUNTER = 0;
    
    slow_clock c0 (.CLOCK(clk), .m(32'd99), .SLOW_CLOCK(clk_500khz));

    always @ (posedge clk_500khz)
    begin
        if (RECEIVE_BIT == 0 && COUNTER == 0) begin // initialize receiver
            COUNTER <= COUNTER + 1;
            RX_DONE <= 0;
        end
        if (COUNTER > 0 && COUNTER <= 16) begin // receiving data
            COUNTER <= COUNTER + 1;
            received[15:0] <= {RECEIVE_BIT, received[15:1]};
        end
        if (COUNTER > 16 && RECEIVE_BIT == 1) begin // finish receiving
            COUNTER <= 0;
            RX_DONE <= 1;
        end
    end

endmodule
