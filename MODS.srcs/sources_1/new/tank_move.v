`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 12:16:44 AM
// Design Name: 
// Module Name: tank_move
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


module tank_move (input clk, [2:0] dir, movement, input GAME_START, GAME_END, RX_DONE, btnC,
                  input can_up, can_down, can_right, can_left,
                  input [18:0] received_data,
                  output reg [7:0] user_x_cen = 107, user_y_cen = 192, opp_x_cen = 108, opp_y_cen = 53,
                  output reg USER_READY = 0, OPP_READY = 0, NEW_GAME = 1, TX_START = 0,
                  output reg [18:0] to_transmit, output reg [2:0] opp_dir = 3'b100);

    wire clk_60hz, clk_25Mhz;
    
    reg [2:0] prev_dir = 0;
    reg WAIT = 0;

//    slow_clock c0 (.CLOCK(clk), .m(32'd999999), .SLOW_CLOCK(clk_50hz));
    slow_clock c0 (.CLOCK(clk), .m(32'd833333), .SLOW_CLOCK(clk_60hz));
    slow_clock c1 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));

    always @ (posedge clk_60hz)
    begin
        TX_START <= 0;
        
        if (GAME_START == 1 && GAME_END == 0) begin
            NEW_GAME <= 0;
            prev_dir <= dir;

            // moving
            case (dir)
                3'b000 : begin // D position 1 (facing forward)
                    case (movement)
                        3'b001 : begin //move forward
                            user_y_cen = can_up ? user_y_cen - 1 : user_y_cen;                   
                        end   
                        3'b010: begin //move backward
                            user_y_cen = can_down ? user_y_cen + 1 : user_y_cen;
                        end
                        3'b011: begin //move left
                            user_x_cen = can_left ? user_x_cen - 1 : user_x_cen;
                        end
                        3'b100: begin //move right
                            user_x_cen = can_right ? user_x_cen + 1 : user_x_cen;
                        end                
                    endcase
                    
                end
                
                3'b001 : begin // D position 2 (facing front-right)
                    case (movement)
                        3'b001 : begin //move forward
                            if (can_right && can_up) begin
                                user_x_cen = user_x_cen + 1;
                                user_y_cen = user_y_cen - 1;
                            end             
                        end   
                        3'b010: begin //move backward
                            if (can_left && can_down) begin
                                user_x_cen = user_x_cen - 1;
                                user_y_cen = user_y_cen + 1;
                            end
                        end
                        3'b011: begin //move left
                            if (can_left && can_up) begin
                                user_x_cen = user_x_cen - 1;
                                user_y_cen = user_y_cen - 1;
                            end
                        end
                        3'b100: begin //move right
                            if (can_down && can_right) begin
                                user_x_cen = user_x_cen + 1;
                                user_y_cen = user_y_cen + 1;
                            end
                        end                
                    endcase
                end
                
                3'b010 : begin // D position 3 (facing rightwards)
                    case(movement)
                        3'b001 : begin //move forward
                            user_x_cen = can_right ? user_x_cen + 1 : user_x_cen;                  
                        end   
                        3'b010: begin //move backward
                            user_x_cen = can_left ? user_x_cen - 1 : user_x_cen;
                        end
                        3'b011: begin //move left
                            user_y_cen = can_up ? user_y_cen - 1 : user_y_cen; 
                        end
                        3'b100: begin //move right
                            user_y_cen = can_down ? user_y_cen + 1 : user_y_cen;
                        end                
                    endcase 
                end
                
                3'b011 : begin // D position 4 (facing back-right)
                    case(movement)
                        3'b001 : begin //move forward
                            if (can_down && can_right) begin
                                user_x_cen = user_x_cen + 1;
                                user_y_cen = user_y_cen + 1;
                            end
                        end   
                        3'b010: begin //move backward
                            if (can_left && can_up) begin
                                user_x_cen = user_x_cen - 1;
                                user_y_cen = user_y_cen - 1;
                            end
                        end
                        3'b011: begin //move left
                            if (can_right && can_up) begin
                                user_x_cen = user_x_cen + 1;
                                user_y_cen = user_y_cen - 1;
                            end
                        end
                        3'b100: begin //move right
                            if (can_left && can_down) begin
                                user_x_cen = user_x_cen - 1;
                                user_y_cen = user_y_cen + 1;
                            end
                        end                
                    endcase
                end
                
                3'b100 : begin // D position 5 (facing backwards)
                    case(movement)
                        3'b001 : begin //move forward
                            user_y_cen = can_down ? user_y_cen + 1 : user_y_cen;                   
                        end   
                        3'b010: begin //move backward
                            user_y_cen = can_up ? user_y_cen - 1 : user_y_cen;
                        end
                        3'b011: begin //move left
                            user_x_cen = can_right ? user_x_cen + 1 : user_x_cen;
                        end
                        3'b100: begin //move right
                            user_x_cen = can_left ? user_x_cen - 1 : user_x_cen;
                        end                
                    endcase
                end
                
                3'b101 : begin // D position 6 (facing back-left)
                    case(movement)
                    3'b001 : begin //move forward
                        if (can_left && can_down) begin
                            user_x_cen = user_x_cen - 1;
                            user_y_cen = user_y_cen + 1;                   
                        end
                    end   
                    3'b010: begin //move backward
                        if (can_right && can_up) begin
                            user_x_cen = user_x_cen + 1;
                            user_y_cen = user_y_cen - 1;
                        end
                    end
                    3'b011: begin //move left
                        if (can_right && can_down) begin
                            user_x_cen = user_x_cen + 1;
                            user_y_cen = user_y_cen + 1;
                        end
                    end
                    3'b100: begin //move right
                        if (can_left && can_up) begin
                            user_x_cen = user_x_cen - 1;
                            user_y_cen = user_y_cen - 1;
                        end
                    end                
                    endcase
                    
                end
                            
                3'b110 : begin // D position 7 (facing leftwards)
                    case(movement)
                        3'b001 : begin //move forward
                            user_x_cen = can_left ? user_x_cen - 1 : user_x_cen;                
                        end   
                        3'b010: begin //move backward
                            user_x_cen = can_right ? user_x_cen + 1 : user_x_cen;
                        end
                        3'b011: begin //move left
                            user_y_cen = can_down ? user_y_cen + 1 : user_y_cen;
                        end
                        3'b100: begin //move right
                            user_y_cen = can_up ? user_y_cen - 1 : user_y_cen;
                        end                
                    endcase
                end
                
                3'b111 : begin // D position 8 (facing front-left)
                    case(movement)
                        3'b001 : begin //move forward
                            if (can_left && can_up) begin
                                user_x_cen = user_x_cen - 1;
                                user_y_cen = user_y_cen - 1;                   
                            end
                        end   
                        3'b010: begin //move backward
                            if (can_right && can_down) begin
                                user_x_cen = user_x_cen + 1;
                                user_y_cen = user_y_cen + 1;
                            end
                        end
                        3'b011: begin //move left
                            if (can_left && can_down) begin
                                user_x_cen = user_x_cen - 1;
                                user_y_cen = user_y_cen + 1;
                            end
                        end
                        3'b100: begin //move right
                            if (can_right && can_up) begin
                            user_x_cen = user_x_cen + 1;
                            user_y_cen = user_y_cen - 1;
                            end                
                        end
                    endcase
                end
                
            endcase

            // 18 - bit transfer data. data[15:8] = user y max pos, data[7:0] = user x max pos 
            // data[18:16] = user direction state
            // with respect to the user's coordinates
            to_transmit <= {dir, user_y_cen, user_x_cen};
            if (prev_dir != dir || movement != 0) TX_START <= 1;
        end
        else if (GAME_END == 1 && USER_READY == 1) begin

            USER_READY <= 0;

            user_x_cen = 107;
            user_y_cen = 192;

            to_transmit <= {3'b000, user_y_cen, user_x_cen};
            TX_START <= 1;
        end
        else begin
            if (btnC && USER_READY == 0) begin
            
                TX_START <= 1;
                to_transmit <= 16'haaaa;
                USER_READY <= 1;
                NEW_GAME <= 1;
                
            end
        end
    end

    always @ (posedge clk_25Mhz)
    begin

        if (RX_DONE == 0) WAIT <= 1;

        if (RX_DONE == 1 && WAIT == 1) begin
            WAIT <= 0;
            if (GAME_START == 1 && GAME_END == 0) begin
                opp_x_cen <= 215 - received_data[7:0];
                opp_y_cen <= 245 - received_data[15:8];
                case (received_data[18:16])
                    3'b000 : opp_dir <= 3'b100;
                    3'b001 : opp_dir <= 3'b101;
                    3'b010 : opp_dir <= 3'b110;
                    3'b011 : opp_dir <= 3'b111;
                    3'b100 : opp_dir <= 3'b000;
                    3'b101 : opp_dir <= 3'b001;
                    3'b110 : opp_dir <= 3'b010;
                    3'b111 : opp_dir <= 3'b011;
                endcase
            end
            else begin
                OPP_READY <= received_data == 16'haaaa ? 1 : 0;
            end
        end
        
        if (GAME_END == 1) begin
            opp_x_cen <= 108;
            opp_y_cen <= 53;
            opp_dir <= 3'b100;
            OPP_READY <= received_data == 16'haaaa ? 1 : 0;
        end

    end

endmodule
