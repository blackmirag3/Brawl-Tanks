`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2024 11:33:52
// Design Name: 
// Module Name: camera_FPS
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

//All positional inputs are relative to player perspective

//calculates size of object using distance-based projection
//renders objects using x for horizontal displacement and y distance for render order

module camera_FPS(
input clock,
input [7:0] enemy_x, enemy_y,
input [2:0] enemy_direction,
input [7:0] pillar_x, pillar_y,
//input [7:0] border_x, border_y,
input [12:0] x, y, //for OLED
output reg [15:0] oled_data = 0
    );
    
    reg [15:0] black_c = 0;     
    reg [15:0] green_c = 16'b00000_111111_00000; 
    reg [15:0] red_c = 16'b11111_000000_00000;
    reg [15:0] white_c = 16'b11111_111111_11111;
    
    reg [7:0] enemy_x_rel, pillar_x_re;
    reg [7:0] enemy_w, enemy_h, pillar_w, pillar_h, barrel_front_h, barrel_front_w, barrel_side_h, barrel_side_w;
    
    //wire opp_front, opp_left, opp_right, opp_back;
    
    initial begin
    end
    
    always @ (posedge clock) begin     
    
        //find size to render objects
        enemy_w = enemy_size_x / enemy_y;
        enemy_h = enemy_size_y / enemy_y;
        pillar_w = pillar_size_x / pillar_y;
        pillar_h = pillar_size_y / pillar_y;
        
        //translate sprite
        //todo
        
        oled_data <= black_c;
        
        case (enemy_direction)
                    3'b000 : begin // D position 1 (facing forward)
                        if ( (x >= 0 && x < enemy_w) || (y >=0 && y < enemy_h)) begin
                            oled_data <= red_c;
                        end
                        
                        if ( x >= 0 && x < barrel_front_size) || (y >= 0 && y < barrel_front_size
                    end
                    
                    3'b001 : begin // D position 2 (facing front-right)
                        if ( (x >= 0 && x < enemy_w) || (y >=0 && y < enemy_h)) begin
                            oled_data <= red_c;
                        end
                    end
                    
                    3'b010 : begin // D position 3 (facing rightwards)
                        if (opp_r_red) begin
                            opp_col <= red_c;
                        end
                        else if (opp_r_blue) begin
                            opp_col <= purple_c;
                        end
                        else if(opp_r_white) begin
                            opp_col <= white_c;
                        end
                        else begin
                            has_opp <= 0;
                            opp_col <= 0;
                        end
                    end
                    
                    3'b011 : begin // D position 4 (facing back-right)
                        if (opp_dr_red) begin
                            opp_col <= red_c;
                        end
                        else if (opp_dr_blue) begin
                            opp_col <= purple_c;
                        end
                        else if (opp_dr_white) begin
                            opp_col <= white_c;
                        end
                        else begin
                            has_opp <= 0;
                            opp_col <= 0;
                        end
                    end
                    
                    3'b100 : begin // D position 5 (facing backwards)
                        if (opp_d_red) begin
                            opp_col <= red_c;
                        end
                        else if (opp_d_blue) begin
                            opp_col <= purple_c;
                        end
                        else if (opp_d_white) begin
                            opp_col <= white_c;
                        end
                        else begin
                            has_opp <= 0;
                            opp_col <= 0;
                        end
                    end
                  
                    3'b101 : begin // D position 6 (facing back-left)
                        if (opp_dl_red) begin
                            opp_col <= red_c;
                        end
                        else if (opp_dl_blue) begin
                            opp_col <= purple_c;
                        end
                        else if (opp_dl_white) begin
                            opp_col <= white_c;
                        end
                        else begin
                            has_opp <= 0;
                            opp_col <= 0;
                        end
                    end
                                
                    3'b110 : begin // D position 7 (facing leftwards)
                        if (opp_l_red) begin
                            opp_col <= red_c;
                        end
                        else if (opp_l_blue) begin
                            opp_col <= purple_c;
                        end
                        else if (opp_l_white) begin
                            opp_col <= white_c;
                        end
                        else begin
                            has_opp <= 0;
                            opp_col <= 0;
                        end
                    end
                    
                    3'b111 : begin // D position 8 (facing front-left)
                        if (opp_fl_red) begin
                            opp_col <= red_c;
                        end
                        else if (opp_fl_blue) begin
                            opp_col <= purple_c;
                        end
                        else if (opp_fl_white) begin
                            opp_col <= white_c;
                        end
                        else begin
                            has_opp <= 0;
                            opp_col <= 0;
                        end
                    end
                    
                endcase
        // Rotate translated position using the lookup values for 3 bit direction orientation
        // Note: Using 8-bit LUT values extended to 16 bits for calculation
        // The >> 7 operation is to normalize the result of the multiplication
//        rel_x <= ((trans_x * cos_theta) - (trans_y * sin_theta)) >>> 7;
//        rel_y <= ((trans_x * sin_theta) + (trans_y * cos_theta)) >>> 7;
    
        //enemy closer than pillar
//        if (enemy_y < pillar_y) begin
         
//        end
        
        //pillar closer than enemy
//        else begin
        
//        end
    end
endmodule

