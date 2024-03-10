`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2024 16:38:48
// Design Name: 
// Module Name: task_d
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


module task_d(input clock, start, up, left, right, speed_sw, [12:0] x, y , output reg [15:0] oled_data = 0);

    wire clk_25Mhz, clk_1khz;
    reg [15:0] blue_c = 16'b00000_000000_11111;
    reg [15:0] white_c = 16'b11111_111111_11111;
    reg [15:0] curr_c = 0;
    reg [12:0] min_pos_x = 0, max_pos_x = 4, min_pos_y = 0, max_pos_y = 4;
    reg [12:0] start_min_x = 45, start_max_x = 49, start_min_y = 59, start_max_y = 63; 
    reg [1:0] button_state = 0;
    reg started = 0, reset = 0, stopped = 0;
    reg [31:0] counter = 0, counter_slow = 0, counter_fast = 0;
    
    slow_clock c0 (.CLOCK(clock), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c1 (.CLOCK(clock), .m(32'd49999), .SLOW_CLOCK(clk_1khz));
    
    always @ (posedge clk_1khz)
    begin
        if (started == 1) begin
            reset <= 0;
            if (up == 1) button_state <= 2'b01;
            else if (left == 1) button_state <= 2'b10;
            else if (right == 1) button_state <= 2'b11;
            if (start == 1 && stopped == 1) begin
                reset <= 1;
                button_state <= 0;
            end
        end
        else begin
            started <= start;
            reset <= start;
        end
    end
    
    always @ (posedge clk_25Mhz)
    begin
        if (started == 1 && reset == 0) begin
            counter_slow <= counter_slow == 833332 ? 0 : counter_slow + 1;
            counter_fast <= counter_fast == 555555 ? 0 : counter_fast + 1;
            counter <= counter_slow;
            if (speed_sw == 1) begin
                counter <= counter_fast;
            end
            
            stopped <= 0;
            case (button_state)
                2'b01 : begin
                    min_pos_y <= (counter == 0 && min_pos_y > 0) ? min_pos_y - 1 : min_pos_y;
                    max_pos_y <= (counter == 0 && max_pos_y > 4) ? max_pos_y - 1 : max_pos_y;
                    if (min_pos_y == 0) stopped <= 1;
                end
                2'b10 : begin
                    min_pos_x <= (counter == 0 && min_pos_x > 0) ? min_pos_x - 1 : min_pos_x;
                    max_pos_x <= (counter == 0 && max_pos_x > 4) ? max_pos_x - 1 : max_pos_x;
                    if (min_pos_x == 0) stopped <= 1;
                end
                2'b11 : begin
                    min_pos_x <= (counter == 0 && min_pos_x < 91) ? min_pos_x + 1 : min_pos_x;
                    max_pos_x <= (counter == 0 && max_pos_x < 95) ? max_pos_x + 1 : max_pos_x;
                    if (max_pos_x == 95) stopped <= 1;
                end
            endcase
        end
        else if (started == 1 && reset == 1) begin
            curr_c <= white_c;
            min_pos_x <= start_min_x;
            max_pos_x <= start_max_x; 
            min_pos_y <= start_min_y;
            max_pos_y <= start_max_y;
        end
        else begin
            curr_c <= blue_c;
        end
        
        if (x >= min_pos_x && x <= max_pos_x && y >= min_pos_y && y <= max_pos_y) begin
            oled_data <= curr_c;
        end
        else begin
            oled_data <= 0;
        end
    end
    
endmodule
