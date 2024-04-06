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
                        
    reg [7:0] x_min = 48, x_max = 167, y_min = 48, y_max = 197;
    
    wire border_up, border_down, border_right, border_left;
    
    assign border_up = (user_y_cen - 5 == y_min);
    assign border_down = (user_y_cen + 5 == y_max);
    assign border_right = (user_x_cen + 5 == x_max);
    assign border_left = (user_x_cen - 5 == x_min);
    
    wire opp_coll_up, opp_coll_down, opp_coll_right, opp_coll_left;
    
    assign opp_coll_up = ((user_y_cen - opp_y_cen == 11) && (user_x_cen - opp_x_cen <= 10 || opp_x_cen - user_x_cen <= 10));
    assign opp_coll_down = ((opp_y_cen - user_y_cen == 11) && (user_x_cen - opp_x_cen <= 10 || opp_x_cen - user_x_cen <= 10));
    assign opp_coll_right = ((opp_x_cen - user_x_cen == 11) && (user_y_cen - opp_y_cen <= 10 || opp_y_cen - user_y_cen <= 10));
    assign opp_coll_left = ((user_x_cen - opp_x_cen == 11) && (user_y_cen - opp_y_cen <= 10 || opp_y_cen - user_y_cen <= 10));
    
    wire mid_p_up, mid_p_down, mid_p_right, mid_p_left;
    
    assign mid_p_up = ((user_x_cen >= 90 && user_x_cen <= 104 && user_y_cen == 131) ||
                       (user_x_cen >= 111 && user_x_cen <= 125 && user_y_cen == 131) ||
                       (user_x_cen >= 100 && user_x_cen <= 110 && user_y_cen == 143));
    assign mid_p_down = ((user_x_cen >= 90 && user_x_cen <= 104 && user_y_cen == 114) ||
                         (user_x_cen >= 111 && user_x_cen <= 125 && user_y_cen == 114) ||
                         (user_x_cen >= 100 && user_x_cen <= 110 && user_y_cen == 102));
    assign mid_p_right = ((user_y_cen >= 103 && user_y_cen <= 119 && user_x_cen == 99) ||
                          (user_y_cen >= 126 && user_y_cen <= 142 && user_x_cen == 99) ||
                          (user_y_cen >= 115 && user_y_cen <= 130 && user_x_cen == 89));
    assign mid_p_left = ((user_y_cen >= 103 && user_y_cen <= 119 && user_x_cen == 116) ||
                         (user_y_cen >= 126 && user_y_cen <= 142 && user_x_cen == 116) ||
                         (user_y_cen >= 115 && user_y_cen <= 130 && user_x_cen == 126));
    
    wire wall_up, wall_down, wall_right, wall_left;
    
    assign wall_up = (user_x_cen >= 63 && user_x_cen <= 94 && user_y_cen == 177) || // bot left wall
                     (user_x_cen >= 69 && user_x_cen <= 81 && user_y_cen == 158) || // vert left wall
                     (user_x_cen >= 74 && user_x_cen <= 99 && user_y_cen == 97) || // top left wall
                     (user_x_cen >= 116 && user_x_cen <= 141 && user_y_cen == 162) || // bot right wall
                     (user_x_cen >= 134 && user_x_cen <= 146 && user_y_cen == 130) || // vert right wall
                     (user_x_cen >= 121 && user_x_cen <= 152 && user_y_cen == 83); // top right wall
                     
    assign wall_down = (user_x_cen >= 63 && user_x_cen <= 94 && user_y_cen == 162) || // bot left wall
                       (user_x_cen >= 69 && user_x_cen <= 81 && user_y_cen == 115) || // vert left wall
                       (user_x_cen >= 74 && user_x_cen <= 99 && user_y_cen == 83) || // top left wall
                       (user_x_cen >= 116 && user_x_cen <= 141 && user_y_cen == 148) || // bot right wall
                       (user_x_cen >= 134 && user_x_cen <= 146 && user_y_cen == 87) || // vert right wall
                       (user_x_cen >= 121 && user_x_cen <= 152 && user_y_cen == 68); // top right wall
    
    assign wall_right = (user_y_cen >= 116 && user_y_cen <= 157 && user_x_cen == 68) || // vert left wall
                        (user_y_cen >= 163 && user_y_cen <= 176 && user_x_cen == 62) || // bot left wall
                        (user_y_cen >= 84 && user_y_cen <= 96 && user_x_cen == 73) || // top left wall
                        (user_y_cen >= 88 && user_y_cen <= 129 && user_x_cen == 133) || // vert right wall
                        (user_y_cen >= 149 && user_y_cen <= 161 && user_x_cen == 115) || // bot right wall
                        (user_y_cen >= 69 && user_y_cen <= 82 && user_x_cen == 120); // top right wall

    assign wall_left = (user_y_cen >= 116 && user_y_cen <= 157 && user_x_cen == 82) || // vert left wall
                       (user_y_cen >= 163 && user_y_cen <= 176 && user_x_cen == 95) || // bot left wall
                       (user_y_cen >= 84 && user_y_cen <= 96 && user_x_cen == 100) || // top left wall
                       (user_y_cen >= 88 && user_y_cen <= 129 && user_x_cen == 147) || // vert right wall
                       (user_y_cen >= 149 && user_y_cen <= 161 && user_x_cen == 142) || // bot right wall
                       (user_y_cen >= 69 && user_y_cen <= 82 && user_x_cen == 153); // top right wall
                            
    // check whether user tank is right below or right above opp tank
    // check whether user tank and opp tank are on the same horizontal level i.e. abs(user x - opp x) <= 10
    assign can_up = (opp_coll_up || border_up || mid_p_up || wall_up) ? 0 : 1;
    assign can_down = (opp_coll_down || border_down || mid_p_down || wall_down) ? 0 : 1;
                    
    // check whether user tank is right beside
    // check whether user tank and opp tank are on the same vertical level i.e. abs(user y - opp y) <= 10
    assign can_right = (opp_coll_right || border_right || mid_p_right || wall_right) ? 0 : 1;
    assign can_left = (opp_coll_left || border_left || mid_p_left || wall_left) ? 0 : 1;
                        
endmodule
