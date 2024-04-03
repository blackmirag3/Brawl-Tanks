`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module tankPosition(input clock, 
             input [12:0] x, y, bullet_x, bullet_y,
             input [3:0] direction,
             input [2:0] movement,
             input fired,
             output reg [15:0] oled_data = 0,
             output reg [12:0] centre_x, centre_y);
    
    wire clk_50hz, clk_25Mhz;
    
    slow_clock c0 (.CLOCK(clock), .m(32'd999999), .SLOW_CLOCK(clk_50hz));
    slow_clock c1 (.CLOCK(clock), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    
    reg [15:0] box_colour = 0;     
    reg [15:0] green_c = 16'b00000_111111_00000; 
    reg [15:0] red_c = 16'b11111_000000_00000; 
    reg [15:0] blue_c = 16'b00000_000000_11111;
    reg [15:0] white_c = 16'b11111_111111_11111;
    reg grey = 16'b10111_101111_10101;


    
    always @ (posedge clk_50hz)
    begin
        
        case(direction)
        4'b0000 : begin // D position 1 (facing forward)
            case(movement)
            3'b000 : begin
                centre_x <= centre_x;
                centre_y <= centre_y;
                end
            3'b001 : begin //move forward
                centre_x <= centre_x;
                centre_y <= centre_y - 1;                   
                end   
            3'b010: begin //move backward
                centre_x <= centre_x;
                centre_y <= centre_y + 1;
                end
            3'b011: begin //move left
                centre_x <= centre_x - 1;
                centre_y <= centre_y;
                end
            3'b100: begin //move right
                centre_x <= centre_x + 1;
                centre_y <= centre_y;
                end                
            endcase
            
        end
        
        4'b0001 : begin // D position 2 (facing front-right)
            case(movement)
            3'b000 : begin // stay still
                centre_x <= centre_x;
                centre_y <= centre_y;
                end
            3'b001 : begin //move forward
                centre_x <= centre_x + 1;
                centre_y <= centre_y - 1;                   
                end   
            3'b010: begin //move backward
                centre_x <= centre_x - 1;
                centre_y <= centre_y + 1;
                end
            3'b011: begin //move left
                centre_x <= centre_x - 1;
                centre_y <= centre_y - 1;
                end
            3'b100: begin //move right
                centre_x <= centre_x + 1;
                centre_y <= centre_y + 1;
                end                
            endcase
//          
        end
        
        4'b0010 : begin // D position 3 (facing rightwards)
            case(movement)
            3'b000 : begin // stay still
                centre_x <= centre_x;
                centre_y <= centre_y;
                end
            3'b001 : begin //move forward
                centre_x <= centre_x + 1;
                centre_y <= centre_y;                   
                end   
            3'b010: begin //move backward
                centre_x <= centre_x - 1;
                centre_y <= centre_y;
                end
            3'b011: begin //move left
                centre_x <= centre_x;
                centre_y <= centre_y - 1;
                end
            3'b100: begin //move right
                centre_x <= centre_x;
                centre_y <= centre_y + 1;
                end                
            endcase
            
        end
        
        4'b0011 : begin // D position 4 (facing back-right)
            case(movement)
            3'b000 : begin // stay still
                centre_x <= centre_x;
                centre_y <= centre_y;
                end
            3'b001 : begin //move forward
                centre_x <= centre_x + 1;
                centre_y <= centre_y + 1;                   
                end   
            3'b010: begin //move backward
                centre_x <= centre_x - 1;
                centre_y <= centre_y - 1;
                end
            3'b011: begin //move left
                centre_x <= centre_x + 1;
                centre_y <= centre_y - 1;
                end
            3'b100: begin //move right
                centre_x <= centre_x - 1;
                centre_y <= centre_y + 1;
                end                
            endcase
            
        end
        
        4'b0100 : begin // D position 5 (facing backwards)
            case(movement)
            3'b000 : begin
                centre_x <= centre_x;
                centre_y <= centre_y;
                end
            3'b001 : begin //move forward
                centre_x <= centre_x;
                centre_y <= centre_y + 1;                   
                end   
            3'b010: begin //move backward
                centre_x <= centre_x;
                centre_y <= centre_y - 1;
                end
            3'b011: begin //move left
                centre_x <= centre_x + 1;
                centre_y <= centre_y;
                end
            3'b100: begin //move right
                centre_x <= centre_x - 1;
                centre_y <= centre_y;
                end                
            endcase
            
        end
        
        4'b0101 : begin // D position 6 (facing back-left)
            case(movement)
            3'b000 : begin // stay still
                centre_x <= centre_x;
                centre_y <= centre_y;
                end
            3'b001 : begin //move forward
                centre_x <= centre_x - 1;
                centre_y <= centre_y + 1;                   
                end   
            3'b010: begin //move backward
                centre_x <= centre_x + 1;
                centre_y <= centre_y - 1;
                end
            3'b011: begin //move left
                centre_x <= centre_x + 1;
                centre_y <= centre_y + 1;
                end
            3'b100: begin //move right
                centre_x <= centre_x - 1;
                centre_y <= centre_y - 1;
                end                
            endcase
            
        end
                    
        4'b0110 : begin // D position 7 (facing leftwards)
            case(movement)
            3'b000 : begin // stay still
                centre_x <= centre_x;
                centre_y <= centre_y;
                end
            3'b001 : begin //move forward
                centre_x <= centre_x - 1;
                centre_y <= centre_y;                   
                end   
            3'b010: begin //move backward
                centre_x <= centre_x + 1;
                centre_y <= centre_y;
                end
            3'b011: begin //move left
                centre_x <= centre_x;
                centre_y <= centre_y + 1;
                end
            3'b100: begin //move right
                centre_x <= centre_x;
                centre_y <= centre_y - 1;
                end                
            endcase
            
        end
        
        4'b0111 : begin // D position 8 (facing front-left)
            case(movement)
            3'b000 : begin // stay still
                centre_x <= centre_x;
                centre_y <= centre_y;
                end
            3'b001 : begin //move forward
                centre_x <= centre_x - 1;
                centre_y <= centre_y - 1;                   
                end   
            3'b010: begin //move backward
                centre_x <= centre_x + 1;
                centre_y <= centre_y + 1;
                end
            3'b011: begin //move left
                centre_x <= centre_x - 1;
                centre_y <= centre_y + 1;
                end
            3'b100: begin //move right
                centre_x <= centre_x + 1;
                centre_y <= centre_y - 1;
                end                
            endcase
            
        end
        
        endcase
    end
    
    //mapping
    
    always@(posedge clk_25Mhz)
    begin
        
        case(direction)
        4'b0000 : begin // D position 1 (facing forward)
            if((x >= centre_x -1 && x <= centre_x + 1 && y >= centre_y - 3 && y <= centre_y - 1) || //1
                (((x == centre_x + 2) || (x == centre_x - 2)) && (y == centre_y)) ||
                ((y == centre_y + 1) && (x <= centre_x - 1) && (x >= centre_x - 2)) ||
                ((y == centre_y + 1) && (x >= centre_x + 1) && (x <= centre_x + 2)) ||
                ((y == centre_y + 2) && (x <= centre_x + 1) && (x >= centre_x - 1)) )
                begin
                oled_data <= red_c;
                end
            else if(((y == centre_y - 1) && (x <= centre_x - 2) && (x >= centre_x - 3)) || //0
                ((y == centre_y - 1) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y) && ((x == centre_x - 3) || (x == centre_x + 3))) ||
                ((y == centre_y + 2) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y + 2) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y + 3) && (x <= centre_x + 3) && (x >= centre_x - 3)))
                begin
                oled_data <= blue_c;
                end
            else if((y >= centre_y) && (y <= centre_y + 1) && (x <= centre_x + 1) && (x >= centre_x - 1)) //u
                begin
                oled_data <= blue_c;
                end
            else if(((y >= centre_y - 2) && (y <= centre_y + 3) && (x <= centre_x + 5) && (x >= centre_x + 4)) ||
                ((y >= centre_y - 2) && (y <= centre_y + 3) && (x >= centre_x - 5) && (x <= centre_x - 4)))
                begin
                oled_data <= white_c;
                end
            else if(fired == 1 && x <= bullet_x + 1 && x >= bullet_x - 1 && y <= bullet_y + 1 && y >= bullet_y - 1)
                begin
                oled_data <= green_c;
                end
            else
                begin
                oled_data <= 0;
                end
        end
        
        4'b0001 : begin // D position 2 (facing front-right)
            if(((y == centre_y - 3) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y - 2) && (x >= centre_x) && (x <= centre_x + 3)) ||
                ((y == centre_y - 1) && (x >= centre_x + 1) && (x <= centre_x + 2)) ||
                ((y == centre_y) && ((x == centre_x + 2) || (x == centre_x - 2))) ||
                ((y == centre_y + 1) && (x == centre_x - 2))||
                ((y == centre_y + 2) && (x >= centre_x - 2) && (x <= centre_x)) )
                begin
                oled_data <= red_c;
                end
            else if(((y == centre_y - 3) && (x == centre_x - 1)) || //0
                ((y == centre_y - 2) && (x >= centre_x - 2) && (x <= centre_x - 1)) ||
                ((y == centre_y - 1) && (x >= centre_x - 3) && (x <= centre_x - 2)) ||
                ((y == centre_y) && (x >= centre_x - 4) && (x <= centre_x - 3)) ||
                ((y == centre_y + 1) && (x == centre_x - 3)) ||
                ((y == centre_y + 1) && (x >= centre_x + 2) && (x <= centre_x + 3)) ||
                ((y == centre_y + 2) && (x >= centre_x + 1) && (x <= centre_x + 2)) ||
                ((y == centre_y + 3) && (x >= centre_x - 1) && (x <= centre_x + 1)) ||
                ((y == centre_y + 4) && (x == centre_x)) )
                begin
                oled_data <= blue_c;
                end
            else if((y <= centre_y + 1) && (y >= centre_y - 1) && (x >= centre_x - 1) && (x <= centre_x) || //u
                    (y <= centre_y + 1) && (y >= centre_y) && (x == centre_x + 1))
                begin
                oled_data <= blue_c;
                end
            else if(((y == centre_y - 4) && (x <= centre_x - 1) && (x >= centre_x - 2)) || //n
                ((y == centre_y - 3) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y - 2) && (x <= centre_x - 3) && (x >= centre_x - 4)) ||
                ((y == centre_y - 1) && (x <= centre_x - 4) && (x >= centre_x - 5)) ||
                ((y == centre_y) && (x == centre_x - 5)) ||
                ((y == centre_y + 1) && (x == centre_x + 4)) ||
                ((y == centre_y + 2) && (x <= centre_x + 4) && (x >= centre_x + 3)) ||
                ((y == centre_y + 3) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y + 4) && (x <= centre_x + 2) && (x >= centre_x + 1)) ||
                ((y == centre_y + 4) && (x >= centre_x) && (x <= centre_x + 1)) )
                begin
                oled_data <= white_c;
                end
            else if(fired == 1 && x <= bullet_x + 1 && x >= bullet_x - 1 && y <= bullet_y + 1 && y >= bullet_y - 1)
                begin
                oled_data <= green_c;
                end
            else
                begin
                oled_data <= 0;
                end
        end
        
        4'b0010 : begin // D position 3 (facing rightwards)
            if((x >= centre_x + 1 && x <= centre_x + 3 && y <= centre_y + 1 && y >= centre_y - 1) || //1
                ((x == centre_x - 2) && (y <= centre_y + 1) && (y >= centre_y - 1)) ||
                ((y == centre_y - 2) && (x <= centre_x) && (x >= centre_x - 1)) ||
                ((y == centre_y - 3) && (x == centre_x - 1)) ||
                ((y == centre_y + 2) && (x <= centre_x) && (x >= centre_x - 1)) ||
                ((y == centre_y + 3) && (x == centre_x - 1)) )
                begin
                oled_data <= red_c;
                end
            else if(((x == centre_x - 3) && (y >= centre_y - 3) && (y <= centre_y + 3)) || //0
                ((x == centre_x - 2) && (y <= centre_y - 2) && (y >= centre_y - 3)) ||
                ((x == centre_x - 2) && (y <= centre_y + 3) && (y >= centre_y + 2)) ||
                ((x == centre_x) && (y == centre_y - 3)) ||
                ((x == centre_x) && (y == centre_y + 3)) ||
                ((x == centre_x + 1) && (y <= centre_y - 2) && (y >= centre_y - 3)) ||
                ((x == centre_x + 1) && (y <= centre_y + 3) && (y >= centre_y + 2)) )
                begin
                oled_data <= blue_c;
                end
            else if((y <= centre_y + 1) && (y >= centre_y - 1) && (x <= centre_x) && (x >= centre_x - 1)) //u
                begin
                oled_data <= blue_c;
                end
            else if(((x <= centre_x + 2) && (x >= centre_x - 3) && (y <= centre_y + 5) && (y >= centre_y + 4)) ||
                ((x <= centre_x + 2) && (x >= centre_x - 3) && (y >= centre_y - 5) && (y <= centre_y - 4)))
                begin
                oled_data <= white_c;
                end
            else if(fired == 1 && x <= bullet_x + 1 && x >= bullet_x - 1 && y <= bullet_y + 1 && y >= bullet_y - 1)
                begin
                oled_data <= green_c;
                end
            else
                begin
                oled_data <= 0;
                end
        end
        
        4'b0011 : begin // D position 4 (facing back-right)
            if(((y == centre_y + 3) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y + 2) && (x >= centre_x) && (x <= centre_x + 3)) ||
                ((y == centre_y + 1) && (x >= centre_x + 1) && (x <= centre_x + 2)) ||
                ((y == centre_y) && ((x == centre_x + 2) || (x == centre_x - 2))) ||
                ((y == centre_y - 1) && (x == centre_x - 2))||
                ((y == centre_y - 2) && (x >= centre_x - 2) && (x <= centre_x)) )
                begin
                oled_data <= red_c;
                end
            else if(((y == centre_y + 3) && (x == centre_x - 1)) || //0
                ((y == centre_y + 2) && (x >= centre_x - 2) && (x <= centre_x - 1)) ||
                ((y == centre_y + 1) && (x >= centre_x - 3) && (x <= centre_x - 2)) ||
                ((y == centre_y) && (x >= centre_x - 4) && (x <= centre_x - 3)) ||
                ((y == centre_y - 1) && (x == centre_x - 3)) ||
                ((y == centre_y - 1) && (x >= centre_x + 2) && (x <= centre_x + 3)) ||
                ((y == centre_y - 2) && (x >= centre_x + 1) && (x <= centre_x + 2)) ||
                ((y == centre_y - 3) && (x >= centre_x - 1) && (x <= centre_x + 1)) ||
                ((y == centre_y - 4) && (x == centre_x)) )
                begin
                oled_data <= blue_c;
                end
            else if((y <= centre_y + 1) && (y >= centre_y - 1) && (x >= centre_x - 1) && (x <= centre_x) || //u
                    (y >= centre_y - 1) && (y <= centre_y) && (x == centre_x + 1))
                begin
                oled_data <= blue_c;
                end
            else if(((y == centre_y + 4) && (x <= centre_x - 1) && (x >= centre_x - 2)) || //n
                ((y == centre_y + 3) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y + 2) && (x <= centre_x - 3) && (x >= centre_x - 4)) ||
                ((y == centre_y + 1) && (x <= centre_x - 4) && (x >= centre_x - 5)) ||
                ((y == centre_y) && (x == centre_x - 5)) ||
                ((y == centre_y - 1) && (x == centre_x + 4)) ||
                ((y == centre_y - 2) && (x <= centre_x + 4) && (x >= centre_x + 3)) ||
                ((y == centre_y - 3) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y - 4) && (x <= centre_x + 2) && (x >= centre_x + 1)) ||
                ((y == centre_y - 4) && (x >= centre_x) && (x <= centre_x + 1)) )
                begin
                oled_data <= white_c;
                end
            else if(fired == 1 && x <= bullet_x + 1 && x >= bullet_x - 1 && y <= bullet_y + 1 && y >= bullet_y - 1)
                begin
                oled_data <= green_c;
                end
            else
                begin
                oled_data <= 0;
                end
        end
        
        4'b0100 : begin // D position 5 (facing backwards)
            if((x >= centre_x - 1 && x <= centre_x + 1 && y <= centre_y + 3 && y >= centre_y + 1) || //1
                (((x == centre_x + 2) || (x == centre_x - 2)) && (y == centre_y)) ||
                ((y == centre_y - 1) && (x <= centre_x - 1) && (x >= centre_x - 2)) ||
                ((y == centre_y - 1) && (x >= centre_x + 1) && (x <= centre_x + 2)) ||
                ((y == centre_y - 2) && (x <= centre_x + 1) && (x >= centre_x - 1)) )
                begin
                oled_data <= red_c;
                end
            else if(((y == centre_y + 1) && (x <= centre_x - 2) && (x >= centre_x - 3)) || //0
                ((y == centre_y + 1) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y) && ((x == centre_x - 3) || (x == centre_x + 3))) ||
                ((y == centre_y - 2) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y - 2) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y - 3) && (x <= centre_x + 3) && (x >= centre_x - 3)))
                begin
                oled_data <= blue_c;
                end
            else if((y <= centre_y) && (y >= centre_y - 1) && (x <= centre_x + 1) && (x >= centre_x - 1)) //u
                begin
                oled_data <= blue_c;
                end
            else if(((y <= centre_y + 2) && (y >= centre_y - 3) && (x <= centre_x + 5) && (x >= centre_x + 4)) ||
                ((y <= centre_y + 2) && (y >= centre_y - 3) && (x >= centre_x - 5) && (x <= centre_x - 4)))
                begin
                oled_data <= white_c;
                end
            else if(fired == 1 && x <= bullet_x + 1 && x >= bullet_x - 1 && y <= bullet_y + 1 && y >= bullet_y - 1)
                begin
                oled_data <= green_c;
                end
            else
                begin
                oled_data <= 0;
                end
        end
      
        4'b0101 : begin // D position 6 (facing back-left)
            if(((y == centre_y + 3) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y + 2) && (x <= centre_x) && (x >= centre_x - 3)) ||
                ((y == centre_y + 1) && (x <= centre_x -1) && (x >= centre_x - 2)) ||
                ((y == centre_y) && ((x == centre_x - 2) || (x == centre_x + 2))) ||
                ((y == centre_y - 1) && (x == centre_x + 2))||
                ((y == centre_y - 2) && (x <= centre_x + 2) && (x >= centre_x)) )
                begin
                oled_data <= red_c;
                end
            else if(((y == centre_y + 3) && (x == centre_x + 1)) || //0
                ((y == centre_y + 2) && (x <= centre_x + 2) && (x >= centre_x + 1)) ||
                ((y == centre_y + 1) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y) && (x <= centre_x + 4) && (x >= centre_x + 3)) ||
                ((y == centre_y - 1) && (x == centre_x + 3)) ||
                ((y == centre_y - 1) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y - 2) && (x <= centre_x - 1) && (x >= centre_x - 2)) ||
                ((y == centre_y - 3) && (x <= centre_x + 1) && (x >= centre_x - 1)) ||
                ((y == centre_y - 4) && (x == centre_x)) )
                begin
                oled_data <= blue_c;
                end
            else if((y <= centre_y + 1) && (y >= centre_y - 1) && (x <= centre_x + 1) && (x >= centre_x) || //u
                    (y >= centre_y - 1) && (y <= centre_y) && (x == centre_x -1))
                begin
                oled_data <= blue_c;
                end
            else if(((y == centre_y + 4) && (x <= centre_x + 2) && (x >= centre_x + 1)) || //n
                ((y == centre_y + 3) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y + 2) && (x <= centre_x + 4) && (x >= centre_x + 3)) ||
                ((y == centre_y + 1) && (x <= centre_x + 5) && (x >= centre_x + 4)) ||
                ((y == centre_y) && (x == centre_x + 5)) ||
                ((y == centre_y - 1) && (x == centre_x - 4)) ||
                ((y == centre_y - 2) && (x <= centre_x - 3) && (x >= centre_x - 4)) ||
                ((y == centre_y - 3) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y - 4) && (x <= centre_x - 1) && (x >= centre_x - 2)) ||
                ((y == centre_y - 4) && (x <= centre_x) && (x >= centre_x - 1)) )
                begin
                oled_data <= white_c;
                end
            else if(fired == 1 && x <= bullet_x + 1 && x >= bullet_x - 1 && y <= bullet_y + 1 && y >= bullet_y - 1)
                begin
                oled_data <= green_c;
                end
            else
                begin
                oled_data <= 0;
                end
        end
                    
        4'b0110 : begin // D position 7 (facing leftwards)
                if((x <= centre_x - 1 && x >= centre_x - 3 && y <= centre_y + 1 && y >= centre_y - 1) || //1
                    ((x == centre_x + 2) && (y <= centre_y + 1) && (y >= centre_y - 1)) ||
                    ((y == centre_y - 2) && (x >= centre_x) && (x <= centre_x + 1)) ||
                    ((y == centre_y - 3) && (x == centre_x + 1)) ||
                    ((y == centre_y + 2) && (x >= centre_x) && (x <= centre_x + 1)) ||
                    ((y == centre_y + 3) && (x == centre_x + 1)) )
                    begin
                    oled_data <= red_c;
                    end
                else if(((x == centre_x + 3) && (y >= centre_y - 3) && (y <= centre_y + 3)) || //0
                    ((x == centre_x + 2) && (y <= centre_y - 2) && (y >= centre_y - 3)) ||
                    ((x == centre_x + 2) && (y <= centre_y + 3) && (y >= centre_y + 2)) ||
                    ((x == centre_x) && (y == centre_y - 3)) ||
                    ((x == centre_x) && (y == centre_y + 3)) ||
                    ((x == centre_x - 1) && (y <= centre_y - 2) && (y >= centre_y - 3)) ||
                    ((x == centre_x - 1) && (y <= centre_y + 3) && (y >= centre_y + 2)) )
                    begin
                    oled_data <= blue_c;
                    end
                else if((y <= centre_y + 1) && (y >= centre_y - 1) && (x <= centre_x + 1) && (x >= centre_x)) //u
                    begin
                    oled_data <= blue_c;
                    end
                else if(((x <= centre_x + 3) && (x >= centre_x - 2) && (y <= centre_y + 5) && (y >= centre_y + 4)) ||
                    ((x <= centre_x + 3) && (x >= centre_x - 2) && (y >= centre_y - 5) && (y <= centre_y - 4)))
                    begin
                    oled_data <= white_c;
                    end
            else if(fired == 1 && x <= bullet_x + 1 && x >= bullet_x - 1 && y <= bullet_y + 1 && y >= bullet_y - 1)
                    begin
                    oled_data <= green_c;
                    end
                else
                    begin
                    oled_data <= 0;
                    end
        end
        
        4'b0111 : begin // D position 8 (facing front-left)
            if(((y == centre_y - 3) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y - 2) && (x <= centre_x) && (x >= centre_x - 3)) ||
                ((y == centre_y - 1) && (x <= centre_x -1) && (x >= centre_x - 2)) ||
                ((y == centre_y) && ((x == centre_x - 2) || (x == centre_x + 2))) ||
                ((y == centre_y + 1) && (x == centre_x + 2))||
                ((y == centre_y + 2) && (x <= centre_x + 2) && (x >= centre_x)) )
                begin
                oled_data <= red_c;
                end
            else if(((y == centre_y - 3) && (x == centre_x + 1)) || //0
                ((y == centre_y - 2) && (x <= centre_x + 2) && (x >= centre_x + 1)) ||
                ((y == centre_y - 1) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y) && (x <= centre_x + 4) && (x >= centre_x + 3)) ||
                ((y == centre_y + 1) && (x == centre_x + 3)) ||
                ((y == centre_y + 1) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y + 2) && (x <= centre_x - 1) && (x >= centre_x - 2)) ||
                ((y == centre_y + 3) && (x <= centre_x + 1) && (x >= centre_x - 1)) ||
                ((y == centre_y + 4) && (x == centre_x)) )
                begin
                oled_data <= blue_c;
                end
            else if((y <= centre_y + 1) && (y >= centre_y - 1) && (x <= centre_x + 1) && (x >= centre_x) || //u
                    (y <= centre_y + 1) && (y >= centre_y) && (x == centre_x -1))
                begin
                oled_data <= blue_c;
                end
            else if(((y == centre_y - 4) && (x <= centre_x + 2) && (x >= centre_x + 1)) || //n
                ((y == centre_y - 3) && (x <= centre_x + 3) && (x >= centre_x + 2)) ||
                ((y == centre_y - 2) && (x <= centre_x + 4) && (x >= centre_x + 3)) ||
                ((y == centre_y - 1) && (x <= centre_x + 5) && (x >= centre_x + 4)) ||
                ((y == centre_y) && (x == centre_x + 5)) ||
                ((y == centre_y + 1) && (x == centre_x - 4)) ||
                ((y == centre_y + 2) && (x <= centre_x - 3) && (x >= centre_x - 4)) ||
                ((y == centre_y + 3) && (x <= centre_x - 2) && (x >= centre_x - 3)) ||
                ((y == centre_y + 4) && (x <= centre_x - 1) && (x >= centre_x - 2)) ||
                ((y == centre_y + 4) && (x <= centre_x) && (x >= centre_x - 1)) )
                begin
                oled_data <= white_c;
                end
            else if(fired == 1 && x <= bullet_x + 1 && x >= bullet_x - 1 && y <= bullet_y + 1 && y >= bullet_y - 1)
                begin
                oled_data <= green_c;
                end
            else
                begin
                oled_data <= 0;
                end
        end
        
        endcase

    end       
endmodule