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


module temp_cam(input clk, input [12:0] x, y, input [7:0] user_x_cen, user_y_cen, opp_x_cen, opp_y_cen,
                input [2:0] user_dir, opp_dir,
                output reg [15:0] camera = 0);
                
    reg [15:0] box_colour = 0;     
    reg [15:0] green_c = 16'b00000_111111_00000; 
    reg [15:0] red_c = 16'b11111_000000_00000; 
    reg [15:0] blue_c = 16'b00000_000000_11111;
    reg [15:0] purple_c = 16'b11111_000000_11111;
    reg [15:0] white_c = 16'b11111_111111_11111;
    
    reg [15:0] user_col = 0, opp_col = 0;
    reg has_user = 0, has_opp = 0;
    
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
        has_opp <= 1;
        has_user <= 1;

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
                    user_col <= 0;
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
                    user_col <= 0;
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
                    user_col <= 0;
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
                    user_col <= 0;
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
                    user_col <= 0;
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
                    user_col <= 0;
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
                    user_col <= 0;
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
                    user_col <= 0;
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
                    opp_col <= 0;
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
                    opp_col <= 0;
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

        camera <= has_user ? user_col : opp_col;
    end
    

endmodule
