
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


module tankMovement(input btnR, btnL, btnU, btnD, RightMouse, clk, debounce,
                     output reg [2:0] movement); 
                     //output reg [4:0] led

    wire isUsedMouse, isUsedL, isUsedR, isUsedD, isUsedU;
    reg isUsed_Mouse, isUsed_L, isUsed_R, isUsed_D, isUsed_U;


always @ (posedge clk) begin
    if (btnU == 1 && RightMouse == 0)begin
        movement <= 1;
        //led[1] <= 1;
    end
    else if (btnD == 1 && RightMouse == 0)begin
        movement <= 2;
        //led[2] <= 1;
    end
    else if (btnR == 1 && RightMouse == 0)begin
        movement <= 4;
        //led[4] <= 1;
        end
    else if (btnL == 1 && RightMouse == 0)begin
        movement <= 3;
        //led[3] <= 1;
        end
    else begin
        movement <= 0;
        //led[0] <= 1;
        //led[4:1] <= 0;
        end
          
end              
       
endmodule
