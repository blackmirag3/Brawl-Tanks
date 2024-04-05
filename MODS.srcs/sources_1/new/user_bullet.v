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

    reg [7:0] rst_x = 240, rst_y = 240;
    wire [7:0] user_x_cen, user_y_cen, opp_x_cen, opp_y_cen;
    reg has_fired = 0, firing = 0;
    
    assign user_x_cen = user_pos[7:0];
    assign user_y_cen = user_pos[15:8];
    assign opp_x_cen = opp_pos[7:0];
    assign opp_y_cen = opp_pos[15:8];
    
    wire up_coll, down_coll, right_coll, left_coll;
    wire up_hit, right_hit, down_hit, left_hit, up_right, down_right, down_left, up_left;
    wire border_up_coll, border_down_coll, border_left_coll, border_right_coll;
    wire mid_pill_up, mid_pill_down, mid_pill_right, mid_pill_left;
    wire wall_up, wall_down, wall_right, wall_left;
    
    assign up_hit = (b_y_cen - opp_y_cen <= 7) && (opp_x_cen - b_x_cen <= 6 || b_x_cen - opp_x_cen <= 6);
    assign right_hit = (opp_x_cen - b_x_cen <= 7) && (opp_y_cen - b_y_cen <= 6 || b_y_cen - opp_y_cen <= 6);
    assign down_hit = (opp_y_cen - b_y_cen <= 7) && (opp_x_cen - b_x_cen <= 6 || b_x_cen - opp_x_cen <= 6);
    assign left_hit = (b_x_cen - opp_x_cen <= 7) && (opp_y_cen - b_y_cen <= 6 || b_y_cen - opp_y_cen <= 6);
    assign up_right = up_hit || right_hit;
    assign down_right = down_hit || right_hit;
    assign down_left = down_hit || left_hit;
    assign up_left = up_hit || left_hit;
    
    assign mid_pill_up = (b_x_cen >= 94 && b_x_cen < 104 && b_y_cen <= 127 && b_y_cen >= 125) ||
                         (b_x_cen > 111 && b_x_cen <= 121 && b_y_cen <= 127 && b_y_cen >= 125) ||
                         (b_x_cen >= 104 && b_x_cen <= 111 && b_y_cen <= 139 && b_y_cen >= 137);
    assign mid_pill_down = (b_x_cen >= 94 && b_x_cen < 104 && b_y_cen >= 118 && b_y_cen <= 120) ||
                           (b_x_cen > 111 && b_x_cen <= 121 && b_y_cen >= 118 && b_y_cen <= 120) ||
                           (b_x_cen >= 104 && b_x_cen <= 111 && b_y_cen >= 106 && b_y_cen <= 108);
    assign mid_pill_right = (b_y_cen >= 107 && b_y_cen < 119 && b_x_cen >= 103 && b_x_cen <= 105) ||
                            (b_y_cen > 126 && b_y_cen <= 138 && b_x_cen >= 103 && b_x_cen <= 105) ||
                            (b_y_cen >= 119 && b_y_cen <= 126 && b_x_cen >= 93 && b_x_cen <= 95);
    assign mid_pill_left = (b_y_cen >= 107 && b_y_cen < 119 && b_x_cen <= 112 && b_x_cen >= 110) ||
                           (b_y_cen > 126 && b_y_cen <= 138 && b_x_cen <= 112 && b_x_cen >= 110) ||
                           (b_y_cen >= 119 && b_y_cen <= 126 && b_x_cen <= 122 && b_x_cen >= 120);
    
    assign border_up_coll = b_y_cen - 1 <= 48;
    assign border_down_coll = b_y_cen + 1 >= 197;
    assign border_left_coll = b_x_cen - 1 <= 48;
    assign border_right_coll = b_x_cen + 1 >= 167;
    
    assign wall_up = (b_x_cen >= 67 && b_x_cen <= 90 && b_y_cen <= 173 && b_y_cen >= 171) || // bot left wall
                     (b_x_cen >= 73 && b_x_cen <= 77 && b_y_cen <= 154 && b_y_cen >= 152) || // vert left wall
                     (b_x_cen >= 78 && b_x_cen <= 95 && b_y_cen <= 93 && b_y_cen >= 91) || // top left wall
                     (b_x_cen >= 120 && b_x_cen <= 137 && b_y_cen <= 158 && b_y_cen >= 156) || // bot right wall
                     (b_x_cen >= 138 && b_x_cen <= 142 && b_y_cen <= 126 && b_y_cen >= 124) || // vert right wall
                     (b_x_cen >= 125 && b_x_cen <= 148 && b_y_cen <= 79 && b_y_cen >= 77); // top right wall
    
    assign wall_down = (b_x_cen >= 67 && b_x_cen <= 90 && b_y_cen >= 166 && b_y_cen <= 168) || // bot left wall
                       (b_x_cen >= 73 && b_x_cen <= 77 && b_y_cen >= 119 && b_y_cen <= 121) || // vert left wall
                       (b_x_cen >= 78 && b_x_cen <= 95 && b_y_cen >= 87 && b_y_cen <= 89) || // top left wall
                       (b_x_cen >= 120 && b_x_cen <= 137 && b_y_cen >= 152 && b_y_cen <= 154) || // bot right wall
                       (b_x_cen >= 138 && b_x_cen <= 142 && b_y_cen >= 91 && b_y_cen <= 93) || // vert right wall
                       (b_x_cen >= 125 && b_x_cen <= 148 && b_y_cen >= 72 && b_y_cen <= 74); // top right wall
    
    assign wall_right = (b_y_cen >= 167 && b_y_cen <= 172 && b_x_cen >= 66 && b_x_cen <= 68) || // bot left wall
                        (b_y_cen >= 120 && b_y_cen <= 153 && b_x_cen >= 72 && b_x_cen <= 74) || // vert left wall
                        (b_y_cen >= 88 && b_y_cen <= 92 && b_x_cen >= 77 && b_x_cen <= 79) || // top left wall
                        (b_y_cen >= 153 && b_y_cen <= 157 && b_x_cen >= 119 && b_x_cen <= 121) || // bot right wall
                        (b_y_cen >= 92 && b_y_cen <= 125 && b_x_cen >= 137 && b_x_cen <= 139) || // vert right wall
                        (b_y_cen >= 73 && b_y_cen <= 78 && b_x_cen >= 124 && b_x_cen <= 126); // top right wall
    
    assign wall_left = (b_y_cen >= 167 && b_y_cen <= 172 && b_x_cen <= 91 && b_x_cen >= 89) || // bot left wall
                       (b_y_cen >= 120 && b_y_cen <= 153 && b_x_cen <= 78 && b_x_cen >= 76) || // vert left wall
                       (b_y_cen >= 88 && b_y_cen <= 92 && b_x_cen <= 96 && b_x_cen >= 94) || // top left wall
                       (b_y_cen >= 153 && b_y_cen <= 157 && b_x_cen <= 138 && b_x_cen >= 136) || // bot right wall
                       (b_y_cen >= 92 && b_y_cen <= 125 && b_x_cen <= 143 && b_x_cen >= 141) || // vert right wall
                       (b_y_cen >= 73 && b_y_cen <= 78 && b_x_cen <= 149 && b_x_cen >= 147); // top right wall
    
    assign up_coll = border_up_coll || mid_pill_up || wall_up;
    assign down_coll = border_down_coll || mid_pill_down || wall_down;
    assign right_coll = border_right_coll || mid_pill_right || wall_right;
    assign left_coll = border_left_coll || mid_pill_left || wall_left;
    
    always @ (posedge bullet_speed, posedge RST)
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
                        b_y_cen <= b_y_cen - 1;
                        
                        HIT <= up_hit;
                        collided <= up_hit || up_coll;
                    end
                    3'b001 : begin
                        b_x_cen <= b_x_cen + 1;
                        b_y_cen <= b_y_cen - 1;
                        
                        HIT <= up_right;
                        collided <= up_right || up_coll || right_coll;
                    end
                    3'b010 : begin
                        b_x_cen <= b_x_cen + 1;
                        
                        HIT <= right_hit;
                        collided <= right_hit || right_coll;
                    end
                    3'b011 : begin
                        b_x_cen <= b_x_cen + 1;
                        b_y_cen <= b_y_cen + 1;
                        
                        HIT <= down_right;
                        collided <= down_right || down_coll || right_coll;
                    end
                    3'b100 : begin
                        b_y_cen <= b_y_cen + 1;
                    
                        HIT <= down_hit;
                        collided <= down_hit || down_coll;
                    end
                    3'b101 : begin
                        b_x_cen <= b_x_cen - 1;
                        b_y_cen <= b_y_cen + 1;
                    
                        HIT <= down_left;
                        collided <= down_left || down_coll || left_coll;
                    end
                    3'b110 : begin
                        b_x_cen <= b_x_cen - 1;
                    
                        HIT <= left_hit;
                        collided <= left_hit || left_coll;
                    end
                    3'b111 : begin
                        b_x_cen <= b_x_cen - 1;
                        b_y_cen <= b_y_cen - 1;
                        
                        HIT <= up_left;
                        collided <= up_left || up_coll || left_coll;
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
