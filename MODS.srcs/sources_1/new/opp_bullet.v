`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 11:25:58 PM
// Design Name: 
// Module Name: opp_bullet
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


module opp_bullet (input bullet_speed, FIRE, BREAK, RST, [2:0] dir, [15:0] opp_pos,
                   output reg [7:0] b_x_cen = 200, b_y_cen = 200);

    reg [7:0] rst_x = 200, rst_y = 200;

    wire [7:0] opp_x_cen, opp_y_cen;
    assign opp_x_cen = opp_pos[7:0];
    assign opp_y_cen = opp_pos[15:8];
    
    reg has_fired = 0, firing = 0;
    
    always @ (posedge bullet_speed, posedge RST)
    begin
    
        if (FIRE && has_fired == 0) begin
            has_fired <= 1;
            firing <= 1;
            
            case (dir)
                3'b000 : begin
                    b_x_cen <= opp_x_cen;
                    b_y_cen <= opp_y_cen - 5;
                end
                3'b001 : begin
                    b_x_cen <= opp_x_cen + 5;
                    b_y_cen <= opp_y_cen - 5;
                end
                3'b010 : begin
                    b_x_cen <= opp_x_cen + 5;
                    b_y_cen <= opp_y_cen;
                end
                3'b011 : begin
                    b_x_cen <= opp_x_cen + 5;
                    b_y_cen <= opp_y_cen + 5;
                end
                3'b100 : begin
                    b_x_cen <= opp_x_cen;
                    b_y_cen <= opp_y_cen + 5;
                end
                3'b101 : begin
                    b_x_cen <= opp_x_cen - 5;
                    b_y_cen <= opp_y_cen + 5;
                end
                3'b110 : begin
                    b_x_cen <= opp_x_cen - 5;
                    b_y_cen <= opp_y_cen;
                end
                3'b111 : begin
                    b_x_cen <= opp_x_cen - 5;
                    b_y_cen <= opp_y_cen - 5;
                end
            endcase
            
        end
        
        if (FIRE && firing) begin
            if (BREAK) begin
                b_x_cen <= rst_x;
                b_y_cen <= rst_y;
                firing <= 0;
            end
            else begin
                case (dir)
                    3'b000 : begin
                        b_y_cen <= b_y_cen - 1;
                    end
                    3'b001 : begin
                        b_x_cen <= b_x_cen + 1;
                        b_y_cen <= b_y_cen - 1;
                    end
                    3'b010 : begin
                        b_x_cen <= b_x_cen + 1;
                    end
                    3'b011 : begin
                        b_x_cen <= b_x_cen + 1;
                        b_y_cen <= b_y_cen + 1;
                    end
                    3'b100 : begin
                        b_y_cen <= b_y_cen + 1;
                    end
                    3'b101 : begin
                        b_x_cen <= b_x_cen - 1;
                        b_y_cen <= b_y_cen + 1;
                    end
                    3'b110 : begin
                        b_x_cen <= b_x_cen - 1;
                    end
                    3'b111 : begin
                        b_x_cen <= b_x_cen - 1;
                        b_y_cen <= b_y_cen - 1;
                    end
                endcase
            end
        end
        
        if (RST && has_fired) begin
            b_x_cen <= rst_x;
            b_y_cen <= rst_y;
            has_fired <= 0;
            firing <= 0;
        end
    
    end

endmodule
