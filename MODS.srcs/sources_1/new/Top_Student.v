`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: Siew Shui Hon
//  STUDENT B NAME: Timothy Lau Kah Ming
//  STUDENT C NAME: 
//  STUDENT D NAME: Sim Jing Jie Ryan 
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input clk, btnC, btnU, btnL, btnR, btnD, [15:0] sw, 
                    inout PS2Clk, PS2Data,
                    output [7:0] JC, [15:0] led, 
                    output reg [6:0] seg = 7'b1111111, output reg [3:0] an, output reg dp = 1);
    
    wire clk_6p25Mhz, clk_12p5Mhz, clk_25Mhz, slow_clk;
    wire fb, send_pixel, sample_pixel;
    reg [15:0] oled_data;
    wire [12:0] pixel_index, x, y;
    
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire left, middle, right, m_event;
    
    reg [2:0] demo_state = 0;
    reg trigger_a = 0, trigger_b = 0, trigger_d = 0, trigger_grp = 0;
    wire a_running, b_running, d_running, grp_running;
    wire [15:0] a_oled, b_oled, d_oled, grp_oled;
    
    wire [6:0] paint_seg, task_seg;
    wire [3:0] task_an;
    wire task_dp, grp_success;
    reg paint_rst = 1;
    reg [15:0] green_success = 16'b00000_111111_00000;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    assign led[3:0] = sw[4:1];
    
    slow_clock c0 (.CLOCK(clk), .m(32'd7), .SLOW_CLOCK(clk_6p25Mhz));
    slow_clock c1 (.CLOCK(clk), .m(32'd3), .SLOW_CLOCK(clk_12p5Mhz));
    slow_clock c2 (.CLOCK(clk), .m(32'd1), .SLOW_CLOCK(clk_25Mhz));
    slow_clock c3 (.CLOCK(clk), .m(32'd49999999), .SLOW_CLOCK(slow_clk));
    
    Oled_Display unit_oled (.clk(clk_6p25Mhz), 
                        .reset(0), 
                        .frame_begin(fb), 
                        .sending_pixels(send_pixel),
                        .sample_pixel(sample_pixel), 
                        .pixel_index(pixel_index), 
                        .pixel_data(oled_data), 
                        .cs(JC[0]), 
                        .sdin(JC[1]), 
                        .sclk(JC[3]), 
                        .d_cn(JC[4]), 
                        .resn(JC[5]), 
                        .vccen(JC[6]),
                        .pmoden(JC[7]));
                        
    MouseCtl mouse_unit (.clk(clk),
                        .rst(0),
                        .value(0),
                        .setx(0),
                        .sety(0),
                        .setmax_x(0),
                        .setmax_y(0),
                        .xpos(xpos),
                        .ypos(ypos),
                        .zpos(zpos),
                        .left(left),
                        .middle(middle),
                        .right(right),
                        .new_event(m_event),
                        .ps2_clk(PS2Clk),
                        .ps2_data(PS2Data));
                        
    paint paint_unit (.clk_100M(clk),
                        .clk_25M(clk_25Mhz),
                        .clk_12p5M(clk_12p5Mhz),
                        .clk_6p25M(clk_6p25Mhz),
                        .slow_clk(slow_clk),
                        .mouse_l(left),
                        .reset(paint_rst),
                        .enable(1),
                        .mouse_x(xpos),
                        .mouse_y(ypos),
                        .pixel_index(pixel_index),
                        .led(),
                        .seg(paint_seg),
                        .colour_chooser(grp_oled));
               
    taskB b_unit (.clk(clk), .sw0(sw[0]), .x(x), .y(y), .oled_data(b_oled), .btnC(btnC), .btnR(btnR), .btnL(btnL),
                    .begin_sw(sw[2]), .trigger(trigger_b), .is_running(b_running));
                        
    task_d d_unit (.clock(clk), .start(btnC), .up(btnU), .left(btnL), .right(btnR), .speed_sw(sw[0]), .x(x), .y(y), 
                    .begin_sw(sw[4]), .trigger(trigger_d), .oled_data(d_oled), .is_running(d_running));
                    
    grp_task grp_unit (.clk(clk), .btnC(btnC), .sw(sw[15:13]), .paint_seg(paint_seg), .trigger(trigger_grp),
                        .dp(task_dp), .seg(task_seg), .an(task_an), .success(grp_success));
                    
    always @ (posedge clk_12p5Mhz)
    begin
        case (demo_state)
            3'd0 : begin
                seg <= 7'b1111111;
                an <= 4'b1111;
                oled_data <= 16'hffff;
                paint_rst <= 1;
                if (sw[1] == 1) demo_state <= 3'd1;
                if (sw[2] == 1) demo_state <= 3'd2;
                if (sw[4] == 1) demo_state <= 3'd3;
                if (sw[5] == 1) demo_state <= 3'd4;
            end
            3'd1 : oled_data <= 0;
            3'd2 : begin
                oled_data <= b_oled;
                trigger_b <= 1;
                if (trigger_b == 1 && b_running == 0) begin
                    trigger_b <= 0;
                    demo_state <= 0;
                end
            end
            3'd3 : begin
                oled_data <= d_oled;
                trigger_d <= 1;
                if (trigger_d == 1 && d_running == 0) begin
                    trigger_d <= 0;
                    demo_state <= 0;
                end
            end
            3'd4 : begin
                paint_rst <= right;
                oled_data <= grp_oled;
                trigger_grp <= 1;
                if (trigger_grp == 1 && sw[5] == 0) begin
                    trigger_grp <= 0;
                    demo_state <= 0;
                end
                
                an <= task_an;
                seg <= task_seg;
                dp <= task_dp;
                if (grp_success == 1) begin
                    oled_data <= green_success;
                end
            end
        endcase
    end
                        
endmodule