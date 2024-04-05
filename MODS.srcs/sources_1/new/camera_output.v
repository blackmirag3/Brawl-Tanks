`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2024 11:25:08 AM
// Design Name: 
// Module Name: camera_output
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


module camera_output(input clk, input [12:0] x, y, input [8:0] user_x_cen, user_y_cen, opp_x_cen, opp_y_cen,
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
    
    reg [15:0] user_col = 0, opp_col = 0;
    reg has_user = 0, has_opp = 0;
   
    reg [15:0] green_c = 16'b00000_111111_00000; 
    reg [15:0] red_c = 16'b11111_000000_00000; 
    reg [15:0] blue_c = 16'b00000_000000_11111;
    reg [15:0] purple_c = 16'b11111_000000_11111;
    reg [15:0] white_c = 16'b11111_111111_11111;
    reg [15:0] yellow_c = 16'b11111_111111_00000;
    reg [15:0] border_c = 16'b00011_000101_00110;
    reg [15:0] wall_c = 16'b10001_011100_01000;
    
    wire [8:0] opp_pos_x, opp_pos_y;
    wire [8:0] cam_max_x, cam_min_x, cam_max_y, cam_min_y;
    
    assign cam_max_x = user_x_cen + 47;
    assign cam_min_x = user_x_cen - 48;
    assign cam_max_y = user_y_cen + 15;
    assign cam_min_y = user_y_cen - 48;
    
    assign opp_pos_x = opp_x_cen - cam_min_x;
    assign opp_pos_y = opp_y_cen - cam_min_y;
        
    wire [8:0] border_x_min, border_x_max, border_y_min, border_y_max;
    assign border_x_min = 47 - cam_min_x; // vertical border min at x = 47
    assign border_x_max = 168 - cam_min_x; // vertical border max at x = 168
    assign border_y_min = 47 - cam_min_y; // horizontal border min at y = 47
    assign border_y_max = 198 - cam_min_y; // horizontal border max at y = 198
    
    // mid-left x at x = 107
    // mid-right x at x = 108
    // mid-up y at y = 122
    // mid-down y at y = 123
    wire [8:0] pill_x_l, pill_x_r, pill_y_top, pill_y_bot, pill_y_small, pill_y_big, pill_x_small, pill_x_big;
    assign pill_x_l = (cam_min_x > 95 && cam_min_x < 121) ? 0 : 95 - cam_min_x;
    assign pill_x_r = 120 - cam_min_x;
    assign pill_y_top = (cam_min_y > 108 && cam_min_y < 138) ? 0 : 108 - cam_min_y;
    assign pill_y_bot = 137 - cam_min_y;
    assign pill_y_small = (cam_min_y > 120 && cam_min_y < 126) ? 0 : 120 - cam_min_y;
    assign pill_y_big = 125 - cam_min_y;
    assign pill_x_small = (cam_min_x > 105 && cam_min_x < 111) ? 0 : 105 - cam_min_x;
    assign pill_x_big = 110 - cam_min_x;
    
    wire mid_pillar;
    assign mid_pillar = (x >= pill_x_l && x <= pill_x_r && y >= pill_y_small && y <= pill_y_big) ||
                        (x >= pill_x_small && x <= pill_x_big && y >= pill_y_top && y <= pill_y_bot);
    
    wire [8:0] bl_wall_xl, bl_wall_xr, bl_wall_ytop, bl_wall_ybot;
    assign bl_wall_xl = (cam_min_x > 68 && cam_min_x < 90) ? 0 : 68 - cam_min_x;
    assign bl_wall_xr = 89 - cam_min_x;
    assign bl_wall_ytop = (cam_min_y > 168 && cam_min_y < 172) ? 0 : 168 - cam_min_y;
    assign bl_wall_ybot = 171 - cam_min_y;
    wire bot_left_wall;
    assign bot_left_wall = (x >= bl_wall_xl && x <= bl_wall_xr && y >= bl_wall_ytop && y <= bl_wall_ybot);
    
    wire [8:0] tr_wall_xl, tr_wall_xr, tr_wall_ytop, tr_wall_ybot;
    assign tr_wall_xl = (cam_min_x > 126 && cam_min_x < 148) ? 0 : 126 - cam_min_x;
    assign tr_wall_xr = 147 - cam_min_x;
    assign tr_wall_ytop = (cam_min_y > 74 && cam_min_y < 78) ? 0 : 74 - cam_min_y;
    assign tr_wall_ybot = 77 - cam_min_y;
    wire top_right_wall;
    assign top_right_wall = (x >= tr_wall_xl && x <= tr_wall_xr && y >= tr_wall_ytop && y <= tr_wall_ybot);
    
    wire [8:0] vert_wleft_xl, vert_wleft_xr, vert_wleft_ytop, vert_wleft_ybot;
    assign vert_wleft_xl = (cam_min_x > 74 && cam_min_x < 77) ? 0 : 74 - cam_min_x;
    assign vert_wleft_xr = 76 - cam_min_x;
    assign vert_wleft_ytop = (cam_min_y > 121 && cam_min_y < 153) ? 0 : 121 - cam_min_y;
    assign vert_wleft_ybot = 152 - cam_min_y;
    wire vert_left_wall;
    assign vert_left_wall = (x >= vert_wleft_xl && x <= vert_wleft_xr && y >= vert_wleft_ytop && y <= vert_wleft_ybot);
    
    wire [8:0] vert_wright_xl, vert_wright_xr, vert_wright_ytop, vert_wright_ybot;
    assign vert_wright_xl = (cam_min_x > 139 && cam_min_x < 142) ? 0 : 139 - cam_min_x;
    assign vert_wright_xr = 141 - cam_min_x;
    assign vert_wright_ytop = (cam_min_y > 93 && cam_min_y < 125) ? 0 : 93 - cam_min_y;
    assign vert_wright_ybot = 124 - cam_min_y;
    wire vert_right_wall;
    assign vert_right_wall = (x >= vert_wright_xl && x <= vert_wright_xr && y >= vert_wright_ytop && y <= vert_wright_ybot);
    
    wire [8:0] tl_wall_xl, tl_wall_xr, tl_wall_ytop, tl_wall_ybot;
    assign tl_wall_xl = (cam_min_x > 79 && cam_min_x < 95) ? 0 : 79 - cam_min_x;
    assign tl_wall_xr = 94 - cam_min_x;
    assign tl_wall_ytop = (cam_min_y > 89 && cam_min_y < 92) ? 0 : 89 - cam_min_y;
    assign tl_wall_ybot = 91 - cam_min_y;
    wire top_left_wall;
    assign top_left_wall = (x >= tl_wall_xl && x <= tl_wall_xr && y >= tl_wall_ytop && y <= tl_wall_ybot);
    
    wire [8:0] br_wall_xl, br_wall_xr, br_wall_ytop, br_wall_ybot;
    assign br_wall_xl = (cam_min_x > 121 && cam_min_x < 137) ? 0 : 121 - cam_min_x;
    assign br_wall_xr = 136 - cam_min_x;
    assign br_wall_ytop = (cam_min_y > 154 && cam_min_y < 157) ? 0 : 154 - cam_min_y;
    assign br_wall_ybot = 156 - cam_min_y;
    wire bot_right_wall;
    assign bot_right_wall = (x >= br_wall_xl && x <= br_wall_xr && y >= br_wall_ytop && y <= br_wall_ybot);
    
    wire walls;
    assign walls = bot_left_wall || top_right_wall || vert_left_wall || vert_right_wall || top_left_wall || bot_right_wall;
    
    wire [8:0] user_x0, user_x1, user_x2, user_x3, user_x4;
    wire [8:0] opp_x0, opp_x1, opp_x2, opp_x3, opp_x4;
    wire [8:0] user_y0, user_y1, user_y2, user_y3, user_y4;
    wire [8:0] opp_y0, opp_y1, opp_y2, opp_y3, opp_y4;

    assign user_x0 = b_x_cen[7:0] - cam_min_x;
    assign user_x1 = b_x_cen[15:8] - cam_min_x;
    assign user_x2 = b_x_cen[23:16] - cam_min_x;
    assign user_x3 = b_x_cen[31:24] - cam_min_x;
    assign user_x4 = b_x_cen[39:32] - cam_min_x;
    
    assign user_y0 = b_y_cen[7:0] - cam_min_y;
    assign user_y1 = b_y_cen[15:8] - cam_min_y;
    assign user_y2 = b_y_cen[23:16] - cam_min_y;
    assign user_y3 = b_y_cen[31:24] - cam_min_y;
    assign user_y4 = b_y_cen[39:32] - cam_min_y;
    
    assign opp_x0 = ob_x_cen[7:0] - cam_min_x;
    assign opp_x1 = ob_x_cen[15:8] - cam_min_x;
    assign opp_x2 = ob_x_cen[23:16] - cam_min_x;
    assign opp_x3 = ob_x_cen[31:24] - cam_min_x;
    assign opp_x4 = ob_x_cen[39:32] - cam_min_x;
    
    assign opp_y0 = ob_y_cen[7:0] - cam_min_y;
    assign opp_y1 = ob_y_cen[15:8] - cam_min_y;
    assign opp_y2 = ob_y_cen[23:16] - cam_min_y;
    assign opp_y3 = ob_y_cen[31:24] - cam_min_y;
    assign opp_y4 = ob_y_cen[39:32] - cam_min_y;
    
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


    // border
    wire border;
    assign border = (x >= border_x_max && x <= 95) || (x <= border_x_min && border_x_min <= 47) ||
                    (y >= border_y_max && y <= 63) || (y <= border_y_min && border_y_min <= 47); 
    
    // user tank colours
     wire user_front_red, user_front_blue, user_front_white;
         
     assign user_front_red = (x >= 48 - 1 && x <= 48 + 1 && y >= 48 - 3 && y <= 48 - 1) || //1
                             (((x == 48 + 2) || (x == 48 - 2)) && (y == 48)) ||
                             ((y == 48 + 1) && (x <= 48 - 1) && (x >= 48 - 2)) ||
                             ((y == 48 + 1) && (x >= 48 + 1) && (x <= 48 + 2)) ||
                             ((y == 48 + 2) && (x <= 48 + 1) && (x >= 48 - 1));
                             
     assign user_front_blue = ((y == 48 - 1) && (x <= 48 - 2) && (x >= 48 - 3)) || //0
                              ((y == 48 - 1) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                              ((y == 48) && ((x == 48 - 3) || (x == 48 + 3))) ||
                              ((y == 48 + 2) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                              ((y == 48 + 2) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                              ((y == 48 + 3) && (x <= 48 + 3) && (x >= 48 - 3)) ||
                              ((y >= 48) && (y <= 48 + 1) && (x <= 48 + 1) && (x >= 48 - 1)); // u
     
     assign user_front_white = ((y >= 48 - 2) && (y <= 48 + 3) && 
                               ((x <= 48 + 5 && x >= 48 + 4) || (x >= 48 - 5 && x <= 48 - 4)));
     
     wire user_fr_red, user_fr_blue, user_fr_white;
     
     assign user_fr_red = ((y == 48 - 3) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                          ((y == 48 - 2) && (x >= 48) && (x <= 48 + 3)) ||
                          ((y == 48 - 1) && (x >= 48 + 1) && (x <= 48 + 2)) ||
                          ((y == 48) && ((x == 48 + 2) || (x == 48 - 2))) ||
                          ((y == 48 + 1) && (x == 48 - 2))||
                          ((y == 48 + 2) && (x >= 48 - 2) && (x <= 48));
     
     assign user_fr_blue = ((y == 48 - 3) && (x == 48 - 1)) || //0
                           ((y == 48 - 2) && (x >= 48 - 2) && (x <= 48 - 1)) ||
                           ((y == 48 - 1) && (x >= 48 - 3) && (x <= 48 - 2)) ||
                           ((y == 48) && (x >= 48 - 4) && (x <= 48 - 3)) ||
                           ((y == 48 + 1) && (x == 48 - 3)) ||
                           ((y == 48 + 1) && (x >= 48 + 2) && (x <= 48 + 3)) ||
                           ((y == 48 + 2) && (x >= 48 + 1) && (x <= 48 + 2)) ||
                           ((y == 48 + 3) && (x >= 48 - 1) && (x <= 48 + 1)) ||
                           ((y == 48 + 4) && (x == 48)) ||
                           ((y <= 48 + 1) && (y >= 48 - 1) && (x >= 48 - 1) && (x <= 48)) || //u
                           ((y <= 48 + 1) && (y >= 48) && (x == 48 + 1));
     
     assign user_fr_white = ((y == 48 - 4) && (x <= 48 - 1) && (x >= 48 - 2)) || //n
                            ((y == 48 - 3) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                            ((y == 48 - 2) && (x <= 48 - 3) && (x >= 48 - 4)) ||
                            ((y == 48 - 1) && (x <= 48 - 4) && (x >= 48 - 5)) ||
                            ((y == 48) && (x == 48 - 5)) ||
                            ((y == 48 + 1) && (x == 48 + 4)) ||
                            ((y == 48 + 2) && (x <= 48 + 4) && (x >= 48 + 3)) ||
                            ((y == 48 + 3) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                            ((y == 48 + 4) && (x <= 48 + 2) && (x >= 48 + 1)) ||
                            ((y == 48 + 4) && (x >= 48) && (x <= 48 + 1));
     
     wire user_r_red, user_r_blue, user_r_white;
     
     assign user_r_red = (x >= 48 + 1 && x <= 48 + 3 && y <= 48 + 1 && y >= 48 - 1) || //1
                         ((x == 48 - 2) && (y <= 48 + 1) && (y >= 48 - 1)) ||
                         ((y == 48 - 2) && (x <= 48) && (x >= 48 - 1)) ||
                         ((y == 48 - 3) && (x == 48 - 1)) ||
                         ((y == 48 + 2) && (x <= 48) && (x >= 48 - 1)) ||
                         ((y == 48 + 3) && (x == 48 - 1));
 
     assign user_r_blue = ((x == 48 - 3) && (y >= 48 - 3) && (y <= 48 + 3)) || //0
                          ((x == 48 - 2) && (y <= 48 - 2) && (y >= 48 - 3)) ||
                          ((x == 48 - 2) && (y <= 48 + 3) && (y >= 48 + 2)) ||
                          ((x == 48) && (y == 48 - 3)) ||
                          ((x == 48) && (y == 48 + 3)) ||
                          ((x == 48 + 1) && (y <= 48 - 2) && (y >= 48 - 3)) ||
                          ((x == 48 + 1) && (y <= 48 + 3) && (y >= 48 + 2)) ||
                          ((y <= 48 + 1) && (y >= 48 - 1) && (x <= 48) && (x >= 48 - 1));
 
     assign user_r_white = ((x <= 48 + 2) && (x >= 48 - 3) && (y <= 48 + 5) && (y >= 48 + 4)) ||
                           ((x <= 48 + 2) && (x >= 48 - 3) && (y >= 48 - 5) && (y <= 48 - 4));
 
     wire user_dr_red, user_dr_blue, user_dr_white;
     
     assign user_dr_red = ((y == 48 + 3) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                          ((y == 48 + 2) && (x >= 48) && (x <= 48 + 3)) ||
                          ((y == 48 + 1) && (x >= 48 + 1) && (x <= 48 + 2)) ||
                          ((y == 48) && ((x == 48 + 2) || (x == 48 - 2))) ||
                          ((y == 48 - 1) && (x == 48 - 2))||
                          ((y == 48 - 2) && (x >= 48 - 2) && (x <= 48));
 
     assign user_dr_blue = ((y == 48 + 3) && (x == 48 - 1)) || //0
                           ((y == 48 + 2) && (x >= 48 - 2) && (x <= 48 - 1)) ||
                           ((y == 48 + 1) && (x >= 48 - 3) && (x <= 48 - 2)) ||
                           ((y == 48) && (x >= 48 - 4) && (x <= 48 - 3)) ||
                           ((y == 48 - 1) && (x == 48 - 3)) ||
                           ((y == 48 - 1) && (x >= 48 + 2) && (x <= 48 + 3)) ||
                           ((y == 48 - 2) && (x >= 48 + 1) && (x <= 48 + 2)) ||
                           ((y == 48 - 3) && (x >= 48 - 1) && (x <= 48 + 1)) ||
                           ((y == 48 - 4) && (x == 48)) ||
                           ((y <= 48 + 1) && (y >= 48 - 1) && (x >= 48 - 1) && (x <= 48)) || //u
                           ((y >= 48 - 1) && (y <= 48) && (x == 48 + 1));
 
     assign user_dr_white = ((y == 48 + 4) && (x <= 48 - 1) && (x >= 48 - 2)) || //n
                            ((y == 48 + 3) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                            ((y == 48 + 2) && (x <= 48 - 3) && (x >= 48 - 4)) ||
                            ((y == 48 + 1) && (x <= 48 - 4) && (x >= 48 - 5)) ||
                            ((y == 48) && (x == 48 - 5)) ||
                            ((y == 48 - 1) && (x == 48 + 4)) ||
                            ((y == 48 - 2) && (x <= 48 + 4) && (x >= 48 + 3)) ||
                            ((y == 48 - 3) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                            ((y == 48 - 4) && (x <= 48 + 2) && (x >= 48 + 1)) ||
                            ((y == 48 - 4) && (x >= 48) && (x <= 48 + 1));
 
     wire user_d_red, user_d_blue, user_d_white;
     
     assign user_d_red = (x >= 48 - 1 && x <= 48 + 1 && y <= 48 + 3 && y >= 48 + 1) || //1
                         (((x == 48 + 2) || (x == 48 - 2)) && (y == 48)) ||
                         ((y == 48 - 1) && (x <= 48 - 1) && (x >= 48 - 2)) ||
                         ((y == 48 - 1) && (x >= 48 + 1) && (x <= 48 + 2)) ||
                         ((y == 48 - 2) && (x <= 48 + 1) && (x >= 48 - 1));
 
     assign user_d_blue = ((y == 48 + 1) && (x <= 48 - 2) && (x >= 48 - 3)) || //0
                          ((y == 48 + 1) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                          ((y == 48) && ((x == 48 - 3) || (x == 48 + 3))) ||
                          ((y == 48 - 2) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                          ((y == 48 - 2) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                          ((y == 48 - 3) && (x <= 48 + 3) && (x >= 48 - 3)) ||
                          (y <= 48) && (y >= 48 - 1) && (x <= 48 + 1) && (x >= 48 - 1);
 
     assign user_d_white = ((y <= 48 + 2) && (y >= 48 - 3) && (x <= 48 + 5) && (x >= 48 + 4)) ||
                           ((y <= 48 + 2) && (y >= 48 - 3) && (x >= 48 - 5) && (x <= 48 - 4));
 
     wire user_dl_red, user_dl_blue, user_dl_white;
     
     assign user_dl_red = ((y == 48 + 3) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                          ((y == 48 + 2) && (x <= 48) && (x >= 48 - 3)) ||
                          ((y == 48 + 1) && (x <= 48 -1) && (x >= 48 - 2)) ||
                          ((y == 48) && ((x == 48 - 2) || (x == 48 + 2))) ||
                          ((y == 48 - 1) && (x == 48 + 2))||
                          ((y == 48 - 2) && (x <= 48 + 2) && (x >= 48));
                         
     assign user_dl_blue = ((y == 48 + 3) && (x == 48 + 1)) || //0
                           ((y == 48 + 2) && (x <= 48 + 2) && (x >= 48 + 1)) ||
                           ((y == 48 + 1) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                           ((y == 48) && (x <= 48 + 4) && (x >= 48 + 3)) ||
                           ((y == 48 - 1) && (x == 48 + 3)) ||
                           ((y == 48 - 1) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                           ((y == 48 - 2) && (x <= 48 - 1) && (x >= 48 - 2)) ||
                           ((y == 48 - 3) && (x <= 48 + 1) && (x >= 48 - 1)) ||
                           ((y == 48 - 4) && (x == 48)) ||
                           ((y <= 48 + 1) && (y >= 48 - 1) && (x <= 48 + 1) && (x >= 48)) || //u
                           ((y >= 48 - 1) && (y <= 48) && (x == 48 -1));
 
     assign user_dl_white = ((y == 48 + 4) && (x <= 48 + 2) && (x >= 48 + 1)) || //n
                            ((y == 48 + 3) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                            ((y == 48 + 2) && (x <= 48 + 4) && (x >= 48 + 3)) ||
                            ((y == 48 + 1) && (x <= 48 + 5) && (x >= 48 + 4)) ||
                            ((y == 48) && (x == 48 + 5)) ||
                            ((y == 48 - 1) && (x == 48 - 4)) ||
                            ((y == 48 - 2) && (x <= 48 - 3) && (x >= 48 - 4)) ||
                            ((y == 48 - 3) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                            ((y == 48 - 4) && (x <= 48 - 1) && (x >= 48 - 2)) ||
                            ((y == 48 - 4) && (x <= 48) && (x >= 48 - 1));
 
     wire user_l_red, user_l_blue, user_l_white;
     
     assign user_l_red = (x <= 48 - 1 && x >= 48 - 3 && y <= 48 + 1 && y >= 48 - 1) || //1
                         ((x == 48 + 2) && (y <= 48 + 1) && (y >= 48 - 1)) ||
                         ((y == 48 - 2) && (x >= 48) && (x <= 48 + 1)) ||
                         ((y == 48 - 3) && (x == 48 + 1)) ||
                         ((y == 48 + 2) && (x >= 48) && (x <= 48 + 1)) ||
                         ((y == 48 + 3) && (x == 48 + 1));
 
     assign user_l_blue = ((x == 48 + 3) && (y >= 48 - 3) && (y <= 48 + 3)) || //0
                          ((x == 48 + 2) && (y <= 48 - 2) && (y >= 48 - 3)) ||
                          ((x == 48 + 2) && (y <= 48 + 3) && (y >= 48 + 2)) ||
                          ((x == 48) && (y == 48 - 3)) ||
                          ((x == 48) && (y == 48 + 3)) ||
                          ((x == 48 - 1) && (y <= 48 - 2) && (y >= 48 - 3)) ||
                          ((x == 48 - 1) && (y <= 48 + 3) && (y >= 48 + 2)) ||
                          ((y <= 48 + 1) && (y >= 48 - 1) && (x <= 48 + 1) && (x >= 48));
                          
     assign user_l_white = ((x <= 48 + 3) && (x >= 48 - 2) && (y <= 48 + 5) && (y >= 48 + 4)) ||
                           ((x <= 48 + 3) && (x >= 48 - 2) && (y >= 48 - 5) && (y <= 48 - 4));
 
     wire user_fl_red, user_fl_blue, user_fl_white;
     
     assign user_fl_red = ((y == 48 - 3) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                          ((y == 48 - 2) && (x <= 48) && (x >= 48 - 3)) ||
                          ((y == 48 - 1) && (x <= 48 -1) && (x >= 48 - 2)) ||
                          ((y == 48) && ((x == 48 - 2) || (x == 48 + 2))) ||
                          ((y == 48 + 1) && (x == 48 + 2))||
                          ((y == 48 + 2) && (x <= 48 + 2) && (x >= 48));
 
     assign user_fl_blue = ((y == 48 - 3) && (x == 48 + 1)) || //0
                           ((y == 48 - 2) && (x <= 48 + 2) && (x >= 48 + 1)) ||
                           ((y == 48 - 1) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                           ((y == 48) && (x <= 48 + 4) && (x >= 48 + 3)) ||
                           ((y == 48 + 1) && (x == 48 + 3)) ||
                           ((y == 48 + 1) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                           ((y == 48 + 2) && (x <= 48 - 1) && (x >= 48 - 2)) ||
                           ((y == 48 + 3) && (x <= 48 + 1) && (x >= 48 - 1)) ||
                           ((y == 48 + 4) && (x == 48)) ||
                           ((y <= 48 + 1) && (y >= 48 - 1) && (x <= 48 + 1) && (x >= 48)) || //u
                           ((y <= 48 + 1) && (y >= 48) && (x == 48 -1));
 
     assign user_fl_white = ((y == 48 - 4) && (x <= 48 + 2) && (x >= 48 + 1)) || //n
                            ((y == 48 - 3) && (x <= 48 + 3) && (x >= 48 + 2)) ||
                            ((y == 48 - 2) && (x <= 48 + 4) && (x >= 48 + 3)) ||
                            ((y == 48 - 1) && (x <= 48 + 5) && (x >= 48 + 4)) ||
                            ((y == 48) && (x == 48 + 5)) ||
                            ((y == 48 + 1) && (x == 48 - 4)) ||
                            ((y == 48 + 2) && (x <= 48 - 3) && (x >= 48 - 4)) ||
                            ((y == 48 + 3) && (x <= 48 - 2) && (x >= 48 - 3)) ||
                            ((y == 48 + 4) && (x <= 48 - 1) && (x >= 48 - 2)) ||
                            ((y == 48 + 4) && (x <= 48) && (x >= 48 - 1));
                            
    // opp tank colours
    wire opp_front_red, opp_front_blue, opp_front_white;
        
    assign opp_front_red = (x >= opp_pos_x - 1 && x <= opp_pos_x + 1 && y >= opp_pos_y - 3 && y <= opp_pos_y - 1) || //1
                            (((x == opp_pos_x + 2) || (x == opp_pos_x - 2)) && (y == opp_pos_y)) ||
                            ((y == opp_pos_y + 1) && (x <= opp_pos_x - 1) && (x >= opp_pos_x - 2)) ||
                            ((y == opp_pos_y + 1) && (x >= opp_pos_x + 1) && (x <= opp_pos_x + 2)) ||
                            ((y == opp_pos_y + 2) && (x <= opp_pos_x + 1) && (x >= opp_pos_x - 1));
                            
    assign opp_front_blue = ((y == opp_pos_y - 1) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) || //0
                             ((y == opp_pos_y - 1) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                             ((y == opp_pos_y) && ((x == opp_pos_x - 3) || (x == opp_pos_x + 3))) ||
                             ((y == opp_pos_y + 2) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                             ((y == opp_pos_y + 2) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                             ((y == opp_pos_y + 3) && (x <= opp_pos_x + 3) && (x >= opp_pos_x - 3)) ||
                             ((y >= opp_pos_y) && (y <= opp_pos_y + 1) && (x <= opp_pos_x + 1) && (x >= opp_pos_x - 1)); // u
    
    assign opp_front_white = ((y >= opp_pos_y - 2) && (y <= opp_pos_y + 3) && 
                              ((x <= opp_pos_x + 5 && x >= opp_pos_x + 4) || (x >= opp_pos_x - 5 && x <= opp_pos_x - 4)));
    
    wire opp_fr_red, opp_fr_blue, opp_fr_white;
    
    assign opp_fr_red = ((y == opp_pos_y - 3) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                         ((y == opp_pos_y - 2) && (x >= opp_pos_x) && (x <= opp_pos_x + 3)) ||
                         ((y == opp_pos_y - 1) && (x >= opp_pos_x + 1) && (x <= opp_pos_x + 2)) ||
                         ((y == opp_pos_y) && ((x == opp_pos_x + 2) || (x == opp_pos_x - 2))) ||
                         ((y == opp_pos_y + 1) && (x == opp_pos_x - 2))||
                         ((y == opp_pos_y + 2) && (x >= opp_pos_x - 2) && (x <= opp_pos_x));
    
    assign opp_fr_blue = ((y == opp_pos_y - 3) && (x == opp_pos_x - 1)) || //0
                          ((y == opp_pos_y - 2) && (x >= opp_pos_x - 2) && (x <= opp_pos_x - 1)) ||
                          ((y == opp_pos_y - 1) && (x >= opp_pos_x - 3) && (x <= opp_pos_x - 2)) ||
                          ((y == opp_pos_y) && (x >= opp_pos_x - 4) && (x <= opp_pos_x - 3)) ||
                          ((y == opp_pos_y + 1) && (x == opp_pos_x - 3)) ||
                          ((y == opp_pos_y + 1) && (x >= opp_pos_x + 2) && (x <= opp_pos_x + 3)) ||
                          ((y == opp_pos_y + 2) && (x >= opp_pos_x + 1) && (x <= opp_pos_x + 2)) ||
                          ((y == opp_pos_y + 3) && (x >= opp_pos_x - 1) && (x <= opp_pos_x + 1)) ||
                          ((y == opp_pos_y + 4) && (x == opp_pos_x)) ||
                          ((y <= opp_pos_y + 1) && (y >= opp_pos_y - 1) && (x >= opp_pos_x - 1) && (x <= opp_pos_x)) || //u
                          ((y <= opp_pos_y + 1) && (y >= opp_pos_y) && (x == opp_pos_x + 1));
    
    assign opp_fr_white = ((y == opp_pos_y - 4) && (x <= opp_pos_x - 1) && (x >= opp_pos_x - 2)) || //n
                           ((y == opp_pos_y - 3) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                           ((y == opp_pos_y - 2) && (x <= opp_pos_x - 3) && (x >= opp_pos_x - 4)) ||
                           ((y == opp_pos_y - 1) && (x <= opp_pos_x - 4) && (x >= opp_pos_x - 5)) ||
                           ((y == opp_pos_y) && (x == opp_pos_x - 5)) ||
                           ((y == opp_pos_y + 1) && (x == opp_pos_x + 4)) ||
                           ((y == opp_pos_y + 2) && (x <= opp_pos_x + 4) && (x >= opp_pos_x + 3)) ||
                           ((y == opp_pos_y + 3) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                           ((y == opp_pos_y + 4) && (x <= opp_pos_x + 2) && (x >= opp_pos_x + 1)) ||
                           ((y == opp_pos_y + 4) && (x >= opp_pos_x) && (x <= opp_pos_x + 1));
    
    wire opp_r_red, opp_r_blue, opp_r_white;
    
    assign opp_r_red = (x >= opp_pos_x + 1 && x <= opp_pos_x + 3 && y <= opp_pos_y + 1 && y >= opp_pos_y - 1) || //1
                        ((x == opp_pos_x - 2) && (y <= opp_pos_y + 1) && (y >= opp_pos_y - 1)) ||
                        ((y == opp_pos_y - 2) && (x <= opp_pos_x) && (x >= opp_pos_x - 1)) ||
                        ((y == opp_pos_y - 3) && (x == opp_pos_x - 1)) ||
                        ((y == opp_pos_y + 2) && (x <= opp_pos_x) && (x >= opp_pos_x - 1)) ||
                        ((y == opp_pos_y + 3) && (x == opp_pos_x - 1));

    assign opp_r_blue = ((x == opp_pos_x - 3) && (y >= opp_pos_y - 3) && (y <= opp_pos_y + 3)) || //0
                         ((x == opp_pos_x - 2) && (y <= opp_pos_y - 2) && (y >= opp_pos_y - 3)) ||
                         ((x == opp_pos_x - 2) && (y <= opp_pos_y + 3) && (y >= opp_pos_y + 2)) ||
                         ((x == opp_pos_x) && (y == opp_pos_y - 3)) ||
                         ((x == opp_pos_x) && (y == opp_pos_y + 3)) ||
                         ((x == opp_pos_x + 1) && (y <= opp_pos_y - 2) && (y >= opp_pos_y - 3)) ||
                         ((x == opp_pos_x + 1) && (y <= opp_pos_y + 3) && (y >= opp_pos_y + 2)) ||
                         ((y <= opp_pos_y + 1) && (y >= opp_pos_y - 1) && (x <= opp_pos_x) && (x >= opp_pos_x - 1));

    assign opp_r_white = ((x <= opp_pos_x + 2) && (x >= opp_pos_x - 3) && (y <= opp_pos_y + 5) && (y >= opp_pos_y + 4)) ||
                          ((x <= opp_pos_x + 2) && (x >= opp_pos_x - 3) && (y >= opp_pos_y - 5) && (y <= opp_pos_y - 4));

    wire opp_dr_red, opp_dr_blue, opp_dr_white;
    
    assign opp_dr_red = ((y == opp_pos_y + 3) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                         ((y == opp_pos_y + 2) && (x >= opp_pos_x) && (x <= opp_pos_x + 3)) ||
                         ((y == opp_pos_y + 1) && (x >= opp_pos_x + 1) && (x <= opp_pos_x + 2)) ||
                         ((y == opp_pos_y) && ((x == opp_pos_x + 2) || (x == opp_pos_x - 2))) ||
                         ((y == opp_pos_y - 1) && (x == opp_pos_x - 2))||
                         ((y == opp_pos_y - 2) && (x >= opp_pos_x - 2) && (x <= opp_pos_x));

    assign opp_dr_blue = ((y == opp_pos_y + 3) && (x == opp_pos_x - 1)) || //0
                          ((y == opp_pos_y + 2) && (x >= opp_pos_x - 2) && (x <= opp_pos_x - 1)) ||
                          ((y == opp_pos_y + 1) && (x >= opp_pos_x - 3) && (x <= opp_pos_x - 2)) ||
                          ((y == opp_pos_y) && (x >= opp_pos_x - 4) && (x <= opp_pos_x - 3)) ||
                          ((y == opp_pos_y - 1) && (x == opp_pos_x - 3)) ||
                          ((y == opp_pos_y - 1) && (x >= opp_pos_x + 2) && (x <= opp_pos_x + 3)) ||
                          ((y == opp_pos_y - 2) && (x >= opp_pos_x + 1) && (x <= opp_pos_x + 2)) ||
                          ((y == opp_pos_y - 3) && (x >= opp_pos_x - 1) && (x <= opp_pos_x + 1)) ||
                          ((y == opp_pos_y - 4) && (x == opp_pos_x)) ||
                          ((y <= opp_pos_y + 1) && (y >= opp_pos_y - 1) && (x >= opp_pos_x - 1) && (x <= opp_pos_x)) || //u
                          ((y >= opp_pos_y - 1) && (y <= opp_pos_y) && (x == opp_pos_x + 1));

    assign opp_dr_white = ((y == opp_pos_y + 4) && (x <= opp_pos_x - 1) && (x >= opp_pos_x - 2)) || //n
                           ((y == opp_pos_y + 3) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                           ((y == opp_pos_y + 2) && (x <= opp_pos_x - 3) && (x >= opp_pos_x - 4)) ||
                           ((y == opp_pos_y + 1) && (x <= opp_pos_x - 4) && (x >= opp_pos_x - 5)) ||
                           ((y == opp_pos_y) && (x == opp_pos_x - 5)) ||
                           ((y == opp_pos_y - 1) && (x == opp_pos_x + 4)) ||
                           ((y == opp_pos_y - 2) && (x <= opp_pos_x + 4) && (x >= opp_pos_x + 3)) ||
                           ((y == opp_pos_y - 3) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                           ((y == opp_pos_y - 4) && (x <= opp_pos_x + 2) && (x >= opp_pos_x + 1)) ||
                           ((y == opp_pos_y - 4) && (x >= opp_pos_x) && (x <= opp_pos_x + 1));

    wire opp_d_red, opp_d_blue, opp_d_white;
    
    assign opp_d_red = (x >= opp_pos_x - 1 && x <= opp_pos_x + 1 && y <= opp_pos_y + 3 && y >= opp_pos_y + 1) || //1
                        (((x == opp_pos_x + 2) || (x == opp_pos_x - 2)) && (y == opp_pos_y)) ||
                        ((y == opp_pos_y - 1) && (x <= opp_pos_x - 1) && (x >= opp_pos_x - 2)) ||
                        ((y == opp_pos_y - 1) && (x >= opp_pos_x + 1) && (x <= opp_pos_x + 2)) ||
                        ((y == opp_pos_y - 2) && (x <= opp_pos_x + 1) && (x >= opp_pos_x - 1));

    assign opp_d_blue = ((y == opp_pos_y + 1) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) || //0
                         ((y == opp_pos_y + 1) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                         ((y == opp_pos_y) && ((x == opp_pos_x - 3) || (x == opp_pos_x + 3))) ||
                         ((y == opp_pos_y - 2) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                         ((y == opp_pos_y - 2) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                         ((y == opp_pos_y - 3) && (x <= opp_pos_x + 3) && (x >= opp_pos_x - 3)) ||
                         (y <= opp_pos_y) && (y >= opp_pos_y - 1) && (x <= opp_pos_x + 1) && (x >= opp_pos_x - 1);

    assign opp_d_white = ((y <= opp_pos_y + 2) && (y >= opp_pos_y - 3) && (x <= opp_pos_x + 5) && (x >= opp_pos_x + 4)) ||
                          ((y <= opp_pos_y + 2) && (y >= opp_pos_y - 3) && (x >= opp_pos_x - 5) && (x <= opp_pos_x - 4));

    wire opp_dl_red, opp_dl_blue, opp_dl_white;
    
    assign opp_dl_red = ((y == opp_pos_y + 3) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                         ((y == opp_pos_y + 2) && (x <= opp_pos_x) && (x >= opp_pos_x - 3)) ||
                         ((y == opp_pos_y + 1) && (x <= opp_pos_x -1) && (x >= opp_pos_x - 2)) ||
                         ((y == opp_pos_y) && ((x == opp_pos_x - 2) || (x == opp_pos_x + 2))) ||
                         ((y == opp_pos_y - 1) && (x == opp_pos_x + 2))||
                         ((y == opp_pos_y - 2) && (x <= opp_pos_x + 2) && (x >= opp_pos_x));
                        
    assign opp_dl_blue = ((y == opp_pos_y + 3) && (x == opp_pos_x + 1)) || //0
                          ((y == opp_pos_y + 2) && (x <= opp_pos_x + 2) && (x >= opp_pos_x + 1)) ||
                          ((y == opp_pos_y + 1) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                          ((y == opp_pos_y) && (x <= opp_pos_x + 4) && (x >= opp_pos_x + 3)) ||
                          ((y == opp_pos_y - 1) && (x == opp_pos_x + 3)) ||
                          ((y == opp_pos_y - 1) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                          ((y == opp_pos_y - 2) && (x <= opp_pos_x - 1) && (x >= opp_pos_x - 2)) ||
                          ((y == opp_pos_y - 3) && (x <= opp_pos_x + 1) && (x >= opp_pos_x - 1)) ||
                          ((y == opp_pos_y - 4) && (x == opp_pos_x)) ||
                          ((y <= opp_pos_y + 1) && (y >= opp_pos_y - 1) && (x <= opp_pos_x + 1) && (x >= opp_pos_x)) || //u
                          ((y >= opp_pos_y - 1) && (y <= opp_pos_y) && (x == opp_pos_x -1));

    assign opp_dl_white = ((y == opp_pos_y + 4) && (x <= opp_pos_x + 2) && (x >= opp_pos_x + 1)) || //n
                           ((y == opp_pos_y + 3) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                           ((y == opp_pos_y + 2) && (x <= opp_pos_x + 4) && (x >= opp_pos_x + 3)) ||
                           ((y == opp_pos_y + 1) && (x <= opp_pos_x + 5) && (x >= opp_pos_x + 4)) ||
                           ((y == opp_pos_y) && (x == opp_pos_x + 5)) ||
                           ((y == opp_pos_y - 1) && (x == opp_pos_x - 4)) ||
                           ((y == opp_pos_y - 2) && (x <= opp_pos_x - 3) && (x >= opp_pos_x - 4)) ||
                           ((y == opp_pos_y - 3) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                           ((y == opp_pos_y - 4) && (x <= opp_pos_x - 1) && (x >= opp_pos_x - 2)) ||
                           ((y == opp_pos_y - 4) && (x <= opp_pos_x) && (x >= opp_pos_x - 1));

    wire opp_l_red, opp_l_blue, opp_l_white;
    
    assign opp_l_red = (x <= opp_pos_x - 1 && x >= opp_pos_x - 3 && y <= opp_pos_y + 1 && y >= opp_pos_y - 1) || //1
                        ((x == opp_pos_x + 2) && (y <= opp_pos_y + 1) && (y >= opp_pos_y - 1)) ||
                        ((y == opp_pos_y - 2) && (x >= opp_pos_x) && (x <= opp_pos_x + 1)) ||
                        ((y == opp_pos_y - 3) && (x == opp_pos_x + 1)) ||
                        ((y == opp_pos_y + 2) && (x >= opp_pos_x) && (x <= opp_pos_x + 1)) ||
                        ((y == opp_pos_y + 3) && (x == opp_pos_x + 1));

    assign opp_l_blue = ((x == opp_pos_x + 3) && (y >= opp_pos_y - 3) && (y <= opp_pos_y + 3)) || //0
                         ((x == opp_pos_x + 2) && (y <= opp_pos_y - 2) && (y >= opp_pos_y - 3)) ||
                         ((x == opp_pos_x + 2) && (y <= opp_pos_y + 3) && (y >= opp_pos_y + 2)) ||
                         ((x == opp_pos_x) && (y == opp_pos_y - 3)) ||
                         ((x == opp_pos_x) && (y == opp_pos_y + 3)) ||
                         ((x == opp_pos_x - 1) && (y <= opp_pos_y - 2) && (y >= opp_pos_y - 3)) ||
                         ((x == opp_pos_x - 1) && (y <= opp_pos_y + 3) && (y >= opp_pos_y + 2)) ||
                         ((y <= opp_pos_y + 1) && (y >= opp_pos_y - 1) && (x <= opp_pos_x + 1) && (x >= opp_pos_x));
                         
    assign opp_l_white = ((x <= opp_pos_x + 3) && (x >= opp_pos_x - 2) && (y <= opp_pos_y + 5) && (y >= opp_pos_y + 4)) ||
                           ((x <= opp_pos_x + 3) && (x >= opp_pos_x - 2) && (y >= opp_pos_y - 5) && (y <= opp_pos_y - 4));

    wire opp_fl_red, opp_fl_blue, opp_fl_white;
    
    assign opp_fl_red = ((y == opp_pos_y - 3) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                         ((y == opp_pos_y - 2) && (x <= opp_pos_x) && (x >= opp_pos_x - 3)) ||
                         ((y == opp_pos_y - 1) && (x <= opp_pos_x -1) && (x >= opp_pos_x - 2)) ||
                         ((y == opp_pos_y) && ((x == opp_pos_x - 2) || (x == opp_pos_x + 2))) ||
                         ((y == opp_pos_y + 1) && (x == opp_pos_x + 2))||
                         ((y == opp_pos_y + 2) && (x <= opp_pos_x + 2) && (x >= opp_pos_x));

    assign opp_fl_blue = ((y == opp_pos_y - 3) && (x == opp_pos_x + 1)) || //0
                          ((y == opp_pos_y - 2) && (x <= opp_pos_x + 2) && (x >= opp_pos_x + 1)) ||
                          ((y == opp_pos_y - 1) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                          ((y == opp_pos_y) && (x <= opp_pos_x + 4) && (x >= opp_pos_x + 3)) ||
                          ((y == opp_pos_y + 1) && (x == opp_pos_x + 3)) ||
                          ((y == opp_pos_y + 1) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                          ((y == opp_pos_y + 2) && (x <= opp_pos_x - 1) && (x >= opp_pos_x - 2)) ||
                          ((y == opp_pos_y + 3) && (x <= opp_pos_x + 1) && (x >= opp_pos_x - 1)) ||
                          ((y == opp_pos_y + 4) && (x == opp_pos_x)) ||
                          ((y <= opp_pos_y + 1) && (y >= opp_pos_y - 1) && (x <= opp_pos_x + 1) && (x >= opp_pos_x)) || //u
                          ((y <= opp_pos_y + 1) && (y >= opp_pos_y) && (x == opp_pos_x -1));

    assign opp_fl_white = ((y == opp_pos_y - 4) && (x <= opp_pos_x + 2) && (x >= opp_pos_x + 1)) || //n
                           ((y == opp_pos_y - 3) && (x <= opp_pos_x + 3) && (x >= opp_pos_x + 2)) ||
                           ((y == opp_pos_y - 2) && (x <= opp_pos_x + 4) && (x >= opp_pos_x + 3)) ||
                           ((y == opp_pos_y - 1) && (x <= opp_pos_x + 5) && (x >= opp_pos_x + 4)) ||
                           ((y == opp_pos_y) && (x == opp_pos_x + 5)) ||
                           ((y == opp_pos_y + 1) && (x == opp_pos_x - 4)) ||
                           ((y == opp_pos_y + 2) && (x <= opp_pos_x - 3) && (x >= opp_pos_x - 4)) ||
                           ((y == opp_pos_y + 3) && (x <= opp_pos_x - 2) && (x >= opp_pos_x - 3)) ||
                           ((y == opp_pos_y + 4) && (x <= opp_pos_x - 1) && (x >= opp_pos_x - 2)) ||
                           ((y == opp_pos_y + 4) && (x <= opp_pos_x) && (x >= opp_pos_x - 1));
    
    always @ (posedge clk) begin
                               
       user_col <= 0;
       opp_col <= 0;
       has_opp <= 1;
       has_user <= 1;
       
       //calculate camera position
//       camera_x = user_x;
//       camera_y = user_y;
       
       //calculate map elements (relative to camera position)
//       border_x1_rel = border_x - camera_x + 48;
//       border_y1_rel = border_y - camera_y + 32;
//       border_x2_rel = border_x1_rel + 100;
//       border_y2_rel = border_y1_rel + 150;
//       pillar_x1_rel = pillar_x - camera_x + 48; 
//       pillar_y1_rel = pillar_y - camera_y + 32;
//       pillar_x2_rel = pillar_x1_rel + 30;
//       pillar_y2_rel = pillar_y1_rel + 30;
//       opp_x_cen = enemy_x - camera_x + 48;
//       opp_y_cen = enemy_y - camera_y + 32;
       
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
            
            if (border) begin
                camera <= border_c;
            end
            else if (mid_pillar || walls) begin
                camera <= wall_c;
            end
            else if (user_bullets) begin
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
//       if ((x == border_x1_rel && y < border_y2_rel && y >= border_y1_rel) ||
//           (x == border_x2_rel && y < border_y2_rel && y >= border_y1_rel) ||
//           (y == border_y1_rel && x < border_x2_rel && x >= border_x1_rel) ||
//           (y == border_y2_rel && x < border_x2_rel && x >= border_x1_rel)) begin
//           camera <= white_c;
//       end
       
//       //render pillar
//       if (x >= pillar_x1_rel && x < pillar_x2_rel &&
//           y >= pillar_y1_rel && y < pillar_y2_rel) begin
//           camera <= white_c;    
//       end
       
    end
    
endmodule
