`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2024 10:12:48 PM
// Design Name: 
// Module Name: temp_cam
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


module temp_cam(input clk, input [12:0] x, y, input [7:0] user_x, user_y, enemy_x, enemy_y,
                input [2:0] user_dir, opp_dir, input [39:0] b_x_cen, b_y_cen, ob_x_cen, ob_y_cen,
                output reg [15:0] camera = 0);
                
    //Movement module to:
    //  1. constraint players coords INSIDE map boundary - 0 < x < 100, 0 < y < 150 (cannot be on map edge)
    //  2. prevent players coords from being inside pillar area
    //      > to consider tank width
    //          if tank is 3 pixels wide and player_x = 1, then render tank on top of map border at x = 0, since tank covers x = 0 to 2 wide.
    //          if tank is 3 pixels wide, then | player_x - pillar_x | at least 1, otherwise overlap...
    
    //Map is 100 * 150 pixels,
    //Initialise coords of map elements
    
    reg [7:0] border_x; //bottom left corner of map border. Border == 100 * 150
    reg [7:0] border_y;
    reg signed [15:0] border_x1_rel; //relative coord W.R.T camera coord
    reg signed [15:0] border_y1_rel;
    reg signed [15:0] border_x2_rel; //relative coord W.R.T camera coord
    reg signed [15:0] border_y2_rel;
    
    reg [7:0] pillar_x; //bottom left corner of pillar. Pillar == 40 * 40
    reg [7:0] pillar_y;
    reg signed [15:0] pillar_x1_rel;
    reg signed [15:0] pillar_y1_rel;
    reg signed [15:0] pillar_x2_rel;
    reg signed [15:0] pillar_y2_rel;
    
    reg [7:0] opp_x_cen;
    reg [7:0] opp_y_cen;
    reg [7:0] user_x_cen;
    reg [7:0] user_y_cen;
    
    //OLED display maintain center point on camera coords
    //Camera coords to fix 20 pixels above tank coords.
    //Map display area is 96x64 (same size as OLED)
    //default 2d FOV of 96x74 (OLED)
    //
    //Initialise camera coords and map display area
    
    reg [7:0] camera_x;
    reg [7:0] camera_y;
    
    //Initialise starting positions of map elements
    initial begin
        user_x_cen = 48;
        user_y_cen = 48;
        border_x = 0; //left side
        border_y = 0; //top sidde
        pillar_x = 35; //left side
        pillar_y = 60; //top side
    end
                
    reg [15:0] box_colour = 0;     
    reg [15:0] green_c = 16'b00000_111111_00000; 
    reg [15:0] red_c = 16'b11111_000000_00000; 
    reg [15:0] blue_c = 16'b00000_000000_11111;
    reg [15:0] purple_c = 16'b11111_000000_11111;
    reg [15:0] white_c = 16'b11111_111111_11111;
    reg [15:0] yellow_c = 16'b11111_111111_00000;
    
    reg [15:0] user_col = 0, opp_col = 0;
    reg has_user = 0, has_opp = 0;
    
    wire [7:0] user_x0, user_x1, user_x2, user_x3, user_x4;
    wire [7:0] opp_x0, opp_x1, opp_x2, opp_x3, opp_x4;
    wire [7:0] user_y0, user_y1, user_y2, user_y3, user_y4;
    wire [7:0] opp_y0, opp_y1, opp_y2, opp_y3, opp_y4;
    
    assign {user_x0, user_x1, user_x2, user_x3, user_x4} = b_x_cen;
    assign {opp_x0, opp_x1, opp_x2, opp_x3, opp_x4} = ob_x_cen;
    assign {user_y0, user_y1, user_y2, user_y3, user_y4} = b_y_cen;
    assign {opp_y0, opp_y1, opp_y2, opp_y3, opp_y4} = ob_y_cen;
//    assign user_x0 = b_x_cen[7:0];
//    assign user_x1 = b_x_cen[15:8];
//    assign user_x2 = b_x_cen[23:16];
//    assign user_x3 = b_x_cen[31:24];
//    assign user_x4 = b_x_cen[39:32];
    
//    assign user_y0 = b_y_cen[7:0];
//    assign user_y1 = b_y_cen[15:8];
//    assign user_y2 = b_y_cen[23:16];
//    assign user_y3 = b_y_cen[31:24];
//    assign user_y4 = b_y_cen[39:32];
    
//    assign opp_x0 = ob_x_cen[7:0];
//    assign opp_x1 = ob_x_cen[15:8];
//    assign opp_x2 = ob_x_cen[23:16];
//    assign opp_x3 = ob_x_cen[31:24];
//    assign opp_x4 = ob_x_cen[39:32];
    
//    assign opp_y0 = ob_y_cen[7:0];
//    assign opp_y1 = ob_y_cen[15:8];
//    assign opp_y2 = ob_y_cen[23:16];
//    assign opp_y3 = ob_y_cen[31:24];
//    assign opp_y4 = ob_y_cen[39:32];
    
    // bullets
    wire user_bullets, opp_bullets;
    
    assign user_bullets = (x >= user_x0 - 1 && x <= user_x0 + 1 && y >= user_y0 - 1 && y <= user_y0 + 1) ||
                          (x >= user_x1 - 1 && x <= user_x1 + 1 && y >= user_y1 - 1 && y <= user_y1 + 1) ||
                          (x >= user_x2 - 1 && x <= user_x2 + 1 && y >= user_y2 - 1 && y <= user_y2 + 1) ||
                          (x >= user_x3 - 1 && x <= user_x3 + 1 && y >= user_y3 - 1 && y <= user_y3 + 1) ||
                          (x >= user_x4 - 1 && x <= user_x4 + 1 && y >= user_y4 - 1 && y <= user_y4 + 1);
    
    assign opp_bullets = (x >= opp_x0 - 1 && x <= opp_x0 + 1 && y >= opp_y0 - 1 && y <= opp_y0 + 1) ||
                         (x >= opp_x1 - 1 && x <= opp_x1 + 1 && y >= opp_y1 - 1 && y <= opp_y1 + 1) ||
                         (x >= opp_x2 - 1 && x <= opp_x2 + 1 && y >= opp_y2 - 1 && y <= opp_y2 + 1) ||
                         (x >= opp_x3 - 1 && x <= opp_x3 + 1 && y >= opp_y3 - 1 && y <= opp_y3 + 1) ||
                         (x >= opp_x4 - 1 && x <= opp_x4 + 1 && y >= opp_y4 - 1 && y <= opp_y4 + 1);

    // user tank colours
    wire user_front_red, user_front_blue, user_front_white;
        
    assign user_front_red = (x >= user_x_cen - 1 && x <= user_x_cen + 1 && y >= user_y_cen - 3 && y <= user_y_cen - 1) || //1
                            (((x == user_x_cen + 2) || (x == user_x_cen - 2)) && (y == user_y_cen)) ||
                            ((y == user_y_cen + 1) && (x <= user_x_cen - 1) && (x >= user_x_cen - 2)) ||
                            ((y == user_y_cen + 1) && (x >= user_x_cen + 1) && (x <= user_x_cen + 2)) ||
                            ((y == user_y_cen + 2) && (x <= user_x_cen + 1) && (x >= user_x_cen - 1));
                            
    assign user_front_blue = ((y == user_y_cen - 1) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) || //0
                             ((y == user_y_cen - 1) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                             ((y == user_y_cen) && ((x == user_x_cen - 3) || (x == user_x_cen + 3))) ||
                             ((y == user_y_cen + 2) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                             ((y == user_y_cen + 2) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                             ((y == user_y_cen + 3) && (x <= user_x_cen + 3) && (x >= user_x_cen - 3)) ||
                             ((y >= user_y_cen) && (y <= user_y_cen + 1) && (x <= user_x_cen + 1) && (x >= user_x_cen - 1)); // u
    
    assign user_front_white = ((y >= user_y_cen - 2) && (y <= user_y_cen + 3) && 
                              ((x <= user_x_cen + 5 && x >= user_x_cen + 4) || (x >= user_x_cen - 5 && x <= user_x_cen - 4)));
    
    wire user_fr_red, user_fr_blue, user_fr_white;
    
    assign user_fr_red = ((y == user_y_cen - 3) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                         ((y == user_y_cen - 2) && (x >= user_x_cen) && (x <= user_x_cen + 3)) ||
                         ((y == user_y_cen - 1) && (x >= user_x_cen + 1) && (x <= user_x_cen + 2)) ||
                         ((y == user_y_cen) && ((x == user_x_cen + 2) || (x == user_x_cen - 2))) ||
                         ((y == user_y_cen + 1) && (x == user_x_cen - 2))||
                         ((y == user_y_cen + 2) && (x >= user_x_cen - 2) && (x <= user_x_cen));
    
    assign user_fr_blue = ((y == user_y_cen - 3) && (x == user_x_cen - 1)) || //0
                          ((y == user_y_cen - 2) && (x >= user_x_cen - 2) && (x <= user_x_cen - 1)) ||
                          ((y == user_y_cen - 1) && (x >= user_x_cen - 3) && (x <= user_x_cen - 2)) ||
                          ((y == user_y_cen) && (x >= user_x_cen - 4) && (x <= user_x_cen - 3)) ||
                          ((y == user_y_cen + 1) && (x == user_x_cen - 3)) ||
                          ((y == user_y_cen + 1) && (x >= user_x_cen + 2) && (x <= user_x_cen + 3)) ||
                          ((y == user_y_cen + 2) && (x >= user_x_cen + 1) && (x <= user_x_cen + 2)) ||
                          ((y == user_y_cen + 3) && (x >= user_x_cen - 1) && (x <= user_x_cen + 1)) ||
                          ((y == user_y_cen + 4) && (x == user_x_cen)) ||
                          ((y <= user_y_cen + 1) && (y >= user_y_cen - 1) && (x >= user_x_cen - 1) && (x <= user_x_cen)) || //u
                          ((y <= user_y_cen + 1) && (y >= user_y_cen) && (x == user_x_cen + 1));
    
    assign user_fr_white = ((y == user_y_cen - 4) && (x <= user_x_cen - 1) && (x >= user_x_cen - 2)) || //n
                           ((y == user_y_cen - 3) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                           ((y == user_y_cen - 2) && (x <= user_x_cen - 3) && (x >= user_x_cen - 4)) ||
                           ((y == user_y_cen - 1) && (x <= user_x_cen - 4) && (x >= user_x_cen - 5)) ||
                           ((y == user_y_cen) && (x == user_x_cen - 5)) ||
                           ((y == user_y_cen + 1) && (x == user_x_cen + 4)) ||
                           ((y == user_y_cen + 2) && (x <= user_x_cen + 4) && (x >= user_x_cen + 3)) ||
                           ((y == user_y_cen + 3) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                           ((y == user_y_cen + 4) && (x <= user_x_cen + 2) && (x >= user_x_cen + 1)) ||
                           ((y == user_y_cen + 4) && (x >= user_x_cen) && (x <= user_x_cen + 1));
    
    wire user_r_red, user_r_blue, user_r_white;
    
    assign user_r_red = (x >= user_x_cen + 1 && x <= user_x_cen + 3 && y <= user_y_cen + 1 && y >= user_y_cen - 1) || //1
                        ((x == user_x_cen - 2) && (y <= user_y_cen + 1) && (y >= user_y_cen - 1)) ||
                        ((y == user_y_cen - 2) && (x <= user_x_cen) && (x >= user_x_cen - 1)) ||
                        ((y == user_y_cen - 3) && (x == user_x_cen - 1)) ||
                        ((y == user_y_cen + 2) && (x <= user_x_cen) && (x >= user_x_cen - 1)) ||
                        ((y == user_y_cen + 3) && (x == user_x_cen - 1));

    assign user_r_blue = ((x == user_x_cen - 3) && (y >= user_y_cen - 3) && (y <= user_y_cen + 3)) || //0
                         ((x == user_x_cen - 2) && (y <= user_y_cen - 2) && (y >= user_y_cen - 3)) ||
                         ((x == user_x_cen - 2) && (y <= user_y_cen + 3) && (y >= user_y_cen + 2)) ||
                         ((x == user_x_cen) && (y == user_y_cen - 3)) ||
                         ((x == user_x_cen) && (y == user_y_cen + 3)) ||
                         ((x == user_x_cen + 1) && (y <= user_y_cen - 2) && (y >= user_y_cen - 3)) ||
                         ((x == user_x_cen + 1) && (y <= user_y_cen + 3) && (y >= user_y_cen + 2)) ||
                         ((y <= user_y_cen + 1) && (y >= user_y_cen - 1) && (x <= user_x_cen) && (x >= user_x_cen - 1));

    assign user_r_white = ((x <= user_x_cen + 2) && (x >= user_x_cen - 3) && (y <= user_y_cen + 5) && (y >= user_y_cen + 4)) ||
                          ((x <= user_x_cen + 2) && (x >= user_x_cen - 3) && (y >= user_y_cen - 5) && (y <= user_y_cen - 4));

    wire user_dr_red, user_dr_blue, user_dr_white;
    
    assign user_dr_red = ((y == user_y_cen + 3) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                         ((y == user_y_cen + 2) && (x >= user_x_cen) && (x <= user_x_cen + 3)) ||
                         ((y == user_y_cen + 1) && (x >= user_x_cen + 1) && (x <= user_x_cen + 2)) ||
                         ((y == user_y_cen) && ((x == user_x_cen + 2) || (x == user_x_cen - 2))) ||
                         ((y == user_y_cen - 1) && (x == user_x_cen - 2))||
                         ((y == user_y_cen - 2) && (x >= user_x_cen - 2) && (x <= user_x_cen));

    assign user_dr_blue = ((y == user_y_cen + 3) && (x == user_x_cen - 1)) || //0
                          ((y == user_y_cen + 2) && (x >= user_x_cen - 2) && (x <= user_x_cen - 1)) ||
                          ((y == user_y_cen + 1) && (x >= user_x_cen - 3) && (x <= user_x_cen - 2)) ||
                          ((y == user_y_cen) && (x >= user_x_cen - 4) && (x <= user_x_cen - 3)) ||
                          ((y == user_y_cen - 1) && (x == user_x_cen - 3)) ||
                          ((y == user_y_cen - 1) && (x >= user_x_cen + 2) && (x <= user_x_cen + 3)) ||
                          ((y == user_y_cen - 2) && (x >= user_x_cen + 1) && (x <= user_x_cen + 2)) ||
                          ((y == user_y_cen - 3) && (x >= user_x_cen - 1) && (x <= user_x_cen + 1)) ||
                          ((y == user_y_cen - 4) && (x == user_x_cen)) ||
                          ((y <= user_y_cen + 1) && (y >= user_y_cen - 1) && (x >= user_x_cen - 1) && (x <= user_x_cen)) || //u
                          ((y >= user_y_cen - 1) && (y <= user_y_cen) && (x == user_x_cen + 1));

    assign user_dr_white = ((y == user_y_cen + 4) && (x <= user_x_cen - 1) && (x >= user_x_cen - 2)) || //n
                           ((y == user_y_cen + 3) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                           ((y == user_y_cen + 2) && (x <= user_x_cen - 3) && (x >= user_x_cen - 4)) ||
                           ((y == user_y_cen + 1) && (x <= user_x_cen - 4) && (x >= user_x_cen - 5)) ||
                           ((y == user_y_cen) && (x == user_x_cen - 5)) ||
                           ((y == user_y_cen - 1) && (x == user_x_cen + 4)) ||
                           ((y == user_y_cen - 2) && (x <= user_x_cen + 4) && (x >= user_x_cen + 3)) ||
                           ((y == user_y_cen - 3) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                           ((y == user_y_cen - 4) && (x <= user_x_cen + 2) && (x >= user_x_cen + 1)) ||
                           ((y == user_y_cen - 4) && (x >= user_x_cen) && (x <= user_x_cen + 1));

    wire user_d_red, user_d_blue, user_d_white;
    
    assign user_d_red = (x >= user_x_cen - 1 && x <= user_x_cen + 1 && y <= user_y_cen + 3 && y >= user_y_cen + 1) || //1
                        (((x == user_x_cen + 2) || (x == user_x_cen - 2)) && (y == user_y_cen)) ||
                        ((y == user_y_cen - 1) && (x <= user_x_cen - 1) && (x >= user_x_cen - 2)) ||
                        ((y == user_y_cen - 1) && (x >= user_x_cen + 1) && (x <= user_x_cen + 2)) ||
                        ((y == user_y_cen - 2) && (x <= user_x_cen + 1) && (x >= user_x_cen - 1));

    assign user_d_blue = ((y == user_y_cen + 1) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) || //0
                         ((y == user_y_cen + 1) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                         ((y == user_y_cen) && ((x == user_x_cen - 3) || (x == user_x_cen + 3))) ||
                         ((y == user_y_cen - 2) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                         ((y == user_y_cen - 2) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                         ((y == user_y_cen - 3) && (x <= user_x_cen + 3) && (x >= user_x_cen - 3)) ||
                         (y <= user_y_cen) && (y >= user_y_cen - 1) && (x <= user_x_cen + 1) && (x >= user_x_cen - 1);

    assign user_d_white = ((y <= user_y_cen + 2) && (y >= user_y_cen - 3) && (x <= user_x_cen + 5) && (x >= user_x_cen + 4)) ||
                          ((y <= user_y_cen + 2) && (y >= user_y_cen - 3) && (x >= user_x_cen - 5) && (x <= user_x_cen - 4));

    wire user_dl_red, user_dl_blue, user_dl_white;
    
    assign user_dl_red = ((y == user_y_cen + 3) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                         ((y == user_y_cen + 2) && (x <= user_x_cen) && (x >= user_x_cen - 3)) ||
                         ((y == user_y_cen + 1) && (x <= user_x_cen -1) && (x >= user_x_cen - 2)) ||
                         ((y == user_y_cen) && ((x == user_x_cen - 2) || (x == user_x_cen + 2))) ||
                         ((y == user_y_cen - 1) && (x == user_x_cen + 2))||
                         ((y == user_y_cen - 2) && (x <= user_x_cen + 2) && (x >= user_x_cen));
                        
    assign user_dl_blue = ((y == user_y_cen + 3) && (x == user_x_cen + 1)) || //0
                          ((y == user_y_cen + 2) && (x <= user_x_cen + 2) && (x >= user_x_cen + 1)) ||
                          ((y == user_y_cen + 1) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                          ((y == user_y_cen) && (x <= user_x_cen + 4) && (x >= user_x_cen + 3)) ||
                          ((y == user_y_cen - 1) && (x == user_x_cen + 3)) ||
                          ((y == user_y_cen - 1) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                          ((y == user_y_cen - 2) && (x <= user_x_cen - 1) && (x >= user_x_cen - 2)) ||
                          ((y == user_y_cen - 3) && (x <= user_x_cen + 1) && (x >= user_x_cen - 1)) ||
                          ((y == user_y_cen - 4) && (x == user_x_cen)) ||
                          ((y <= user_y_cen + 1) && (y >= user_y_cen - 1) && (x <= user_x_cen + 1) && (x >= user_x_cen)) || //u
                          ((y >= user_y_cen - 1) && (y <= user_y_cen) && (x == user_x_cen -1));

    assign user_dl_white = ((y == user_y_cen + 4) && (x <= user_x_cen + 2) && (x >= user_x_cen + 1)) || //n
                           ((y == user_y_cen + 3) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                           ((y == user_y_cen + 2) && (x <= user_x_cen + 4) && (x >= user_x_cen + 3)) ||
                           ((y == user_y_cen + 1) && (x <= user_x_cen + 5) && (x >= user_x_cen + 4)) ||
                           ((y == user_y_cen) && (x == user_x_cen + 5)) ||
                           ((y == user_y_cen - 1) && (x == user_x_cen - 4)) ||
                           ((y == user_y_cen - 2) && (x <= user_x_cen - 3) && (x >= user_x_cen - 4)) ||
                           ((y == user_y_cen - 3) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                           ((y == user_y_cen - 4) && (x <= user_x_cen - 1) && (x >= user_x_cen - 2)) ||
                           ((y == user_y_cen - 4) && (x <= user_x_cen) && (x >= user_x_cen - 1));

    wire user_l_red, user_l_blue, user_l_white;
    
    assign user_l_red = (x <= user_x_cen - 1 && x >= user_x_cen - 3 && y <= user_y_cen + 1 && y >= user_y_cen - 1) || //1
                        ((x == user_x_cen + 2) && (y <= user_y_cen + 1) && (y >= user_y_cen - 1)) ||
                        ((y == user_y_cen - 2) && (x >= user_x_cen) && (x <= user_x_cen + 1)) ||
                        ((y == user_y_cen - 3) && (x == user_x_cen + 1)) ||
                        ((y == user_y_cen + 2) && (x >= user_x_cen) && (x <= user_x_cen + 1)) ||
                        ((y == user_y_cen + 3) && (x == user_x_cen + 1));

    assign user_l_blue = ((x == user_x_cen + 3) && (y >= user_y_cen - 3) && (y <= user_y_cen + 3)) || //0
                         ((x == user_x_cen + 2) && (y <= user_y_cen - 2) && (y >= user_y_cen - 3)) ||
                         ((x == user_x_cen + 2) && (y <= user_y_cen + 3) && (y >= user_y_cen + 2)) ||
                         ((x == user_x_cen) && (y == user_y_cen - 3)) ||
                         ((x == user_x_cen) && (y == user_y_cen + 3)) ||
                         ((x == user_x_cen - 1) && (y <= user_y_cen - 2) && (y >= user_y_cen - 3)) ||
                         ((x == user_x_cen - 1) && (y <= user_y_cen + 3) && (y >= user_y_cen + 2)) ||
                         ((y <= user_y_cen + 1) && (y >= user_y_cen - 1) && (x <= user_x_cen + 1) && (x >= user_x_cen));
                         
     assign user_l_white = ((x <= user_x_cen + 3) && (x >= user_x_cen - 2) && (y <= user_y_cen + 5) && (y >= user_y_cen + 4)) ||
                           ((x <= user_x_cen + 3) && (x >= user_x_cen - 2) && (y >= user_y_cen - 5) && (y <= user_y_cen - 4));

    wire user_fl_red, user_fl_blue, user_fl_white;
    
    assign user_fl_red = ((y == user_y_cen - 3) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                         ((y == user_y_cen - 2) && (x <= user_x_cen) && (x >= user_x_cen - 3)) ||
                         ((y == user_y_cen - 1) && (x <= user_x_cen -1) && (x >= user_x_cen - 2)) ||
                         ((y == user_y_cen) && ((x == user_x_cen - 2) || (x == user_x_cen + 2))) ||
                         ((y == user_y_cen + 1) && (x == user_x_cen + 2))||
                         ((y == user_y_cen + 2) && (x <= user_x_cen + 2) && (x >= user_x_cen));

    assign user_fl_blue = ((y == user_y_cen - 3) && (x == user_x_cen + 1)) || //0
                          ((y == user_y_cen - 2) && (x <= user_x_cen + 2) && (x >= user_x_cen + 1)) ||
                          ((y == user_y_cen - 1) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                          ((y == user_y_cen) && (x <= user_x_cen + 4) && (x >= user_x_cen + 3)) ||
                          ((y == user_y_cen + 1) && (x == user_x_cen + 3)) ||
                          ((y == user_y_cen + 1) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                          ((y == user_y_cen + 2) && (x <= user_x_cen - 1) && (x >= user_x_cen - 2)) ||
                          ((y == user_y_cen + 3) && (x <= user_x_cen + 1) && (x >= user_x_cen - 1)) ||
                          ((y == user_y_cen + 4) && (x == user_x_cen)) ||
                          ((y <= user_y_cen + 1) && (y >= user_y_cen - 1) && (x <= user_x_cen + 1) && (x >= user_x_cen)) || //u
                          ((y <= user_y_cen + 1) && (y >= user_y_cen) && (x == user_x_cen -1));

    assign user_fl_white = ((y == user_y_cen - 4) && (x <= user_x_cen + 2) && (x >= user_x_cen + 1)) || //n
                           ((y == user_y_cen - 3) && (x <= user_x_cen + 3) && (x >= user_x_cen + 2)) ||
                           ((y == user_y_cen - 2) && (x <= user_x_cen + 4) && (x >= user_x_cen + 3)) ||
                           ((y == user_y_cen - 1) && (x <= user_x_cen + 5) && (x >= user_x_cen + 4)) ||
                           ((y == user_y_cen) && (x == user_x_cen + 5)) ||
                           ((y == user_y_cen + 1) && (x == user_x_cen - 4)) ||
                           ((y == user_y_cen + 2) && (x <= user_x_cen - 3) && (x >= user_x_cen - 4)) ||
                           ((y == user_y_cen + 3) && (x <= user_x_cen - 2) && (x >= user_x_cen - 3)) ||
                           ((y == user_y_cen + 4) && (x <= user_x_cen - 1) && (x >= user_x_cen - 2)) ||
                           ((y == user_y_cen + 4) && (x <= user_x_cen) && (x >= user_x_cen - 1));

    // opp tank colours
    wire opp_front_red, opp_front_blue, opp_front_white;
        
    assign opp_front_red = (x >= opp_x_cen - 1 && x <= opp_x_cen + 1 && y >= opp_y_cen - 3 && y <= opp_y_cen - 1) || //1
                            (((x == opp_x_cen + 2) || (x == opp_x_cen - 2)) && (y == opp_y_cen)) ||
                            ((y == opp_y_cen + 1) && (x <= opp_x_cen - 1) && (x >= opp_x_cen - 2)) ||
                            ((y == opp_y_cen + 1) && (x >= opp_x_cen + 1) && (x <= opp_x_cen + 2)) ||
                            ((y == opp_y_cen + 2) && (x <= opp_x_cen + 1) && (x >= opp_x_cen - 1));
                            
    assign opp_front_blue = ((y == opp_y_cen - 1) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) || //0
                             ((y == opp_y_cen - 1) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                             ((y == opp_y_cen) && ((x == opp_x_cen - 3) || (x == opp_x_cen + 3))) ||
                             ((y == opp_y_cen + 2) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                             ((y == opp_y_cen + 2) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                             ((y == opp_y_cen + 3) && (x <= opp_x_cen + 3) && (x >= opp_x_cen - 3)) ||
                             ((y >= opp_y_cen) && (y <= opp_y_cen + 1) && (x <= opp_x_cen + 1) && (x >= opp_x_cen - 1)); // u
    
    assign opp_front_white = ((y >= opp_y_cen - 2) && (y <= opp_y_cen + 3) && 
                              ((x <= opp_x_cen + 5 && x >= opp_x_cen + 4) || (x >= opp_x_cen - 5 && x <= opp_x_cen - 4)));
    
    wire opp_fr_red, opp_fr_blue, opp_fr_white;
    
    assign opp_fr_red = ((y == opp_y_cen - 3) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                         ((y == opp_y_cen - 2) && (x >= opp_x_cen) && (x <= opp_x_cen + 3)) ||
                         ((y == opp_y_cen - 1) && (x >= opp_x_cen + 1) && (x <= opp_x_cen + 2)) ||
                         ((y == opp_y_cen) && ((x == opp_x_cen + 2) || (x == opp_x_cen - 2))) ||
                         ((y == opp_y_cen + 1) && (x == opp_x_cen - 2))||
                         ((y == opp_y_cen + 2) && (x >= opp_x_cen - 2) && (x <= opp_x_cen));
    
    assign opp_fr_blue = ((y == opp_y_cen - 3) && (x == opp_x_cen - 1)) || //0
                          ((y == opp_y_cen - 2) && (x >= opp_x_cen - 2) && (x <= opp_x_cen - 1)) ||
                          ((y == opp_y_cen - 1) && (x >= opp_x_cen - 3) && (x <= opp_x_cen - 2)) ||
                          ((y == opp_y_cen) && (x >= opp_x_cen - 4) && (x <= opp_x_cen - 3)) ||
                          ((y == opp_y_cen + 1) && (x == opp_x_cen - 3)) ||
                          ((y == opp_y_cen + 1) && (x >= opp_x_cen + 2) && (x <= opp_x_cen + 3)) ||
                          ((y == opp_y_cen + 2) && (x >= opp_x_cen + 1) && (x <= opp_x_cen + 2)) ||
                          ((y == opp_y_cen + 3) && (x >= opp_x_cen - 1) && (x <= opp_x_cen + 1)) ||
                          ((y == opp_y_cen + 4) && (x == opp_x_cen)) ||
                          ((y <= opp_y_cen + 1) && (y >= opp_y_cen - 1) && (x >= opp_x_cen - 1) && (x <= opp_x_cen)) || //u
                          ((y <= opp_y_cen + 1) && (y >= opp_y_cen) && (x == opp_x_cen + 1));
    
    assign opp_fr_white = ((y == opp_y_cen - 4) && (x <= opp_x_cen - 1) && (x >= opp_x_cen - 2)) || //n
                           ((y == opp_y_cen - 3) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                           ((y == opp_y_cen - 2) && (x <= opp_x_cen - 3) && (x >= opp_x_cen - 4)) ||
                           ((y == opp_y_cen - 1) && (x <= opp_x_cen - 4) && (x >= opp_x_cen - 5)) ||
                           ((y == opp_y_cen) && (x == opp_x_cen - 5)) ||
                           ((y == opp_y_cen + 1) && (x == opp_x_cen + 4)) ||
                           ((y == opp_y_cen + 2) && (x <= opp_x_cen + 4) && (x >= opp_x_cen + 3)) ||
                           ((y == opp_y_cen + 3) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                           ((y == opp_y_cen + 4) && (x <= opp_x_cen + 2) && (x >= opp_x_cen + 1)) ||
                           ((y == opp_y_cen + 4) && (x >= opp_x_cen) && (x <= opp_x_cen + 1));
    
    wire opp_r_red, opp_r_blue, opp_r_white;
    
    assign opp_r_red = (x >= opp_x_cen + 1 && x <= opp_x_cen + 3 && y <= opp_y_cen + 1 && y >= opp_y_cen - 1) || //1
                        ((x == opp_x_cen - 2) && (y <= opp_y_cen + 1) && (y >= opp_y_cen - 1)) ||
                        ((y == opp_y_cen - 2) && (x <= opp_x_cen) && (x >= opp_x_cen - 1)) ||
                        ((y == opp_y_cen - 3) && (x == opp_x_cen - 1)) ||
                        ((y == opp_y_cen + 2) && (x <= opp_x_cen) && (x >= opp_x_cen - 1)) ||
                        ((y == opp_y_cen + 3) && (x == opp_x_cen - 1));

    assign opp_r_blue = ((x == opp_x_cen - 3) && (y >= opp_y_cen - 3) && (y <= opp_y_cen + 3)) || //0
                         ((x == opp_x_cen - 2) && (y <= opp_y_cen - 2) && (y >= opp_y_cen - 3)) ||
                         ((x == opp_x_cen - 2) && (y <= opp_y_cen + 3) && (y >= opp_y_cen + 2)) ||
                         ((x == opp_x_cen) && (y == opp_y_cen - 3)) ||
                         ((x == opp_x_cen) && (y == opp_y_cen + 3)) ||
                         ((x == opp_x_cen + 1) && (y <= opp_y_cen - 2) && (y >= opp_y_cen - 3)) ||
                         ((x == opp_x_cen + 1) && (y <= opp_y_cen + 3) && (y >= opp_y_cen + 2)) ||
                         ((y <= opp_y_cen + 1) && (y >= opp_y_cen - 1) && (x <= opp_x_cen) && (x >= opp_x_cen - 1));

    assign opp_r_white = ((x <= opp_x_cen + 2) && (x >= opp_x_cen - 3) && (y <= opp_y_cen + 5) && (y >= opp_y_cen + 4)) ||
                          ((x <= opp_x_cen + 2) && (x >= opp_x_cen - 3) && (y >= opp_y_cen - 5) && (y <= opp_y_cen - 4));

    wire opp_dr_red, opp_dr_blue, opp_dr_white;
    
    assign opp_dr_red = ((y == opp_y_cen + 3) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                         ((y == opp_y_cen + 2) && (x >= opp_x_cen) && (x <= opp_x_cen + 3)) ||
                         ((y == opp_y_cen + 1) && (x >= opp_x_cen + 1) && (x <= opp_x_cen + 2)) ||
                         ((y == opp_y_cen) && ((x == opp_x_cen + 2) || (x == opp_x_cen - 2))) ||
                         ((y == opp_y_cen - 1) && (x == opp_x_cen - 2))||
                         ((y == opp_y_cen - 2) && (x >= opp_x_cen - 2) && (x <= opp_x_cen));

    assign opp_dr_blue = ((y == opp_y_cen + 3) && (x == opp_x_cen - 1)) || //0
                          ((y == opp_y_cen + 2) && (x >= opp_x_cen - 2) && (x <= opp_x_cen - 1)) ||
                          ((y == opp_y_cen + 1) && (x >= opp_x_cen - 3) && (x <= opp_x_cen - 2)) ||
                          ((y == opp_y_cen) && (x >= opp_x_cen - 4) && (x <= opp_x_cen - 3)) ||
                          ((y == opp_y_cen - 1) && (x == opp_x_cen - 3)) ||
                          ((y == opp_y_cen - 1) && (x >= opp_x_cen + 2) && (x <= opp_x_cen + 3)) ||
                          ((y == opp_y_cen - 2) && (x >= opp_x_cen + 1) && (x <= opp_x_cen + 2)) ||
                          ((y == opp_y_cen - 3) && (x >= opp_x_cen - 1) && (x <= opp_x_cen + 1)) ||
                          ((y == opp_y_cen - 4) && (x == opp_x_cen)) ||
                          ((y <= opp_y_cen + 1) && (y >= opp_y_cen - 1) && (x >= opp_x_cen - 1) && (x <= opp_x_cen)) || //u
                          ((y >= opp_y_cen - 1) && (y <= opp_y_cen) && (x == opp_x_cen + 1));

    assign opp_dr_white = ((y == opp_y_cen + 4) && (x <= opp_x_cen - 1) && (x >= opp_x_cen - 2)) || //n
                           ((y == opp_y_cen + 3) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                           ((y == opp_y_cen + 2) && (x <= opp_x_cen - 3) && (x >= opp_x_cen - 4)) ||
                           ((y == opp_y_cen + 1) && (x <= opp_x_cen - 4) && (x >= opp_x_cen - 5)) ||
                           ((y == opp_y_cen) && (x == opp_x_cen - 5)) ||
                           ((y == opp_y_cen - 1) && (x == opp_x_cen + 4)) ||
                           ((y == opp_y_cen - 2) && (x <= opp_x_cen + 4) && (x >= opp_x_cen + 3)) ||
                           ((y == opp_y_cen - 3) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                           ((y == opp_y_cen - 4) && (x <= opp_x_cen + 2) && (x >= opp_x_cen + 1)) ||
                           ((y == opp_y_cen - 4) && (x >= opp_x_cen) && (x <= opp_x_cen + 1));

    wire opp_d_red, opp_d_blue, opp_d_white;
    
    assign opp_d_red = (x >= opp_x_cen - 1 && x <= opp_x_cen + 1 && y <= opp_y_cen + 3 && y >= opp_y_cen + 1) || //1
                        (((x == opp_x_cen + 2) || (x == opp_x_cen - 2)) && (y == opp_y_cen)) ||
                        ((y == opp_y_cen - 1) && (x <= opp_x_cen - 1) && (x >= opp_x_cen - 2)) ||
                        ((y == opp_y_cen - 1) && (x >= opp_x_cen + 1) && (x <= opp_x_cen + 2)) ||
                        ((y == opp_y_cen - 2) && (x <= opp_x_cen + 1) && (x >= opp_x_cen - 1));

    assign opp_d_blue = ((y == opp_y_cen + 1) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) || //0
                         ((y == opp_y_cen + 1) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                         ((y == opp_y_cen) && ((x == opp_x_cen - 3) || (x == opp_x_cen + 3))) ||
                         ((y == opp_y_cen - 2) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                         ((y == opp_y_cen - 2) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                         ((y == opp_y_cen - 3) && (x <= opp_x_cen + 3) && (x >= opp_x_cen - 3)) ||
                         (y <= opp_y_cen) && (y >= opp_y_cen - 1) && (x <= opp_x_cen + 1) && (x >= opp_x_cen - 1);

    assign opp_d_white = ((y <= opp_y_cen + 2) && (y >= opp_y_cen - 3) && (x <= opp_x_cen + 5) && (x >= opp_x_cen + 4)) ||
                          ((y <= opp_y_cen + 2) && (y >= opp_y_cen - 3) && (x >= opp_x_cen - 5) && (x <= opp_x_cen - 4));

    wire opp_dl_red, opp_dl_blue, opp_dl_white;
    
    assign opp_dl_red = ((y == opp_y_cen + 3) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                         ((y == opp_y_cen + 2) && (x <= opp_x_cen) && (x >= opp_x_cen - 3)) ||
                         ((y == opp_y_cen + 1) && (x <= opp_x_cen -1) && (x >= opp_x_cen - 2)) ||
                         ((y == opp_y_cen) && ((x == opp_x_cen - 2) || (x == opp_x_cen + 2))) ||
                         ((y == opp_y_cen - 1) && (x == opp_x_cen + 2))||
                         ((y == opp_y_cen - 2) && (x <= opp_x_cen + 2) && (x >= opp_x_cen));
                        
    assign opp_dl_blue = ((y == opp_y_cen + 3) && (x == opp_x_cen + 1)) || //0
                          ((y == opp_y_cen + 2) && (x <= opp_x_cen + 2) && (x >= opp_x_cen + 1)) ||
                          ((y == opp_y_cen + 1) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                          ((y == opp_y_cen) && (x <= opp_x_cen + 4) && (x >= opp_x_cen + 3)) ||
                          ((y == opp_y_cen - 1) && (x == opp_x_cen + 3)) ||
                          ((y == opp_y_cen - 1) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                          ((y == opp_y_cen - 2) && (x <= opp_x_cen - 1) && (x >= opp_x_cen - 2)) ||
                          ((y == opp_y_cen - 3) && (x <= opp_x_cen + 1) && (x >= opp_x_cen - 1)) ||
                          ((y == opp_y_cen - 4) && (x == opp_x_cen)) ||
                          ((y <= opp_y_cen + 1) && (y >= opp_y_cen - 1) && (x <= opp_x_cen + 1) && (x >= opp_x_cen)) || //u
                          ((y >= opp_y_cen - 1) && (y <= opp_y_cen) && (x == opp_x_cen -1));

    assign opp_dl_white = ((y == opp_y_cen + 4) && (x <= opp_x_cen + 2) && (x >= opp_x_cen + 1)) || //n
                           ((y == opp_y_cen + 3) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                           ((y == opp_y_cen + 2) && (x <= opp_x_cen + 4) && (x >= opp_x_cen + 3)) ||
                           ((y == opp_y_cen + 1) && (x <= opp_x_cen + 5) && (x >= opp_x_cen + 4)) ||
                           ((y == opp_y_cen) && (x == opp_x_cen + 5)) ||
                           ((y == opp_y_cen - 1) && (x == opp_x_cen - 4)) ||
                           ((y == opp_y_cen - 2) && (x <= opp_x_cen - 3) && (x >= opp_x_cen - 4)) ||
                           ((y == opp_y_cen - 3) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                           ((y == opp_y_cen - 4) && (x <= opp_x_cen - 1) && (x >= opp_x_cen - 2)) ||
                           ((y == opp_y_cen - 4) && (x <= opp_x_cen) && (x >= opp_x_cen - 1));

    wire opp_l_red, opp_l_blue, opp_l_white;
    
    assign opp_l_red = (x <= opp_x_cen - 1 && x >= opp_x_cen - 3 && y <= opp_y_cen + 1 && y >= opp_y_cen - 1) || //1
                        ((x == opp_x_cen + 2) && (y <= opp_y_cen + 1) && (y >= opp_y_cen - 1)) ||
                        ((y == opp_y_cen - 2) && (x >= opp_x_cen) && (x <= opp_x_cen + 1)) ||
                        ((y == opp_y_cen - 3) && (x == opp_x_cen + 1)) ||
                        ((y == opp_y_cen + 2) && (x >= opp_x_cen) && (x <= opp_x_cen + 1)) ||
                        ((y == opp_y_cen + 3) && (x == opp_x_cen + 1));

    assign opp_l_blue = ((x == opp_x_cen + 3) && (y >= opp_y_cen - 3) && (y <= opp_y_cen + 3)) || //0
                         ((x == opp_x_cen + 2) && (y <= opp_y_cen - 2) && (y >= opp_y_cen - 3)) ||
                         ((x == opp_x_cen + 2) && (y <= opp_y_cen + 3) && (y >= opp_y_cen + 2)) ||
                         ((x == opp_x_cen) && (y == opp_y_cen - 3)) ||
                         ((x == opp_x_cen) && (y == opp_y_cen + 3)) ||
                         ((x == opp_x_cen - 1) && (y <= opp_y_cen - 2) && (y >= opp_y_cen - 3)) ||
                         ((x == opp_x_cen - 1) && (y <= opp_y_cen + 3) && (y >= opp_y_cen + 2)) ||
                         ((y <= opp_y_cen + 1) && (y >= opp_y_cen - 1) && (x <= opp_x_cen + 1) && (x >= opp_x_cen));
                         
    assign opp_l_white = ((x <= opp_x_cen + 3) && (x >= opp_x_cen - 2) && (y <= opp_y_cen + 5) && (y >= opp_y_cen + 4)) ||
                           ((x <= opp_x_cen + 3) && (x >= opp_x_cen - 2) && (y >= opp_y_cen - 5) && (y <= opp_y_cen - 4));

    wire opp_fl_red, opp_fl_blue, opp_fl_white;
    
    assign opp_fl_red = ((y == opp_y_cen - 3) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                         ((y == opp_y_cen - 2) && (x <= opp_x_cen) && (x >= opp_x_cen - 3)) ||
                         ((y == opp_y_cen - 1) && (x <= opp_x_cen -1) && (x >= opp_x_cen - 2)) ||
                         ((y == opp_y_cen) && ((x == opp_x_cen - 2) || (x == opp_x_cen + 2))) ||
                         ((y == opp_y_cen + 1) && (x == opp_x_cen + 2))||
                         ((y == opp_y_cen + 2) && (x <= opp_x_cen + 2) && (x >= opp_x_cen));

    assign opp_fl_blue = ((y == opp_y_cen - 3) && (x == opp_x_cen + 1)) || //0
                          ((y == opp_y_cen - 2) && (x <= opp_x_cen + 2) && (x >= opp_x_cen + 1)) ||
                          ((y == opp_y_cen - 1) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                          ((y == opp_y_cen) && (x <= opp_x_cen + 4) && (x >= opp_x_cen + 3)) ||
                          ((y == opp_y_cen + 1) && (x == opp_x_cen + 3)) ||
                          ((y == opp_y_cen + 1) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                          ((y == opp_y_cen + 2) && (x <= opp_x_cen - 1) && (x >= opp_x_cen - 2)) ||
                          ((y == opp_y_cen + 3) && (x <= opp_x_cen + 1) && (x >= opp_x_cen - 1)) ||
                          ((y == opp_y_cen + 4) && (x == opp_x_cen)) ||
                          ((y <= opp_y_cen + 1) && (y >= opp_y_cen - 1) && (x <= opp_x_cen + 1) && (x >= opp_x_cen)) || //u
                          ((y <= opp_y_cen + 1) && (y >= opp_y_cen) && (x == opp_x_cen -1));

    assign opp_fl_white = ((y == opp_y_cen - 4) && (x <= opp_x_cen + 2) && (x >= opp_x_cen + 1)) || //n
                           ((y == opp_y_cen - 3) && (x <= opp_x_cen + 3) && (x >= opp_x_cen + 2)) ||
                           ((y == opp_y_cen - 2) && (x <= opp_x_cen + 4) && (x >= opp_x_cen + 3)) ||
                           ((y == opp_y_cen - 1) && (x <= opp_x_cen + 5) && (x >= opp_x_cen + 4)) ||
                           ((y == opp_y_cen) && (x == opp_x_cen + 5)) ||
                           ((y == opp_y_cen + 1) && (x == opp_x_cen - 4)) ||
                           ((y == opp_y_cen + 2) && (x <= opp_x_cen - 3) && (x >= opp_x_cen - 4)) ||
                           ((y == opp_y_cen + 3) && (x <= opp_x_cen - 2) && (x >= opp_x_cen - 3)) ||
                           ((y == opp_y_cen + 4) && (x <= opp_x_cen - 1) && (x >= opp_x_cen - 2)) ||
                           ((y == opp_y_cen + 4) && (x <= opp_x_cen) && (x >= opp_x_cen - 1));

    always @ (posedge clk) begin
    
        user_col <= 0;
        opp_col <= 0;
        has_opp <= 1;
        has_user <= 1;
        
        //calculate camera position
        camera_x = user_x;
        camera_y = user_y;
        
        //calculate map elements (relative to camera position)
        border_x1_rel = border_x - camera_x + 48;
        border_y1_rel = border_y - camera_y + 32;
        border_x2_rel = border_x1_rel + 100;
        border_y2_rel = border_y1_rel + 150;
        pillar_x1_rel = pillar_x - camera_x + 48; 
        pillar_y1_rel = pillar_y - camera_y + 32;
        pillar_x2_rel = pillar_x1_rel + 30;
        pillar_y2_rel = pillar_y1_rel + 30;
        opp_x_cen = enemy_x - camera_x + 48;
        opp_y_cen = enemy_y - camera_y + 32;
        
        //render OLED display 

        case (user_dir)
            3'b000 : begin // D position 1 (facing forward)
                if (user_front_red) begin // 1
                    user_col <= red_c;
                end
                else if (user_front_blue) begin
                    user_col <= blue_c;
                end
                else if(user_front_white) begin
                    user_col <= white_c;
                end
                else begin
                    has_user <= 0;
                    //user_col <= 0;
                end
            end
            
            3'b001 : begin // D position 2 (facing front-right)
                if (user_fr_red) begin
                    user_col <= red_c;
                end
                else if (user_fr_blue) begin
                    user_col <= blue_c;
                end
                else if (user_fr_white) begin
                    user_col <= white_c;
                end
                else begin
                    has_user <= 0;
                    //user_col <= 0;
                end
            end
            
            3'b010 : begin // D position 3 (facing rightwards)
                if (user_r_red) begin
                    user_col <= red_c;
                end
                else if (user_r_blue) begin
                    user_col <= blue_c;
                end
                else if(user_r_white) begin
                    user_col <= white_c;
                end
                else begin
                    has_user <= 0;
                    //user_col <= 0;
                end
            end
            
            3'b011 : begin // D position 4 (facing back-right)
                if (user_dr_red) begin
                    user_col <= red_c;
                end
                else if (user_dr_blue) begin
                    user_col <= blue_c;
                end
                else if (user_dr_white) begin
                    user_col <= white_c;
                end
                else begin
                    has_user <= 0;
                    //user_col <= 0;
                end
            end
            
            3'b100 : begin // D position 5 (facing backwards)
                if (user_d_red) begin
                    user_col <= red_c;
                end
                else if (user_d_blue) begin
                    user_col <= blue_c;
                end
                else if (user_d_white) begin
                    user_col <= white_c;
                end
                else begin
                    has_user <= 0;
                    //user_col <= 0;
                end
            end
          
            3'b101 : begin // D position 6 (facing back-left)
                if (user_dl_red) begin
                    user_col <= red_c;
                end
                else if (user_dl_blue) begin
                    user_col <= blue_c;
                end
                else if (user_dl_white) begin
                    user_col <= white_c;
                end
                else begin
                    has_user <= 0;
                    //user_col <= 0;
                end
            end
                        
            3'b110 : begin // D position 7 (facing leftwards)
                if (user_l_red) begin
                    user_col <= red_c;
                end
                else if (user_l_blue) begin
                    user_col <= blue_c;
                end
                else if (user_l_white) begin
                    user_col <= white_c;
                end
                else begin
                    has_user <= 0;
                    //user_col <= 0;
                end
            end
            
            3'b111 : begin // D position 8 (facing front-left)
                if (user_fl_red) begin
                    user_col <= red_c;
                end
                else if (user_fl_blue) begin
                    user_col <= blue_c;
                end
                else if (user_fl_white) begin
                    user_col <= white_c;
                end
                else begin
                    has_user <= 0;
                    //user_col <= 0;
                end
            end
            
        endcase

        case (opp_dir)
            3'b000 : begin // D position 1 (facing forward)
                if (opp_front_red) begin // 1
                    opp_col <= red_c;
                end
                else if (opp_front_blue) begin
                    opp_col <= purple_c;
                end
                else if(opp_front_white) begin
                    opp_col <= white_c;
                end
                else begin
                    has_opp <= 0;
                    //opp_col <= 0;
                end
            end
            
            3'b001 : begin // D position 2 (facing front-right)
                if (opp_fr_red) begin
                    opp_col <= red_c;
                end
                else if (opp_fr_blue) begin
                    opp_col <= purple_c;
                end
                else if (opp_fr_white) begin
                    opp_col <= white_c;
                end
                else begin
                    has_opp <= 0;
                    //opp_col <= 0;
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
                    //opp_col <= 0;
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
                    //opp_col <= 0;
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
                    //opp_col <= 0;
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
                    //opp_col <= 0;
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
                    //opp_col <= 0;
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
                    //opp_col <= 0;
                end
            end
            
        endcase

        camera <= has_user ? user_col : opp_col;
        
        if (has_user == 0 && has_opp == 0) begin
            
            if (user_bullets) begin
                camera <= green_c;
            end
            else if (opp_bullets) begin
                camera <= yellow_c;
            end
            else camera <= 0;
        end
        
        //render border after camera receives user_col and opp_col;
//        if ((x == border_x1_rel || x == border_x2_rel) && (y >= border_y1_rel && y < border_y2_rel) ||
//            (y == border_y1_rel || y == border_y2_rel) && (x >= border_x1_rel && y < border_x2_rel)) begin
        if ((x == border_x1_rel && y < border_y2_rel && y >= border_y1_rel) ||
            (x == border_x2_rel && y < border_y2_rel && y >= border_y1_rel) ||
            (y == border_y1_rel && x < border_x2_rel && x >= border_x1_rel) ||
            (y == border_y2_rel && x < border_x2_rel && x >= border_x1_rel)) begin
            camera <= white_c;
        end
        
        //render pillar
        if (x >= pillar_x1_rel && x < pillar_x2_rel &&
            y >= pillar_y1_rel && y < pillar_y2_rel) begin
            camera <= white_c;    
        end
        
    end
    

endmodule
