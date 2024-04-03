`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2024 12:37:21 AM
// Design Name: 
// Module Name: transmitter
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


module transmitter (input clk, START, [15:0] transmit_data, output reg TRANSMIT_BIT = 1);

    wire clk_500khz;
    reg [31:0] TIMER = 0;
    reg [15:0] buffer;
    reg BEGIN = 0;
    
    slow_clock c0 (.CLOCK(clk), .m(32'd99), .SLOW_CLOCK(clk_500khz));
    
    always @ (posedge clk_500khz)
    begin
        TIMER <= TIMER == 27 ? 0 : TIMER + 1;
        
        if (START == 0 && TIMER == 0) BEGIN <= 0;
        if (START == 1 && TIMER == 0) begin
            BEGIN <= 1;
        end
        
        if (BEGIN) begin
            if (TIMER <= 5 || TIMER >= 23) TRANSMIT_BIT <= 1;
            else if (TIMER == 6) begin // begin data transmit, initialization
                TRANSMIT_BIT <= 0;
                buffer <= transmit_data;
            end
            else if (TIMER >= 7 && TIMER <= 22) begin // transmitting data
                TRANSMIT_BIT <= buffer[0];
                buffer[15:0] <= {1'b0, buffer[15:1]};
            end
        end
        
    end

endmodule
