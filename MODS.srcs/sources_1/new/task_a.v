`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 01:27:00
// Design Name: 
// Module Name: task_a
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


module task_a(input clock, btnC, btnD, [12:0] x, y , output reg [15:0] oled_data = 0);

    wire clk_1Mhz, btnC_debounce, btnD_debounce;
    reg [15:0] green = 16'b00000_111111_00000;
    reg [15:0] orange = 16'b11111_101010_00000;
    reg [15:0] red = 16'b11111_000000_00000;
    reg started_one = 0, started_two = 0, has_started_two = 0;
    reg [1:0] shape = 2'b00;
    reg [31:0] counter_one = 0, counter_two = 0;
    
    slow_clock c0 (.CLOCK(clock), .m(32'd49999), .SLOW_CLOCK(clk_1Khz));
    slow_clock c1 (.CLOCK(clock), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    debouncer d0(.clock(clk_1Mhz), .button(btnD), .state(btnD_debounce));
    
    always @ (posedge clk_1Khz) begin
        if (started_one == 1) counter_one <= (counter_one == 5500) ? 0 : counter_one + 1;
        
        if (btnD_debounce == 1) started_two = 1;
        else has_started_two = 0;
    end
    
    always @ (posedge clock )begin //updates every millisecond
    //A1: create red border
        oled_data <= 0;
        if ((x == 3 && y >= 3 && y < 61) ||
                (x == 92 && y >= 3 && y < 61) ||
                (y == 3 && x >= 3 && x < 93) ||
                (y == 60 && x >= 3 && x < 93)) oled_data <= red;

        //A2
        if (btnC == 1) started_one = 1;
        
        //A3: start
        if (started_one == 1) begin
            //A2 orange border
            if ((x >= 6 && x < 9 && y >= 6 && y < 58) ||
                (x >= 87 && x < 90 && y >= 6 && y < 58) ||
                (x >= 9 && x < 87 && y >= 6 && y < 9) ||
                (x >= 9 && x < 87 && y >= 55 && y < 58))oled_data <= orange;
            //A3 sequence
            //green border 1 px
            if ((counter_one > 1999) && ((x == 11 && y >= 11 && y < 53) || 
                (x == 84 && y >= 11 && y < 53) ||
                (y == 11 && x >= 12 && x < 84) ||
                (y == 52  && x >= 12 && x < 84))) oled_data <= green;
            //green border 2 px
            if ((counter_one > 3499) && ((x >= 14 && x < 16 && y >= 14 && y < 50) ||
                (x >= 80 && x < 82 && y >= 14 && y < 50) ||
                (y >= 14 && y < 16 && x >= 15 && x < 80) ||
                (y >= 48 && y < 50 && x >= 15 && x < 80))) oled_data <= green;
            //green border 3 px
            if ((counter_one >= 4499) && ((x >= 18 && x < 21 && y >= 18 && y < 46) ||
                (x >= 75 && x < 78 && y >= 18 && y < 46) ||
                (y >= 18 && y < 21 && x >= 19 && x < 75) ||
                (y >= 43 && y < 46 && x >= 19 && x < 75))) oled_data <= green;
            //A3 part 6 sequence
            
            if (started_two == 1 && has_started_two == 0) begin
                if (shape == 0) begin
                    shape = 2'b01;
                end
                else if (shape == 2'b01) begin
                    //create red square
                    if (x >= 45 && x < 52 && y >= 29 && y < 36) oled_data <= red;
                    else oled_data <= 0;
                    shape = 2'b10;
                end
                else if (shape == 2'b10) begin
                    //orange circle
                    if ((x >= 47 && x < 50 && (y == 29 || y == 35)) || 
                    (x >= 46 && x <51 && (y == 30 || y == 34)) || 
                    (x >= 45 && x < 52 && (y >= 31 && y < 34))) oled_data <= orange;
                    else oled_data <= 0;
                    shape = 2'b11;
                end
                else if (shape == 2'b11) begin
                    //green triangle
                    if ((x >= 45 && x < 52 && y == 29) ||
                    (x >= 44 && x < 51 && y == 30) ||
                    (x >= 45 && x < 50 && y == 31) ||
                    (x >= 46 && x < 49 && y == 32) || 
                    (x == 47 && y == 33)) oled_data <= red;
                    else oled_data <= 0;
                    shape = 2'b01;
                end
                //started_two = 0;
            end
        end
    end
endmodule

