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


module taskB(input clk, sw0, btnC, btnL, btnR, [12:0] x, y, 
             input begin_sw, trigger,
             output reg [15:0] oled_data = 0, output reg is_running = 0);

    wire clk_25Mhz, clk_1hz, clk_1000hz;
    
    reg [31:0] taskB_count = 0;
    reg [31:0] state = 0;
    reg [31:0] border_position = 5;
    reg [31:0] colour_state = 0;

    reg [15:0] box_colour = 0;     
    
    reg [15:0] green_c = 16'b00000_111111_00000; 
    reg [15:0] red_c = 16'b11111_000000_00000; 
    reg [15:0] blue_c = 16'b00000_000000_11111;
    reg [15:0] white_c = 16'b11111_111111_11111;
    
    slow_clock c0 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c1 (.CLOCK(clk), .m(32'd49999999), .SLOW_CLOCK(clk_1hz));
    slow_clock c2 (.CLOCK(clk), .m(32'd49999), .SLOW_CLOCK(clk_1000hz));

                 
    always@(posedge clk_1hz)
    begin
        if(sw0 == 1)begin
        taskB_count <= (taskB_count == 32'd4) ? taskB_count : taskB_count + 1 ;
            if(taskB_count == 32'd4)begin
                state <= 1;
            end
        end
    end
    
    wire isUsedC, isUsedL, isUsedR;
    reg isUsed_C, isUsed_L, isUsed_R;
    debouncer d0 (.btn(btnC), .clk(clk), .signal(isUsedC));
    debouncer d1 (.btn(btnR), .clk(clk), .signal(isUsedR));
    debouncer d2 (.btn(btnL), .clk(clk), .signal(isUsedL));

    //4.B3
    always@(posedge clk_1000hz)
    begin
        if(state == 1)begin
            if((btnL == 1) && (border_position != 1) && (isUsed_L == 0)) begin
                border_position <= border_position - 1;
                end
            if((btnR == 1) && (border_position != 5) && (isUsed_R == 0)) begin
                border_position <= border_position + 1;
                end
            if((btnC == 1) && (isUsed_C == 0))begin
                colour_state <= (colour_state == 3) ? 0 : colour_state + 1 ;
                end
            case(colour_state)
                32'd0 :begin
                    box_colour <= white_c;
                    end
                32'd1 :begin
                    box_colour <= red_c;
                    end           
                32'd2 :begin
                    box_colour <= green_c;
                    end           
                32'd3 :begin
                    box_colour <= blue_c;
                    end
            endcase
            isUsed_R <= isUsedR;        
            isUsed_L <= isUsedL;        
            isUsed_C <= isUsedC;        

        end
    end
    
    
           
    always@(posedge clk_25Mhz)
    begin 
        if(trigger == 1)begin
            is_running <= 1;
                    if (begin_sw == 0) begin
                        is_running <= 0;
                    end
        
            case (state)
            32'd0000: begin
                if((x >= 41 && x <= 54 && y >= 25 && y <= 27) 
                    | (x >= 41 && x <= 54 && y >= 36 && y <= 38)
                    | (x >= 41 && x <= 43 && y >= 28 && y <= 35)
                    | (x >= 52 && x <= 54 && y >= 28 && y <= 35))
                    begin
                        oled_data <= green_c;
                    end
                else
                    begin
                        oled_data <= 16'd0;
                    end
                end
            32'd0001: begin
                case (border_position)
                32'd1: begin  //leftmost
                    if((x >= 11 && x <= 16 && y >= 29 && y <= 34) 
                    | (x >= 28 && x <= 33 && y >= 29 && y <= 34)
                    | (x >= 45 && x <= 50 && y >= 29 && y <= 34)
                    | (x >= 62 && x <= 67 && y >= 29 && y <= 34)
                    | (x >= 79 && x <= 84 && y >= 29 && y <= 34))
                        begin
                            oled_data <= box_colour;
                        end
                    else if ((x >= 7 && x <= 20 && y >= 25 && y <= 27) //top rect
                            | (x >= 7 && x <= 20 && y >= 36 && y <= 38) //bot rect
                            | (x >= 7 && x <= 9 && y >= 28 && y <= 35) //left rect
                            | (x >= 18 && x <= 20 && y >= 28 && y <= 35)) //right rect
                        begin 
                            oled_data <= green_c;
                        end
                    else
                        begin
                            oled_data <= 16'd0;
                        end        
                    end
                            
                32'd2: begin  //2ndleftmost
                    if((x >= 11 && x <= 16 && y >= 29 && y <= 34) 
                    | (x >= 28 && x <= 33 && y >= 29 && y <= 34)
                    | (x >= 45 && x <= 50 && y >= 29 && y <= 34)
                    | (x >= 62 && x <= 67 && y >= 29 && y <= 34)
                    | (x >= 79 && x <= 84 && y >= 29 && y <= 34))
                        begin
                            oled_data <= box_colour;
                        end
                    else if ((x >= 24 && x <= 37 && y >= 25 && y <= 27) //top rect
                            | (x >= 24 && x <= 37 && y >= 36 && y <= 38) //bot rect
                            | (x >= 24 && x <= 26 && y >= 28 && y <= 35) //left rect
                            | (x >= 35 && x <= 37 && y >= 28 && y <= 35)) //right rect
                        begin 
                            oled_data <= green_c;
                        end
                    else
                        begin
                            oled_data <= 16'd0;
                        end
                    end
                            
                32'd3: begin //middle
                    if((x >= 11 && x <= 16 && y >= 29 && y <= 34) 
                    | (x >= 28 && x <= 33 && y >= 29 && y <= 34)
                    | (x >= 45 && x <= 50 && y >= 29 && y <= 34)
                    | (x >= 62 && x <= 67 && y >= 29 && y <= 34)
                    | (x >= 79 && x <= 84 && y >= 29 && y <= 34))
                        begin
                            oled_data <= box_colour;
                        end
                    else if ((x >= 41 && x <= 54 && y >= 25 && y <= 27) //top rect
                            | (x >= 41 && x <= 54 && y >= 36 && y <= 38) //bot rect
                            | (x >= 41 && x <= 43 && y >= 28 && y <= 35) //left rect
                            | (x >= 52 && x <= 54 && y >= 28 && y <= 35)) //right rect
                        begin 
                            oled_data <= green_c;
                        end
                    else
                        begin
                            oled_data <= 16'd0;
                        end            
                    end
                            
                32'd4: begin //2ndrightmost
                    if((x >= 11 && x <= 16 && y >= 29 && y <= 34) 
                    | (x >= 28 && x <= 33 && y >= 29 && y <= 34)
                    | (x >= 45 && x <= 50 && y >= 29 && y <= 34)
                    | (x >= 62 && x <= 67 && y >= 29 && y <= 34)
                    | (x >= 79 && x <= 84 && y >= 29 && y <= 34))
                        begin
                            oled_data <= box_colour;
                        end
                    else if ((x >= 58 && x <= 71 && y >= 25 && y <= 27) //top rect
                            | (x >= 58 && x <= 71 && y >= 36 && y <= 38) //bot rect
                            | (x >= 58 && x <= 60 && y >= 28 && y <= 35) //left rect
                            | (x >= 69 && x <= 71 && y >= 28 && y <= 35)) //right rect
                        begin 
                            oled_data <= green_c;
                        end
                    else
                        begin
                            oled_data <= 16'd0;
                        end         
                    end 
                               
                32'd5: begin  //rightmost
                    if((x >= 11 && x <= 16 && y >= 29 && y <= 34) 
                        | (x >= 28 && x <= 33 && y >= 29 && y <= 34)
                        | (x >= 45 && x <= 50 && y >= 29 && y <= 34)
                        | (x >= 62 && x <= 67 && y >= 29 && y <= 34)
                        | (x >= 79 && x <= 84 && y >= 29 && y <= 34))
                        begin
                            oled_data <= box_colour;
                        end
                    else if ((x >= 75 && x <= 88 && y >= 25 && y <= 27) //top rect
                            | (x >= 75 && x <= 88 && y >= 36 && y <= 38) //bot rect
                            | (x >= 75 && x <= 77 && y >= 28 && y <= 35) //left rect
                            | (x >= 86 && x <= 88 && y >= 28 && y <= 35)) //right rect
                        begin 
                            oled_data <= green_c;
                        end
                    else
                        begin
                            oled_data <= 16'd0;
                        end
                    end
                    
                endcase
                end
        endcase
        end
        
        if(trigger == 0)begin
            taskB_count <= 0;
            state <= 0;
            border_position <= 5;
            colour_state <= 0;
            box_colour <= 0;     
        end
        
    end
endmodule