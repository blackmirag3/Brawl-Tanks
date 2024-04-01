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


module camera(
input clock,
 [12:0] oled_x, oled_y ,
 [7:0] player_x, player_y, enemy_x, enemy_y, pillar_x, pillar_y, //map is 150 * 100 pixels, 
 output reg [15:0] oled_data = 0
  );

reg [15:0] green = 16'b00000_111111_00000;
reg [15:0] orange = 16'b11111_101010_00000;
reg [15:0] red = 16'b11111_000000_00000;
wire clk_1khz;
slow_clock c0 (.CLOCK(clock), .m(32'd49999), .SLOW_CLOCK(clk_1khz));

always @ (posedge clk_1khz) begin


end
endmodule
