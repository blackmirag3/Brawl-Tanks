`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2024 11:33:52
// Design Name: 
// Module Name: camera_FPS
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

//calculates size of object using distance-based projection
//renders objects using x for horizontal displacement and y distance for render order

module camera_FPS(
input clock,
input [2:0] enemy_direction,
input [7:0] enemy_x, enemy_y,
input [7:0] pillar_x, pillar_y,
//input [7:0] border_x, border_y,
input [12:0] x, y, //for OLED
output reg [15:0] oled_data = 0
    );
    
    reg [7:0] enemy_size, pilar_size;
    
    always @ (posedge clock) begin
        //find size multiplier for objects
        //enemy_size
        
            // Rotate translated position using the lookup values for 3 bit direction orientation
        // Note: Using 8-bit LUT values extended to 16 bits for calculation
        // The >> 7 operation is to normalize the result of the multiplication
//        rel_x <= ((trans_x * cos_theta) - (trans_y * sin_theta)) >>> 7;
//        rel_y <= ((trans_x * sin_theta) + (trans_y * cos_theta)) >>> 7;
    
        //enemy closer than pillar
//        if (enemy_y < pillar_y) begin
         
//        end
        
        //pillar closer than enemy
//        else begin
        
//        end
    end
endmodule
