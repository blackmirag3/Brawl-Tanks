`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2024 07:25:52 PM
// Design Name: 
// Module Name: check_movement
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


module check_movement (input [7:0] user_x_cen, user_y_cen,
                        input [7:0] opp_x_cen, opp_y_cen, 
                        output can_up, can_down, can_left, can_right);
                        
    reg [7:0] x_min = 0, x_max = 95, y_min = 0, y_max = 63;
    
    // check whether user tank is right below or right above opp tank
    // check whether user tank and opp tank are on the same horizontal level i.e. abs(user x - opp x) <= 5
    assign can_up = ((user_y_cen - opp_y_cen == 7) && (user_x_cen - opp_x_cen <= 6 || opp_x_cen - user_x_cen <= 6))
                    || (user_y_cen - 3 == y_min) ? 0 : 1;
    assign can_down = ((opp_y_cen - user_y_cen == 7) && (user_x_cen - opp_x_cen <= 6 || opp_x_cen - user_x_cen <= 6))
                    || (user_y_cen + 3 == y_max) ? 0 : 1;
                    
    // check whether user tank is right beside
    // check whether user tank and opp tank are on the same vertical level i.e. abs(user y - opp y) <= 5
    assign can_right = ((opp_x_cen - user_x_cen == 7) && (user_y_cen - opp_y_cen <= 6 || opp_y_cen - user_y_cen <= 6))
                    || (user_x_cen + 3 == x_max) ? 0 : 1;
    assign can_left = ((user_x_cen - opp_x_cen == 7) && (user_y_cen - opp_y_cen <= 6 || opp_y_cen - user_y_cen <= 6))
                    || (user_x_cen - 3 == x_min) ? 0 : 1;
                        
endmodule
