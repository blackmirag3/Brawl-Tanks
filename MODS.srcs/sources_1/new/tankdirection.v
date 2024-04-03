`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 23:41:02
// Design Name: 
// Module Name: tankdirection
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


module tankdirection(input btnR, btnL, RightMouse, clk, debounce,
                     output reg [3:0] state);
                     //output reg [10:0] led);
                     
    wire isUsedL, isUsedR;
    reg isUsed_L, isUsed_R;
    debouncer d1 (.btn(btnR), .clk(debounce), .signal(isUsedR));
    debouncer d2 (.btn(btnL), .clk(debounce), .signal(isUsedL));
    
always @ (posedge clk) begin
    //led [10:0] <= 0;
    if (btnR == 1 && RightMouse == 1 && isUsed_R == 0)begin
        state <= (state == 7) ? 0 : state + 1;
        end
    if (btnL == 1 && RightMouse == 1 && isUsed_L == 0)begin
        state <= (state == 0) ? 7 : state - 1;
        end
    
//    case(state)
//    4'd0 :  begin
//        led[10] <= 1;
//        led[9:0] <= 0;
//        end       
//    4'd1 :  begin
//        led[9] <= 1;
//        end  
//    4'd2 :  begin
//        led[8] <= 1;
//        end  
//    4'd3 :  begin
//        led[7] <= 1;
//        end  
//    4'd4 :  begin
//        led[6] <= 1;
//        end  
//    4'd5 :  begin
//        led[5] <= 1;
//        end  
//    4'd6 :  begin
//        led[4] <= 1;
//        end  
//    4'd7 :  begin
//        led[3] <= 1;
//        end
//    endcase
    
    isUsed_R <= isUsedR;        
    isUsed_L <= isUsedL;              
end       
       
        
endmodule
