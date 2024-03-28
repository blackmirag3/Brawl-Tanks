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


module check_movement (input [7:0] user_x_min, user_x_max, user_y_min, user_y_max,
                        input [7:0] opp_x_min, opp_x_max, opp_y_min, opp_y_max, 
                        output can_up, can_down, can_left, can_right);
                        
    reg [7:0] x_min = 0, x_max = 95, y_min = 0, y_max = 63;
    
    // check whether user tank is right below or right above opp tank
    // check whether user tank and opp tank are on the same horizontal level i.e. abs(user x - opp x) <= 5
    assign can_up = ((user_y_min - opp_y_max == 1) && (user_x_min - opp_x_min <= 5 || opp_x_min - user_x_min <= 5))
                    || (user_y_min == y_min) ? 0 : 1;
    assign can_down = ((opp_y_min - user_y_max == 1) && (user_x_min - opp_x_min <= 5 || opp_x_min - user_x_min <= 5))
                    || (user_y_max == y_max) ? 0 : 1;
                    
    // check whether user tank is right beside
    // check whether user tank and opp tank are on the same vertical level i.e. abs(user y - opp y) <= 5
    assign can_right = ((opp_x_min - user_x_max == 1) && (user_y_min - opp_y_min <= 5 || opp_y_min - user_y_min <= 5))
                    || (user_x_max == x_max) ? 0 : 1;
    assign can_left = ((user_x_min - opp_x_max == 1) && (user_y_min - opp_y_min <= 5 || opp_y_min - user_y_min <= 5))
                    || (user_x_min == x_min) ? 0 : 1;
                        
endmodule
