
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2024 16:38:48
// Design Name: 
// Module Name: task_d
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


module bullet(input clock, btnC,
             [12:0] centre_x, centre_y,
             [3:0] direction, 
             output reg fired = 0,
             output reg [12:0] bullet_x, bullet_y);

    wire clk_1khz;
    reg [31:0] counter = 0;
    reg[12:0] max_x = 96, max_y = 96, min_x = 0, min_y = 0;
    reg[3:0] bullet_state = 0;
    reg reloaded = 1;
    slow_clock cc (.CLOCK(clock), .m(32'd49999), .SLOW_CLOCK(clk_1khz));

    
    always @ (posedge clk_1khz)
    begin
        if(btnC == 1 && fired == 0 && reloaded == 1) begin
            case(direction)
            4'b0000 : begin
                bullet_x <= centre_x;
                bullet_y <= centre_y - 5;
                bullet_state <= 4'b0000;
                end
            4'b0001 : begin
                bullet_x <= centre_x + 5;
                bullet_y <= centre_y - 5;
                bullet_state <= 4'b0001;
                end
            4'b0010 : begin
                bullet_x <= centre_x + 5;
                bullet_y <= centre_y;
                bullet_state <= 4'b0010;
                end
            4'b0011 : begin
                bullet_x <= centre_x + 5;
                bullet_y <= centre_y + 5;   
                bullet_state <= 4'b0011;
                end
            4'b0100 : begin
                bullet_x <= centre_x;
                bullet_y <= centre_y + 5;
                bullet_state <= 4'b0100;
                end
            4'b0101 : begin
                bullet_x <= centre_x - 5;
                bullet_y <= centre_y + 5;
                bullet_state <= 4'b0101;
                end
            4'b0110 : begin
                bullet_x <= centre_x - 5;
                bullet_y <= centre_y;
                bullet_state <= 4'b0110;
                end
            4'b0111 : begin
                bullet_x <= centre_x - 5;
                bullet_y <= centre_y - 5;
                bullet_state <= 4'b0111;
                end
            endcase
            fired <= 1;
            reloaded <= 0;
        end
        
        counter <= (counter == 32'd20) ? 0 : counter + 1;
        if(fired == 1 && counter == 0) begin
            case(bullet_state)
            4'b0000 : begin // D position 1 (facing forward)
                bullet_x <= bullet_x;
                bullet_y <= bullet_y - 1;                   
                end
                
            4'b0001 : begin // D position 2 (facing front-right)
                bullet_x <= bullet_x + 1;
                bullet_y <= bullet_y - 1;                   
                end   
                
            4'b0010 : begin // D position 3 (facing rightwards)
                bullet_x <= bullet_x + 1;
                bullet_y <= bullet_y;                   
                end   
                    
            4'b0011 : begin // D position 4 (facing back-right)
                bullet_x <= bullet_x + 1;
                bullet_y <= bullet_y + 1;                   
                end   
                
            4'b0100 : begin // D position 5 (facing backwards)
                bullet_x <= bullet_x;
                bullet_y <= bullet_y + 1;                   
                end   
                
            4'b0101 : begin // D position 6 (facing back-left)
                bullet_x <= bullet_x - 1;
                bullet_y <= bullet_y + 1;                   
                end   
                            
            4'b0110 : begin // D position 7 (facing leftwards)
                bullet_x <= bullet_x - 1;
                bullet_y <= bullet_y;                   
                end   
                    
            4'b0111 : begin // D position 8 (facing front-left)
                bullet_x <= bullet_x - 1;
                bullet_y <= bullet_y - 1;                   
                end
                   
            endcase
        end
        
        if(bullet_x >= max_x || bullet_y >= max_y || bullet_y <= min_y || bullet_x <= min_x)
            begin
            fired <= 0;
            counter <= 0;
            end
        if(btnC == 0)begin
            reloaded <= 1;
            end 
    end

    
endmodule
