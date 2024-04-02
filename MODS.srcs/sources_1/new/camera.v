`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2024 15:08:46
// Design Name: 
// Module Name: camera
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

//for 2D brawlstars mode
module camera(
input clock,
input [2:0] player_direction,
input [7:0] player_x, player_y, enemy_x, enemy_y,
input [12:0] x, y, //for OLED
//input fov_up, fov_down, //TODO: fov increase and decrease buttons

output reg [15:0] oled_data = 0
  );
  
  
//Movement module to:
//  1. constraint players coords INSIDE map boundary - 0 < x < 100, 0 < y < 150 (cannot be on map edge)
//  2. prevent players coords from being inside 39x39 pillar (30 - 69, 55 - 94)
//      > to consider tank width
//          if tank is 3 pixels wide and player_x = 1, then render tank on top of map border at x = 0, since tank covers x = 0 to 2 wide.
//          if tank is 3 pixels wide, then | player_x - pillar_x | at least 1, otherwise overlap...

//Map is 100 * 150 pixels,
//Initialise coords of map elements

reg signed [15:0] border_x; //bottom left corner of map border. Border == 100 * 150
reg signed [15:0] border_y;
reg signed [15:0] border_x_rel; //relative coord W.R.T camera coord
reg signed [15:0] border_y_rel;

reg signed [15:0] pillar_x; //bottom left corner of pillar. Pillar == 40 * 40
reg signed [15:0] pillar_y;
reg signed [15:0] pillar_x_rel;
reg signed [15:0] pillar_y_rel;

reg signed [15:0] enemy_x_rel;
reg signed [15:0] enemy_y_rel;

//OLED display maintain center point on camera coords
//Camera coords to fix 20 pixels above tank coords.
//Map display area is 96x64 (same size as OLED)
// map_bottom_left represent bottom left corner coords of display area, to render map info only within x to x+95 and y to y + 63
//default 2d FOV of 96x74 (OLED)
//
//Initialise camera coords and map display area

reg signed [15:0] camera_x;
reg signed [15:0] camera_y;
reg map_bottom_left;

//Initialise starting positions of map elements
initial begin
    border_x = 0;
    border_y = 0;
    pillar_x = 30;
    pillar_y = 55;
end

reg [15:0] green = 16'b00000_111111_00000;
reg [15:0] orange = 16'b11111_101010_00000;
reg [15:0] red = 16'b11111_000000_00000;
reg [15:0] white = 16'b11111_111111_11111;

wire clk_1khz; 
slow_clock c0 (.CLOCK(clock), .m(32'd49999), .SLOW_CLOCK(clk_1khz));

always @ (posedge clk_1khz) begin
    
    //calculate camera position
    camera_x = player_x;
    camera_y = player_y + 20;
    
    //calculate map elements (relative to camera position)
    border_x_rel = border_x - camera_x + 48;
    border_y_rel = border_y - camera_y + 32;
    pillar_x_rel = pillar_x - camera_x + 48; 
    pillar_y_rel = pillar_y - camera_y + 32;
    enemy_x_rel = enemy_x - camera_x + 48; //TODO: check if valid -> enemy_x (8 bit unsigned) - camera_x (16 bit signed)
    enemy_y_rel = enemy_y - camera_y + 32; //TODO: check if valid
    
    //render OLED display
    //
    //render player -> account for directional sprite, centered on player_x and player_y
 
    //render enemy -> account for directional sprite, centered on player_x and player_y
    
    //render border
    if (x == border_x_rel || x == border_x_rel + 100 ||
        y == border_y_rel || y == border_y_rel + 150) begin
        oled_data <= white;
    end
    
    //render pillar
    if (x >= pillar_x_rel && x < pillar_x_rel + 30 ||
        y >= pillar_y_rel && y < pillar_y_rel + 30) begin
        oled_data <= white;    
    end
end
endmodule
