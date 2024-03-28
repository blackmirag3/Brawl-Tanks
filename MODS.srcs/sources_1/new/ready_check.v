`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2024 08:10:38 PM
// Design Name: 
// Module Name: ready_check
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


module ready_check (input clk, input [12:0] x, y, output reg [15:0] oled_screen);

    wire clk_25Mhz;
    reg READY = 0;
    slow_clock c2 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));

    wire ready, press, paint_black;
    
    assign ready = (x >= 18 && x <= 19 && y >= 15 && y <= 24) || (x >= 24 && x <= 25 && y >= 17 && y <= 18) ||
                   (x >= 20 && x <= 23 && y >= 15 && y <= 16) || (x >= 20 && x <= 23 && y >= 19 && y <= 20) ||
                   (x >= 22 && x <= 23 && y >= 21 && y <= 22) || (x >= 24 && x <= 25 && y >= 23 && y <= 24) || // letter R
                   (x >= 28 && x <= 29 && y >= 15 && y <= 24) || (x >= 30 && x <= 35 && y >= 15 && y <= 16) ||
                   (x >= 30 && x <= 33 && y >= 19 && y <= 20) || (x >= 30 && x <= 35 && y >= 23 && y <= 24) || // letter E
                   (x >= 38 && x <= 39 && y >= 17 && y <= 24) || (x >= 44 && x <= 45 && y >= 17 && y <= 24) ||
                   (x >= 40 && x <= 43 && y >= 15 && y <= 16) || (x >= 40 && x <= 43 && y >= 19 && y <= 20) || // letter A
                   (x >= 48 && x <= 49 && y >= 15 && y <= 24) || (x >= 54 && x <= 55 && y >= 17 && y <= 22) ||
                   (x >= 50 && x <= 53 && y >= 15 && y <= 16) || (x >= 50 && x <= 53 && y >= 23 && y <= 24) || // letter D
                   (x >= 58 && x <= 59 && y >= 15 && y <= 18) || (x >= 66 && x <= 67 && y >= 15 && y <= 18) ||
                   (x >= 60 && x <= 65 && y >= 19 && y <= 20) || (x >= 62 && x <= 63 && y >= 21 && y <= 24) || // letter Y
                   (x >= 70 && x <= 75 && y >= 15 && y <= 16) || (x >= 76 && x <= 77 && y >= 17 && y <= 20) ||
                   (x >= 72 && x <= 75 && y >= 19 && y <= 20) || (x >= 73 && x <= 74 && y >= 23 && y <= 24);   // ? mark

    assign press = (y == 31 && ((x >= 23 && x <= 25) || (x >= 28 && x <= 30) || (x >= 33 && x <= 36) || (x >= 39 && x <= 41) ||
                   (x >= 44 && x <= 46) || (x >= 50 && x <= 52) || (x >= 55 && x <= 59) || x == 61 || x == 64 || (x >= 67 && x <= 68) || 
                   (x == 72))) || // first row
                   (y == 32 && (x == 23 || x == 26 || x == 28 || x == 31 || x == 33 || x == 38 || x == 43 || x == 50 || x == 53 ||
                   x == 57 || x == 64 || (x >= 61 && x <= 62) || x == 66 || x == 69 || x == 72)) || // second row
                   (y == 33 && ((x >= 23 && x <= 25) || (x >= 28 && x <= 30) || (x >= 33 && x <= 35) || (x >= 39 && x <= 40) ||
                   (x >= 44 && x <= 45) || (x >= 50 && x <= 52) || x == 57 || x == 61 || (x >= 63 && x <= 64) || x == 66 || x == 72)) || // third row
                   (y == 34 && (x == 23 || x == 28 || x == 30 || x == 33 || x == 41 || x == 46 || x == 50 || x == 53 || x == 57 ||
                   x == 61 || x == 64 || x == 66 || x == 69)) || // fourth row
                   (y == 35 && (x == 23 || x == 28 || x == 31 || (x >= 33 && x <= 36) || (x >= 38 && x <= 40) || (x >= 43 && x <= 45) ||
                   (x >= 50 && x <= 52) || x == 57 || x == 61 || x == 64 || (x >= 67 && x <= 68) || x == 72)); // fifth row
                   
    assign paint_black = ready || press; 

    always @ (posedge clk_25Mhz)
    begin
        
        if (READY == 0) begin
            // not ready screen
            if (paint_black) begin
                oled_screen <= 0;
            end
            else oled_screen <= 16'b11111_111111_11111;
            
        end
        
    end

endmodule
