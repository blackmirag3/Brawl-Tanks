`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2024 01:05:13 AM
// Design Name: 
// Module Name: game_state
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


module game_state (input clk, input [12:0] x, y, pixel_index,
                    input USER_READY, OPP_READY, GAME_END, USER_WIN, NEW_GAME, 
                    output reg GAME_START = 0, 
                    output reg [15:0] oled_screen);

    wire clk_25Mhz, clk_1khz;
    
    reg [15:0] orange = 16'b11111_101010_00000;
    reg [15:0] yellow = 16'b11111_111010_00000;
    reg [15:0] green = 16'b00101_111011_00000;
    reg [15:0] red = 16'b11101_000010_00000;

    reg [11:0] count = 0;
    reg [1:0] count_down_state = 0;

    slow_clock c1 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c2 (.CLOCK(clk), .m(32'd49999), .SLOW_CLOCK(clk_1khz));

    wire waiting, for_p2, waiting_scr;
    wire three, three_edge, two, two_edge, one, one_edge;
    wire you_win, you_lose, play_again, winner, loser;
    
    assign waiting = (x >= 14 && x <= 15 && y >= 17 && y <= 26) || (x >= 22 && x <= 23 && y >= 17 && y <= 26) ||
                     (x >= 16 && x <= 17 && y >= 23 && y <= 24) || (x >= 18 && x <= 19 && y >= 21 && y <= 22) ||
                     (x >= 20 && x <= 21 && y >= 23 && y <= 24) || // letter W
                     (x >= 26 && x <= 27 && y >= 19 && y <= 26) || (x >= 32 && x <= 33 && y >= 19 && y <= 26) ||
                     (x >= 28 && x <= 31 && y >= 17 && y <= 18) || (x >= 28 && x <= 31 && y >= 21 && y <= 22) || // letter A
                     (x >= 36 && x <= 41 && y >= 17 && y <= 18) || (x >= 38 && x <= 39 && y >= 19 && y <= 24) ||
                     (x >= 36 && x <= 41 && y >= 25 && y <= 26) || // letter I
                     (x >= 44 && x <= 53 && y >= 17 && y <= 18) || (x >= 48 && x <= 49 && y >= 19 && y <= 26) || // letter T
                     (x >= 56 && x <= 61 && y >= 17 && y <= 18) || (x >= 58 && x <= 59 && y >= 19 && y <= 24) ||
                     (x >= 56 && x <= 61 && y >= 25 && y <= 26) || // letter I
                     (x >= 64 && x <= 65 && y >= 17 && y <= 26) || (x >= 66 && x <= 67 && y >= 19 && y <= 20) ||
                     (x >= 68 && x <= 69 && y >= 21 && y <= 22) || (x >= 70 && x <= 71 && y >= 17 && y <= 26) || // letter N
                     (x >= 74 && x <= 75 && y >= 19 && y <= 24) || (x >= 76 && x <= 79 && y >= 17 && y <= 18) ||
                     (x >= 76 && x <= 79 && y >= 25 && y <= 26) || (x >= 78 && x <= 81 && y >= 21 && y <= 22) ||
                     (x >= 80 && x <= 81 && y >= 23 && y <= 24); // letter G
                     
    assign for_p2 = (x >= 11 && x <= 12 && y >= 31 && y <= 40) || (x >= 13 && x <= 18 && y >= 31 && y <= 32) ||
                    (x >= 13 && x <= 16 && y >= 35 && y <= 36) || // letter F
                    (x >= 21 && x <= 22 && y >= 33 && y <= 38) || (x >= 23 && x <= 26 && y >= 31 && y <= 32) ||
                    (x >= 27 && x <= 28 && y >= 33 && y <= 38) || (x >= 23 && x <= 26 && y >= 39 && y <= 40) || // letter O
                    (x >= 31 && x <= 36 && y >= 31 && y <= 32) || (x >= 31 && x <= 32 && y >= 33 && y <= 40) ||
                    (x >= 33 && x <= 36 && y >= 35 && y <= 36) || (x >= 37 && x <= 38 && y >= 33 && y <= 34) ||
                    (x >= 35 && x <= 36 && y >= 37 && y <= 38) || (x >= 37 && x <= 38 && y >= 39 && y <= 40) || // letter R
                    (x >= 45 && x <= 46 && y >= 31 && y <= 40) || (x >= 47 && x <= 50 && y >= 31 && y <= 32) ||
                    (x >= 51 && x <= 52 && y >= 33 && y <= 34) || (x >= 47 && x <= 50 && y >= 35 && y <= 36) || // letter P
                    (x >= 55 && x <= 56 && y >= 33 && y <= 34) || (x >= 57 && x <= 60 && y >= 31 && y <= 32) ||
                    (x >= 61 && x <= 62 && y >= 33 && y <= 34) || (x >= 59 && x <= 60 && y >= 35 && y <= 36) ||
                    (x >= 57 && x <= 58 && y >= 37 && y <= 38) || (x >= 55 && x <= 62 && y >= 39 && y <= 40) || // num 2
                    (x >= 67 && x <= 68 && y >= 39 && y <= 40) || (x >= 75 && x <= 76 && y >= 39 && y <= 40) ||
                    (x >= 83 && x <= 84 && y >= 39 && y <= 40);
                    
    assign waiting_scr = waiting || for_p2;
    
    assign three = (x >= 37 && x <= 56 && y >= 7 && y <= 13) || (x >= 30 && x <= 36 && y >= 14 && y <= 20) ||
                   (x >= 57 && x <= 63 && y >= 14 && y <= 27) || (x >= 44 && x <= 56 && y >= 28 && y <= 34) ||
                   (x >= 57 && x <= 63 && y >= 35 && y <= 48) || (x >= 30 && x <= 36 && y >= 42 && y <= 48) ||
                   (x >= 37 && x <= 56 && y >= 49 && y <= 55);
                   
    assign three_edge = ((x >= 37 && x <= 56) && (y == 6 || y == 14 || y == 48 || y == 56)) ||
                        (x == 36 && ((y >= 7 && y <= 13) || (y >= 49 && y <= 55))) ||
                        (x == 57 && ((y >= 7 && y <= 13) || (y >= 49 && y <= 55))) ||
                        ((x == 29 || x == 37) && ((y >= 14 && y <= 20) || (y >= 42 && y <= 48))) ||
                        ((x == 56 || x == 64) && ((y >= 14 && y <= 27) || (y >= 35 && y <= 48))) ||
                        ((x >= 30 && x <= 36) && (y == 13 || y == 21 || y == 41 || y == 49)) ||
                        ((x >= 57 && x <= 63) && (y == 13 || y == 28 || y == 34 || y == 49)) ||
                        ((x >= 44 && x <= 55) && (y == 27 || y == 35)) ||
                        ((y >= 28 && y <= 34) && (x == 43 || x == 57));
                        
    assign two = (x >= 37 && x <= 56 && y >= 7 && y <= 13) || (x >= 30 && x <= 36 && y >= 14 && y <= 20) ||
                 (x >= 57 && x <= 63 && y >= 14 && y <= 27) || (x >= 44 && x <= 56 && y >= 28 && y <= 34) ||
                 (x >= 37 && x <= 43 && y >= 35 && y <= 41) || (x >= 30 && x <= 36 && y >= 42 && y <= 48) ||
                 (x >= 30 && x <= 63 && y >= 49 && y <= 55);
                 
    assign two_edge = ((x >= 37 && x <= 56) && (y == 6 || y == 14)) ||
                      ((x == 36 || x == 57) && (y >= 7 && y <= 13)) ||
                      (y == 13 && ((x >= 30 && x <= 36) || (x >= 57 && x <= 63))) ||
                      ((x == 29 || x == 37) && (y >= 14 && y <= 20)) ||
                      (y == 21 && x >= 30 && x <= 36) || ((x == 56 || x == 64) && (y >= 14 && y <= 27)) ||
                      (y == 28 && x >= 57 && x <= 63) || ((x >= 44 && x <= 56) && (y == 27 || y == 35)) ||
                      ((x == 43 || x == 57) && (y >= 28 && y <= 34)) || ((x >= 37 && x <= 43) && (y == 34 || y == 42)) ||
                      ((x == 36 || x == 44) && (y >= 35 && y <= 41)) || (y == 41 && x >= 30 && x <= 35) ||
                      (x == 37 && y >= 43 && y <= 48) || (x == 29 && y >= 42 && y <= 55) ||
                      (y == 48 && x >= 38 && x <= 63) || (y == 56 && x >= 30 && x <= 63) || (x == 64 && y >= 49 && y <= 55);

    assign one = (x >= 44 && x <= 50 && y >= 7 && y <= 48) || (x >= 37 && x <= 43 && y >= 14 && y <= 20) || (x >= 30 && x <= 63 && y >= 49 && y <= 55);
    
    assign one_edge = (y == 6 && x >= 44 && x <= 50) || (x == 51 && y >= 7 && y <= 47) || (x == 36 && y >= 14 && y <= 20) ||
                      (x == 43 && ((y >= 7 && y <= 13) || y >= 21 && y <= 47)) || ((x >= 37 && x <= 42) && (y == 13 || y == 21)) ||
                      (y == 48 && ((x >= 30 && x <= 43) || (x >= 51 && x <= 63))) || (y == 56 && x >= 30 && x <= 63) ||
                      ((x == 29 || x == 64) && (y >= 49 && y <= 55));

    assign you_win = (x >= 10 && x <= 11 && y >= 8 && y <= 9) || (x >= 18 && x <= 19 && y >= 8 && y <= 9) ||
                      (x >= 12 && x <= 13 && y >= 10 && y <= 11) || (x >= 16 && x <= 17 && y >= 10 && y <= 11) ||
                      (x >= 14 && x <= 15 && y >= 12 && y <= 21) || // letter Y
                      (x >= 24 && x <= 29 && y >= 8 && y <= 9) || (x >= 24 && x <= 29 && y >= 20 && y <= 21) ||
                      (x >= 22 && x <= 23 && y >= 10 && y <= 19) || (x >= 30 && x <= 31 && y >= 10 && y <= 19) || // letter O
                      (x >= 34 && x <= 35 && y >= 8 && y <= 19) || (x >= 42 && x <= 43 && y >= 8 && y <= 19) ||
                      (x >= 36 && x <= 41 && y >= 20 && y <= 21) || // letter U
                      (x >= 50 && x <= 51 && y >= 8 && y <= 21) || (x >= 58 && x <= 59 && y >= 8 && y <= 21) ||
                      (x >= 52 && x <= 53 && y >= 18 && y <= 19) || (x >= 56 && x <= 57 && y >= 18 && y <= 19) ||
                      (x >= 54 && x <= 55 && y >= 16 && y <= 17) || // letter W
                      (x >= 62 && x <= 67 && y >= 8 && y <= 9) || (x >= 64 && x <= 65 && y >= 10 && y <= 19) ||
                      (x >= 62 && x <= 67 && y >= 20 && y <= 21) || // letter I
                      (x >= 70 && x <= 71 && y >= 8 && y <= 21) || (x >= 72 && x <= 73 && y >= 10 && y <= 11) ||
                      (x >= 74 && x <= 75 && y >= 12 && y <= 13) || (x >= 76 && x <= 77 && y >= 14 && y <= 15) ||
                      (x >= 78 && x <= 79 && y >= 8 && y <= 21) || // letter N
                      (x >= 84 && x <= 85 && y >= 8 && y <= 17) || (x >= 84 && x <= 85 && y >= 20 && y <= 21); // ! mark
    
    assign you_lose = (x >= 3 && x <= 4 && y >= 8 && y <= 9) || (x >= 11 && x <= 12 && y >= 8 && y <= 9) ||
                       (x >= 5 && x <= 6 && y >= 10 && y <= 11) || (x >= 9 && x <= 10 && y >= 10 && y <= 11) ||
                       (x >= 7 && x <= 8 && y >= 12 && y <= 21) || // letter Y
                       (x >= 17 && x <= 22 && y >= 8 && y <= 9) || (x >= 17 && x <= 22 && y >= 20 && y <= 21) ||
                       (x >= 15 && x <= 16 && y >= 10 && y <= 19) || (x >= 23 && x <= 24 && y >= 10 && y <= 19) || // letter O
                       (x >= 27 && x <= 28 && y >= 8 && y <= 19) || (x >= 35 && x <= 36 && y >= 8 && y <= 19) ||
                       (x >= 29 && x <= 34 && y >= 20 && y <= 21) || // letter U
                       (x >= 43 && x <= 44 && y >= 8 && y <= 21) || (x >= 45 && x <= 52 && y >= 20 && y <= 21) || // letter L
                       (x >= 57 && x <= 62 && y >= 8 && y <= 9) || (x >= 55 && x <= 56 && y >= 10 && y <= 19) ||
                       (x >= 57 && x <= 62 && y >= 20 && y <= 21) || (x >= 63 && x <= 64 && y >= 10 && y <= 19) || // letter O
                       (x >= 69 && x <= 76 && y >= 8 && y <= 9) || (x >= 67 && x <= 68 && y >= 10 && y <= 11) ||
                       (x >= 69 && x <= 74 && y >= 12 && y <= 13) || (x >= 75 && x <= 76 && y >= 14 && y <= 19) ||
                       (x >= 69 && x <= 74 && y >= 20 && y <= 21) || (x >= 67 && x <= 68 && y >= 18 && y <= 19) || // letter S
                       (x >= 79 && x <= 80 && y >= 8 && y <= 21) || (x >= 81 && x <= 88 && y >= 8 && y <= 9) ||
                       (x >= 81 && x <= 84 && y >= 12 && y <= 13) || (x >= 81 && x <= 88 && y >= 20 && y <= 21) || // letter E
                       (x >= 91 && x <= 92 && y >= 8 && y <= 17) || (x >= 91 && x <= 92 && y >= 20 && y <= 21); // ! mark
    
    assign play_again = (x >= 28 && x <= 29 && y >= 31 && y <= 40) || (x >= 30 && x <= 33 && y >= 31 && y <= 32) ||
                        (x >= 34 && x <= 35 && y >= 33 && y <= 34) || (x >= 30 && x <= 33 && y >= 35 && y <= 36) || // letter P
                        (x >= 38 && x <= 39 && y >= 31 && y <= 40) || (x >= 40 && x <= 45 && y >= 39 && y <= 40) || // letter L
                        (x >= 50 && x <= 53 && y >= 31 && y <= 32) || (x >= 48 && x <= 49 && y >= 33 && y <= 40) ||
                        (x >= 50 && x <= 53 && y >= 35 && y <= 36) || (x >= 54 && x <= 55 && y >= 33 && y <= 40) || // letter A
                        (x >= 58 && x <= 59 && y >= 31 && y <= 34) || (x >= 60 && x <= 65 && y >= 35 && y <= 36) ||
                        (x >= 66 && x <= 67 && y >= 31 && y <= 34) || (x >= 62 && x <= 63 && y >= 37 && y <= 40) || // letter Y
                        (x >= 22 && x <= 25 && y >= 44 && y <= 45) || (x >= 20 && x <= 21 && y >= 46 && y <= 53) ||
                        (x >= 22 && x <= 25 && y >= 48 && y <= 49) || (x >= 26 && x <= 27 && y >= 46 && y <= 53) || // letter A
                        (x >= 32 && x <= 35 && y >= 44 && y <= 45) || (x >= 30 && x <= 31 && y >= 46 && y <= 51) ||
                        (x >= 32 && x <= 35 && y >= 52 && y <= 53) || (x >= 34 && x <= 37 && y >= 48 && y <= 49) ||
                        (x >= 36 && x <= 37 && y >= 50 && y <= 51) || // letter G
                        (x >= 42 && x <= 45 && y >= 44 && y <= 45) || (x >= 40 && x <= 41 && y >= 46 && y <= 53) ||
                        (x >= 42 && x <= 45 && y >= 48 && y <= 49) || (x >= 46 && x <= 47 && y >= 46 && y <= 53) || // letter A
                        (x >= 50 && x <= 55 && y >= 44 && y <= 45) || (x >= 52 && x <= 53 && y >= 46 && y <= 51) ||
                        (x >= 50 && x <= 55 && y >= 52 && y <= 53) || // letter I
                        (x >= 58 && x <= 59 && y >= 44 && y <= 53) || (x >= 60 && x <= 61 && y >= 46 && y <= 47) ||
                        (x >= 64 && x <= 65 && y >= 44 && y <= 53) || (x >= 62 && x <= 63 && y >= 48 && y <= 49) || // letter N
                        (x >= 68 && x <= 73 && y >= 44 && y <= 45) || (x >= 74 && x <= 75 && y >= 46 && y <= 49) ||
                        (x >= 70 && x <= 73 && y >= 48 && y <= 49) || (x >= 70 && x <= 71 && y >= 52 && y <= 53); // ? mark

    assign winner = you_win || play_again;
    assign loser = you_lose || play_again;

    always @ (posedge clk_1khz)
    begin
                
        count_down_state <= 0;
        if (USER_READY == 1 && OPP_READY == 1) begin
            count <= count == 3001 ? 0 : count + 1;

            if (count > 1000) count_down_state <= 1;
            if (count > 2000) count_down_state <= 2;
            if (count > 3000) count_down_state <= 3;
        end
        else count <= 0;
    end
    
    wire [15:0] init_oled;
    blk_mem_gen_0 oled_start (.clka(clk_25Mhz),
                              .addra(pixel_index),
                              .dina(init_oled),
                              .douta(init_oled),
                              .ena(1),
                              .wea(0));
    
    always @ (posedge clk_25Mhz)
    begin
        
        if (GAME_START == 0) begin
            
            if (USER_READY == 0) begin
                // start screen
                oled_screen <= init_oled;
            end
            else if (USER_READY == 1 && OPP_READY == 0) begin
                // wait screen
                if (waiting_scr) begin
                    oled_screen <= 0;
                end
                else oled_screen <= 16'b11111_111111_11111;
            end
            else if (USER_READY == 1 && OPP_READY == 1) begin
                case (count_down_state)
                    0 : begin
                        if (three) begin
                            oled_screen <= orange;
                        end
                        else if (three_edge) begin
                            oled_screen = 0;
                        end
                        else oled_screen <= 16'b11111_111111_11111;
                    end
                    1 : begin
                        if (two) begin
                            oled_screen <= yellow;
                        end
                        else if (two_edge) begin
                            oled_screen = 0;
                        end
                        else oled_screen <= 16'b11111_111111_11111;
                    end
                    2 : begin
                        if (one) begin
                            oled_screen <= green;
                        end
                        else if (one_edge) begin
                            oled_screen = 0;
                        end
                        else oled_screen <= 16'b11111_111111_11111;
                    end
                    3 : begin
                        GAME_START <= 1;
                    end
                endcase
                
            end
        end
        
        if (GAME_END == 1) begin
        
            if (USER_WIN) begin
                if (winner) begin
                    oled_screen <= 0;
                end
                else oled_screen <= green;
            end
            else begin
                if (loser) begin
                    oled_screen <= 0;
                end
                else oled_screen <= red;
            end
            
            GAME_START <= ~NEW_GAME;
        end
        
    end

endmodule
