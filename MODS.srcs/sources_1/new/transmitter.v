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


module transmitter (input clk, START, [18:0] transmit_data, output reg TRANSMIT_BIT = 1);

    wire clk_500khz;
    reg [31:0] TIMER = 0;
    reg [18:0] buffer;
    reg BEGIN = 0;
    
    slow_clock c0 (.CLOCK(clk), .m(32'd99), .SLOW_CLOCK(clk_500khz));
    
    always @ (posedge clk_500khz)
    begin
        TIMER <= TIMER == 28 ? 0 : TIMER + 1;
        
        if (START == 0 && TIMER == 0) BEGIN <= 0;
        if (START == 1 && TIMER == 0) begin
            BEGIN <= 1;
        end
        
        if (BEGIN) begin
            if (TIMER <= 4 || TIMER >= 25) TRANSMIT_BIT <= 1;
            else if (TIMER == 5) begin // begin data transmit, initialization
                TRANSMIT_BIT <= 0;
                buffer <= transmit_data;
            end
            else if (TIMER >= 6 && TIMER <= 24) begin // transmitting data
                TRANSMIT_BIT <= buffer[0];
                buffer[18:0] <= {1'b0, buffer[18:1]};
            end
        end
        
    end

endmodule
