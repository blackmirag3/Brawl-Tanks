`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 04:18:36 AM
// Design Name: 
// Module Name: user_bullet
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


module user_bullet (input bullet_speed, FIRE, RST, [2:0] dir, [15:0] user_pos, [15:0] opp_pos,
                    output reg [7:0] b_x_cen = 200, b_y_cen = 200,
                    output reg collided = 0, HIT = 0);

    reg [7:0] rst_x = 200, rst_y = 200;
    wire [7:0] user_x_cen, user_y_cen, opp_x_cen, opp_y_cen;
    reg has_fired = 0, firing = 0;
    
    assign user_x_cen = user_pos[7:0];
    assign user_y_cen = user_pos[15:8];
    assign opp_x_cen = opp_pos[7:0];
    assign opp_y_cen = opp_pos[15:8];
    
    wire up_hit, right_hit, down_hit, left_hit, up_right, down_right, down_left, up_left;
    wire border_up_coll, border_down_coll, border_left_coll, border_right_coll;
        
    assign up_hit = (b_y_cen - opp_y_cen <= 7) && (opp_x_cen - b_x_cen <= 6 || b_x_cen - opp_x_cen <= 6);
    assign right_hit = (opp_x_cen - b_x_cen <= 7) && (opp_y_cen - b_y_cen <= 6 || b_y_cen - opp_y_cen <= 6);
    assign down_hit = (opp_y_cen - b_y_cen <= 7) && (opp_x_cen - b_x_cen <= 6 || b_x_cen - opp_x_cen <= 6);
    assign left_hit = (b_x_cen - opp_x_cen <= 7) && (opp_y_cen - b_y_cen <= 6 || b_y_cen - opp_y_cen <= 6);
    assign up_right = up_hit || right_hit;
    assign down_right = down_hit || right_hit;
    assign down_left = down_hit || left_hit;
    assign up_left = up_hit || left_hit;
    assign border_up_coll = b_y_cen - 1 == 0;
    assign border_down_coll = b_y_cen + 1 == 63;
    assign border_left_coll = b_x_cen - 1 == 0;
    assign border_right_coll = b_x_cen + 1 == 95;
    
    always @ (posedge bullet_speed, RST)
    begin
        
        if (FIRE && has_fired == 0) begin
            has_fired <= 1;
            firing <= 1;
            
            case (dir)
                3'b000 : begin
                    b_x_cen <= user_x_cen;
                    b_y_cen <= user_y_cen - 5;
                end
                3'b001 : begin
                    b_x_cen <= user_x_cen + 5;
                    b_y_cen <= user_y_cen - 5;
                end
                3'b010 : begin
                    b_x_cen <= user_x_cen + 5;
                    b_y_cen <= user_y_cen;
                end
                3'b011 : begin
                    b_x_cen <= user_x_cen + 5;
                    b_y_cen <= user_y_cen + 5;
                end
                3'b100 : begin
                    b_x_cen <= user_x_cen;
                    b_y_cen <= user_y_cen + 5;
                end
                3'b101 : begin
                    b_x_cen <= user_x_cen - 5;
                    b_y_cen <= user_y_cen + 5;
                end
                3'b110 : begin
                    b_x_cen <= user_x_cen - 5;
                    b_y_cen <= user_y_cen;
                end
                3'b111 : begin
                    b_x_cen <= user_x_cen - 5;
                    b_y_cen <= user_y_cen - 5;
                end
            endcase
            
        end
        
        if (FIRE && firing) begin
            
            if (collided == 1) begin
                firing <= 0;
                b_x_cen <= rst_x;
                b_y_cen <= rst_y;
                collided <= 0;
                HIT <= 0;
            end
            
            if (collided == 0) begin
                case (dir)
                    3'b000 : begin
                        b_y_cen <= user_y_cen - 1;
                        
                        HIT <= up_hit;
                        collided <= up_hit || border_up_coll;
                    end
                    3'b001 : begin
                        b_x_cen <= user_x_cen + 1;
                        b_y_cen <= user_y_cen - 1;
                        
                        HIT <= up_right;
                        collided <= up_right || border_up_coll || border_right_coll;
                    end
                    3'b010 : begin
                        b_x_cen <= user_x_cen + 1;
                        
                        HIT <= right_hit;
                        collided <= right_hit || border_right_coll;
                    end
                    3'b011 : begin
                        b_x_cen <= user_x_cen + 1;
                        b_y_cen <= user_y_cen + 1;
                        
                        HIT <= down_right;
                        collided <= down_right || border_down_coll || border_right_coll;
                    end
                    3'b100 : begin
                        b_y_cen <= user_y_cen + 1;
                    
                        HIT <= down_hit;
                        collided <= down_hit || border_down_coll;
                    end
                    3'b101 : begin
                        b_x_cen <= user_x_cen - 1;
                        b_y_cen <= user_y_cen + 1;
                    
                        HIT <= down_left;
                        collided <= down_left || border_down_coll || border_left_coll;
                    end
                    3'b110 : begin
                        b_x_cen <= user_x_cen - 1;
                    
                        HIT <= left_hit;
                        collided <= left_hit || border_left_coll;
                    end
                    3'b111 : begin
                        b_x_cen <= user_x_cen - 1;
                        b_y_cen <= user_y_cen - 1;
                        
                        HIT <= up_left;
                        collided <= up_left || border_up_coll || border_left_coll;
                    end
                endcase
            end
        end
        
        // reset bullet
        if (RST) begin
            b_x_cen <= rst_x;
            b_y_cen <= rst_y;
            has_fired <= 0;
            firing <= 0;
            collided <= 0;
            HIT <= 0;
        end
    end

endmodule
