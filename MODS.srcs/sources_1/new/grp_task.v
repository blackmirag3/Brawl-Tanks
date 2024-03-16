`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2024 23:16:44
// Design Name: 
// Module Name: grp_task
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


module grp_task(input clk, btnC, trigger, [2:0] sw, [6:0] paint_seg,
                output reg dp, output reg [6:0] seg, output reg [3:0] an,
                output reg success = 0);
                
    reg [6:0] an3_seg = 7'b0010010, an2_seg = 7'b1001111, an1_seg = 7'b1111001, an0_seg = 7'b1111000;
    reg [6:0] default_an1 = 7'b1111001, default_an0 = 7'b1111000;
    
    reg [1:0] an_step = 0;
    
    wire clk_1khz, clk_25Mhz, btn_signal;
    
    slow_clock c0 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c1 (.CLOCK(clk), .m(32'd49999), .SLOW_CLOCK(clk_1khz));
    
    debouncer d0 (.btn(btnC), .clk(clk), .signal(btn_signal));
    
    always @ (posedge clk_1khz)
    begin
        an_step <= an_step == 2'b11 ? 0 : an_step + 1;
    end
    
    always @ (posedge clk_25Mhz)
    begin
    
        if (trigger == 1) begin
        
            if (success == 0) begin
                if (sw[0] == 1) begin
                    an0_seg <= 7'b1111111;
                    an1_seg <= 7'b1111111;
                end
                if (sw[1] == 1) begin
                    an0_seg <= paint_seg;
                end
                if (sw[2] == 1) begin
                    an0_seg <= an0_seg;
                    an1_seg <= paint_seg;
                end
                
                if (btn_signal && an1_seg == default_an1 && an0_seg == default_an0) begin
                    success <= 1;
                end
            end
            else begin
                an0_seg <= default_an0;
                an1_seg <= default_an1;
            end
        
            case (an_step)
                2'b00 : begin
                    an <= 4'b1110;
                    seg <= an0_seg;
                    dp <= 1;
                end
                2'b01 : begin
                    an <= 4'b1101;
                    seg <= an1_seg;
                    dp <= 1;
                end
                2'b10 : begin
                    an <= 4'b1011;
                    seg <= an2_seg;
                    dp <= 0;
                end
                2'b11 : begin
                    an <= 4'b0111;
                    seg <= an3_seg;
                    dp <= 1;
                end
            endcase
            
        end
        else begin
            
            success <= 0;
            an0_seg <= default_an0;
            an1_seg <= default_an1;
            
        end
        
    end
    
endmodule
