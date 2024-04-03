`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2024 01:04:04 AM
// Design Name: 
// Module Name: bullet_collision
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


module bullet_collision (input clk, moving, [2:0] dir, [15:0] opp_data, [15:0] bullet_data, output reg hit = 0, reg collided = 0);

    wire [7:0] opp_x_cen, opp_y_cen;
    assign opp_x_cen = opp_data[15:8];
    assign opp_y_cen = opp_data[7:0];

    wire [7:0] b_x_cen, b_y_cen;
    assign b_x_cen = bullet_data[15:8];
    assign b_y_cen = bullet_data[7:0];
    
    wire up_hit, right_hit, down_hit, left_hit, up_right, down_right, down_left, up_left;
    
    assign up_hit = (b_y_cen - opp_y_cen <= 7) && (opp_x_cen - b_x_cen <= 6 || b_x_cen - opp_x_cen <= 6);
    assign right_hit = (opp_x_cen - b_x_cen <= 7) && (opp_y_cen - b_y_cen <= 6 || b_y_cen - opp_y_cen <= 6);
    assign down_hit = (opp_y_cen - b_y_cen <= 7) && (opp_x_cen - b_x_cen <= 6 || b_x_cen - opp_x_cen <= 6);
    assign left_hit = (b_x_cen - opp_x_cen <= 7) && (opp_y_cen - b_y_cen <= 6 || b_y_cen - opp_y_cen <= 6);
    assign up_right = up_hit || right_hit;
    assign down_right = down_hit || right_hit;
    assign down_left = down_hit || left_hit;
    assign up_left = up_hit || left_hit;
    
    always @ (posedge clk)
    begin
        if (moving == 1) begin
            if (dir == 0) begin // up
                hit <= up_hit;
                collided <= (up_hit || (b_y_cen - 1 == 0));
            end
            if (dir == 1) begin // up-right
                hit <= up_right;
                collided <= (up_right || b_y_cen - 1 == 0 || b_x_cen + 1 == 95);
            end
            if (dir == 2) begin // right
                hit <= right_hit;
                collided <= (right_hit || b_x_cen + 1 == 95);
            end
            if (dir == 3) begin // down-right
                hit <= down_right;
                collided <= (down_right || b_y_cen + 1 == 63 || b_x_cen + 1 == 95);
            end
            if (dir == 4) begin // down
                hit <= down_hit;
                collided <= (down_hit || b_y_cen + 1 == 63);
            end
            if (dir == 5) begin // down-left
                hit <= down_left;
                collided <= (down_left || b_y_cen + 1 == 63 || b_x_cen - 1 == 0);
            end
            if (dir == 6) begin // left
                hit <= left_hit;
                collided <= (left_hit || b_x_cen - 1 == 0);
            end
            if (dir == 7) begin // up-left
                hit <= up_left;
                collided <= (up_left || b_y_cen - 1 == 0 || b_x_cen - 1 == 0);
            end
        end
        
        if (moving == 0) begin
            hit <= 0;
            collided <= 0;
        end
    end

endmodule
