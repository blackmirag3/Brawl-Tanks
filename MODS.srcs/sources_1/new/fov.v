`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2024 15:21:14
// Design Name: 
// Module Name: fov
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

//calculates relative position of object W.R.T player position and player direction
//calculates whether object is within player FOV (90 degree)
module fov(
input clk,
input [7:0] player_angle, //scaled to 256 degrees from 360 degrees
input [7:0] player_x, player_y, //enemy_x, enemy_y, pillar_x, pillar_y,
input [7:0] object_x, object_y,
output reg [15:0] object_x_relative, object_y_relative
//output [7:0] enemy_x_rel, enemy_y_rel, pillar_x_rel, pillar_y_rel
);

reg signed [15:0] rel_x;
reg signed [15:0] rel_y;
reg signed [15:0] trans_x;
reg signed [15:0] trans_y;
reg signed [15:0] sin_theta;
reg signed [15:0] cos_theta;

// Sin and Cos LUTs (8-bit signed, scaled -128 to 127 for sin, 0 to 255 for angle)
reg [7:0] sin_lut[255:0];
reg [7:0] cos_lut[255:0];

// Initialize LUTs with precomputed sin and cos values
initial begin
    sin_lut[0] = 0;
    sin_lut[1] = 3;
    sin_lut[2] = 6;
    sin_lut[3] = 9;
    sin_lut[4] = 12;
    sin_lut[5] = 16;
    sin_lut[6] = 19;
    sin_lut[7] = 22;
    sin_lut[8] = 25;
    sin_lut[9] = 28;
    sin_lut[10] = 31;
    sin_lut[11] = 34;
    sin_lut[12] = 37;
    sin_lut[13] = 40;
    sin_lut[14] = 43;
    sin_lut[15] = 46;
    sin_lut[16] = 49;
    sin_lut[17] = 51;
    sin_lut[18] = 54;
    sin_lut[19] = 57;
    sin_lut[20] = 60;
    sin_lut[21] = 63;
    sin_lut[22] = 65;
    sin_lut[23] = 68;
    sin_lut[24] = 71;
    sin_lut[25] = 73;
    sin_lut[26] = 76;
    sin_lut[27] = 78;
    sin_lut[28] = 81;
    sin_lut[29] = 83;
    sin_lut[30] = 85;
    sin_lut[31] = 88;
    sin_lut[32] = 90;
    sin_lut[33] = 92;
    sin_lut[34] = 94;
    sin_lut[35] = 96;
    sin_lut[36] = 98;
    sin_lut[37] = 100;
    sin_lut[38] = 102;
    sin_lut[39] = 104;
    sin_lut[40] = 106;
    sin_lut[41] = 107;
    sin_lut[42] = 109;
    sin_lut[43] = 111;
    sin_lut[44] = 112;
    sin_lut[45] = 113;
    sin_lut[46] = 115;
    sin_lut[47] = 116;
    sin_lut[48] = 117;
    sin_lut[49] = 118;
    sin_lut[50] = 120;
    sin_lut[51] = 121;
    sin_lut[52] = 122;
    sin_lut[53] = 122;
    sin_lut[54] = 123;
    sin_lut[55] = 124;
    sin_lut[56] = 125;
    sin_lut[57] = 125;
    sin_lut[58] = 126;
    sin_lut[59] = 126;
    sin_lut[60] = 126;
    sin_lut[61] = 127;
    sin_lut[62] = 127;
    sin_lut[63] = 127;
    sin_lut[64] = 127;
    sin_lut[65] = 127;
    sin_lut[66] = 127;
    sin_lut[67] = 127;
    sin_lut[68] = 126;
    sin_lut[69] = 126;
    sin_lut[70] = 126;
    sin_lut[71] = 125;
    sin_lut[72] = 125;
    sin_lut[73] = 124;
    sin_lut[74] = 123;
    sin_lut[75] = 122;
    sin_lut[76] = 122;
    sin_lut[77] = 121;
    sin_lut[78] = 120;
    sin_lut[79] = 118;
    sin_lut[80] = 117;
    sin_lut[81] = 116;
    sin_lut[82] = 115;
    sin_lut[83] = 113;
    sin_lut[84] = 112;
    sin_lut[85] = 111;
    sin_lut[86] = 109;
    sin_lut[87] = 107;
    sin_lut[88] = 106;
    sin_lut[89] = 104;
    sin_lut[90] = 102;
    sin_lut[91] = 100;
    sin_lut[92] = 98;
    sin_lut[93] = 96;
    sin_lut[94] = 94;
    sin_lut[95] = 92;
    sin_lut[96] = 90;
    sin_lut[97] = 88;
    sin_lut[98] = 85;
    sin_lut[99] = 83;
    sin_lut[100] = 81;
    sin_lut[101] = 78;
    sin_lut[102] = 76;
    sin_lut[103] = 73;
    sin_lut[104] = 71;
    sin_lut[105] = 68;
    sin_lut[106] = 65;
    sin_lut[107] = 63;
    sin_lut[108] = 60;
    sin_lut[109] = 57;
    sin_lut[110] = 54;
    sin_lut[111] = 51;
    sin_lut[112] = 49;
    sin_lut[113] = 46;
    sin_lut[114] = 43;
    sin_lut[115] = 40;
    sin_lut[116] = 37;
    sin_lut[117] = 34;
    sin_lut[118] = 31;
    sin_lut[119] = 28;
    sin_lut[120] = 25;
    sin_lut[121] = 22;
    sin_lut[122] = 19;
    sin_lut[123] = 16;
    sin_lut[124] = 12;
    sin_lut[125] = 9;
    sin_lut[126] = 6;
    sin_lut[127] = 3;
    sin_lut[128] = 0;
    sin_lut[129] = -3;
    sin_lut[130] = -6;
    sin_lut[131] = -9;
    sin_lut[132] = -12;
    sin_lut[133] = -16;
    sin_lut[134] = -19;
    sin_lut[135] = -22;
    sin_lut[136] = -25;
    sin_lut[137] = -28;
    sin_lut[138] = -31;
    sin_lut[139] = -34;
    sin_lut[140] = -37;
    sin_lut[141] = -40;
    sin_lut[142] = -33;
    sin_lut[143] = -46;
    sin_lut[144] = -49;
    sin_lut[145] = -51;
    sin_lut[146] = -54;
    sin_lut[147] = -57;
    sin_lut[148] = -60;
    sin_lut[149] = -63;
    sin_lut[150] = -65;
    sin_lut[151] = -68;
    sin_lut[152] = -71;
    sin_lut[153] = -73;
    sin_lut[154] = -76;
    sin_lut[155] = -78;
    sin_lut[156] = -81;
    sin_lut[157] = -83;
    sin_lut[158] = -85;
    sin_lut[159] = -88;
    sin_lut[160] = -90;
    sin_lut[161] = -92;
    sin_lut[162] = -94;
    sin_lut[163] = -96;
    sin_lut[164] = -98;
    sin_lut[165] = -100;
    sin_lut[166] = -102;
    sin_lut[167] = -104;
    sin_lut[168] = -106;
    sin_lut[169] = -107;
    sin_lut[170] = -109;
    sin_lut[171] = -111;
    sin_lut[172] = -112;
    sin_lut[173] = -113;
    sin_lut[174] = -115;
    sin_lut[175] = -116;
    sin_lut[176] = -117;
    sin_lut[177] = -118;
    sin_lut[178] = -120;
    sin_lut[179] = -121;
    sin_lut[180] = -122;
    sin_lut[181] = -122;
    sin_lut[182] = -123;
    sin_lut[183] = -124;
    sin_lut[184] = -125;
    sin_lut[185] = -125;
    sin_lut[186] = -126;
    sin_lut[187] = -126;
    sin_lut[188] = -126;
    sin_lut[189] = -127;
    sin_lut[190] = -127;
    sin_lut[191] = -127;
    sin_lut[192] = -127;
    sin_lut[193] = -127;
    sin_lut[194] = -127;
    sin_lut[195] = -127;
    sin_lut[196] = -126;
    sin_lut[197] = -126;
    sin_lut[198] = -126;
    sin_lut[199] = -125;
    sin_lut[200] = -125;
    sin_lut[201] = -124;
    sin_lut[202] = -123;
    sin_lut[203] = -122;
    sin_lut[204] = -122;
    sin_lut[205] = -121;
    sin_lut[206] = -120;
    sin_lut[207] = -118;
    sin_lut[208] = -117;
    sin_lut[209] = -116;
    sin_lut[210] = -115;
    sin_lut[211] = -113;
    sin_lut[212] = -112;
    sin_lut[213] = -111;
    sin_lut[214] = -109;
    sin_lut[215] = -107;
    sin_lut[216] = -106;
    sin_lut[217] = -104;
    sin_lut[218] = -102;
    sin_lut[219] = -100;
    sin_lut[220] = -98;
    sin_lut[221] = -96;
    sin_lut[222] = -94;
    sin_lut[223] = -92;
    sin_lut[224] = -90;
    sin_lut[225] = -88;
    sin_lut[226] = -85;
    sin_lut[227] = -83;
    sin_lut[228] = -81;
    sin_lut[229] = -78;
    sin_lut[230] = -76;
    sin_lut[231] = -73;
    sin_lut[232] = -71;
    sin_lut[233] = -68;
    sin_lut[234] = -65;
    sin_lut[235] = -63;
    sin_lut[236] = -60;
    sin_lut[237] = -57;
    sin_lut[238] = -54;
    sin_lut[239] = -51;
    sin_lut[240] = -49;
    sin_lut[241] = -46;
    sin_lut[242] = -43;
    sin_lut[243] = -40;
    sin_lut[244] = -37;
    sin_lut[245] = -34;
    sin_lut[246] = -31;
    sin_lut[247] = -28;
    sin_lut[248] = -25;
    sin_lut[249] = -22;
    sin_lut[250] = -19;
    sin_lut[251] = -16;
    sin_lut[252] = -12;
    sin_lut[253] = -9;
    sin_lut[254] = -6;
    sin_lut[255] = -3;	

    cos_lut[0] = 127;
    cos_lut[1] = 127;
    cos_lut[2] = 127;
    cos_lut[3] = 127;
    cos_lut[4] = 126;
    cos_lut[5] = 126;
    cos_lut[6] = 126;
    cos_lut[7] = 125;
    cos_lut[8] = 125;
    cos_lut[9] = 124;
    cos_lut[10] = 123;
    cos_lut[11] = 122;
    cos_lut[12] = 122;
    cos_lut[13] = 121;
    cos_lut[14] = 120;
    cos_lut[15] = 118;
    cos_lut[16] = 117;
    cos_lut[17] = 116;
    cos_lut[18] = 115;
    cos_lut[19] = 113;
    cos_lut[20] = 112;
    cos_lut[21] = 111;
    cos_lut[22] = 109;
    cos_lut[23] = 107;
    cos_lut[24] = 106;
    cos_lut[25] = 104;
    cos_lut[26] = 102;
    cos_lut[27] = 100;
    cos_lut[28] = 98;
    cos_lut[29] = 96;
    cos_lut[30] = 94;
    cos_lut[31] = 92;
    cos_lut[32] = 90;
    cos_lut[33] = 88;
    cos_lut[34] = 85;
    cos_lut[35] = 83;
    cos_lut[36] = 81;
    cos_lut[37] = 78;
    cos_lut[38] = 76;
    cos_lut[39] = 73;
    cos_lut[40] = 71;
    cos_lut[41] = 68;
    cos_lut[42] = 65;
    cos_lut[43] = 63;
    cos_lut[44] = 60;
    cos_lut[45] = 57;
    cos_lut[46] = 54;
    cos_lut[47] = 51;
    cos_lut[48] = 49;
    cos_lut[49] = 46;
    cos_lut[50] = 43;
    cos_lut[51] = 40;
    cos_lut[52] = 37;
    cos_lut[53] = 34;
    cos_lut[54] = 31;
    cos_lut[55] = 28;
    cos_lut[56] = 25;
    cos_lut[57] = 22;
    cos_lut[58] = 19;
    cos_lut[59] = 16;
    cos_lut[60] = 12;
    cos_lut[61] = 9;
    cos_lut[62] = 6;
    cos_lut[63] = 3;
    cos_lut[64] = 0;
    cos_lut[65] = -3;
    cos_lut[66] = -6;
    cos_lut[67] = -9;
    cos_lut[68] = -12;
    cos_lut[69] = -16;
    cos_lut[70] = -19;
    cos_lut[71] = -22;
    cos_lut[72] = -25;
    cos_lut[73] = -28;
    cos_lut[74] = -31;
    cos_lut[75] = -34;
    cos_lut[76] = -37;
    cos_lut[77] = -40;
    cos_lut[78] = -43;
    cos_lut[79] = -46;
    cos_lut[80] = -49;
    cos_lut[81] = -51;
    cos_lut[82] = -54;
    cos_lut[83] = -57;
    cos_lut[84] = -60;
    cos_lut[85] = -63;
    cos_lut[86] = -65;
    cos_lut[87] = -68;
    cos_lut[88] = -71;
    cos_lut[89] = -73;
    cos_lut[90] = -76;
    cos_lut[91] = -78;
    cos_lut[92] = -81;
    cos_lut[93] = -83;
    cos_lut[94] = -85;
    cos_lut[95] = -88;
    cos_lut[96] = -90;
    cos_lut[97] = -92;
    cos_lut[98] = -94;
    cos_lut[99] = -96;
    cos_lut[100] = -98;
    cos_lut[101] = -100;
    cos_lut[102] = -102;
    cos_lut[103] = -104;
    cos_lut[104] = -106;
    cos_lut[105] = -107;
    cos_lut[106] = -109;
    cos_lut[107] = -111;
    cos_lut[108] = -112;
    cos_lut[109] = -113;
    cos_lut[110] = -115;
    cos_lut[111] = -116;
    cos_lut[112] = -117;
    cos_lut[113] = -118;
    cos_lut[114] = -120;
    cos_lut[115] = -121;
    cos_lut[116] = -122;
    cos_lut[117] = -122;
    cos_lut[118] = -123;
    cos_lut[119] = -124;
    cos_lut[120] = -125;
    cos_lut[121] = -125;
    cos_lut[122] = -126;
    cos_lut[123] = -126;
    cos_lut[124] = -126;
    cos_lut[125] = -127;
    cos_lut[126] = -127;
    cos_lut[127] = -127;
    cos_lut[128] = -127;
    cos_lut[129] = -127;
    cos_lut[130] = -127;
    cos_lut[131] = -127;
    cos_lut[132] = -126;
    cos_lut[133] = -126;
    cos_lut[134] = -126;
    cos_lut[135] = -125;
    cos_lut[136] = -125;
    cos_lut[137] = -124;
    cos_lut[138] = -123;
    cos_lut[139] = -122;
    cos_lut[140] = -122;
    cos_lut[141] = -121;
    cos_lut[142] = -120;
    cos_lut[143] = -118;
    cos_lut[144] = -117;
    cos_lut[145] = -116;
    cos_lut[146] = -115;
    cos_lut[147] = -113;
    cos_lut[148] = -112;
    cos_lut[149] = -111;
    cos_lut[150] = -109;
    cos_lut[151] = -107;
    cos_lut[152] = -106;
    cos_lut[153] = -104;
    cos_lut[154] = -102;
    cos_lut[155] = -100;
    cos_lut[156] = -98;
    cos_lut[157] = -96;
    cos_lut[158] = -94;
    cos_lut[159] = -92;
    cos_lut[160] = -90;
    cos_lut[161] = -88;
    cos_lut[162] = -85;
    cos_lut[163] = -83;
    cos_lut[164] = -81;
    cos_lut[165] = -78;
    cos_lut[166] = -76;
    cos_lut[167] = -73;
    cos_lut[168] = -71;
    cos_lut[169] = -68;
    cos_lut[170] = -65;
    cos_lut[171] = -63;
    cos_lut[172] = -60;
    cos_lut[173] = -57;
    cos_lut[174] = -54;
    cos_lut[175] = -51;
    cos_lut[176] = -49;
    cos_lut[177] = -46;
    cos_lut[178] = -43;
    cos_lut[179] = -40;
    cos_lut[180] = -37;
    cos_lut[181] = -34;
    cos_lut[182] = -31;
    cos_lut[183] = -28;
    cos_lut[184] = -25;
    cos_lut[185] = -22;
    cos_lut[186] = -19;
    cos_lut[187] = -16;
    cos_lut[188] = -12;
    cos_lut[189] = -9;
    cos_lut[190] = -6;
    cos_lut[191] = -3;
    cos_lut[192] = -0;
    cos_lut[193] = 3;
    cos_lut[194] = 6;
    cos_lut[195] = 9;
    cos_lut[196] = 12;
    cos_lut[197] = 16;
    cos_lut[198] = 19;
    cos_lut[199] = 22;
    cos_lut[200] = 25;
    cos_lut[201] = 28;
    cos_lut[202] = 31;
    cos_lut[203] = 34;
    cos_lut[204] = 37;
    cos_lut[205] = 40;
    cos_lut[206] = 43;
    cos_lut[207] = 46;
    cos_lut[208] = 49;
    cos_lut[209] = 51;
    cos_lut[210] = 54;
    cos_lut[211] = 57;
    cos_lut[212] = 60;
    cos_lut[213] = 63;
    cos_lut[214] = 65;
    cos_lut[215] = 68;
    cos_lut[216] = 71;
    cos_lut[217] = 73;
    cos_lut[218] = 76;
    cos_lut[219] = 78;
    cos_lut[220] = 81;
    cos_lut[221] = 83;
    cos_lut[222] = 85;
    cos_lut[223] = 88;
    cos_lut[224] = 90;
    cos_lut[225] = 92;
    cos_lut[226] = 94;
    cos_lut[227] = 96;
    cos_lut[228] = 98;
    cos_lut[229] = 100;
    cos_lut[230] = 102;
    cos_lut[231] = 104;
    cos_lut[232] = 106;
    cos_lut[233] = 107;
    cos_lut[234] = 109;
    cos_lut[235] = 111;
    cos_lut[236] = 112;
    cos_lut[237] = 113;
    cos_lut[238] = 115;
    cos_lut[239] = 116;
    cos_lut[240] = 117;
    cos_lut[241] = 118;
    cos_lut[242] = 120;
    cos_lut[243] = 121;
    cos_lut[244] = 122;
    cos_lut[245] = 122;
    cos_lut[246] = 123;
    cos_lut[247] = 124;
    cos_lut[248] = 125;
    cos_lut[249] = 125;
    cos_lut[250] = 126;
    cos_lut[251] = 126;
    cos_lut[252] = 126;
    cos_lut[253] = 127;
    cos_lut[254] = 127;
    cos_lut[255] = 127;
end

always @(posedge clk) begin
    // Translate object position to be relative to player position
    trans_x = object_x - player_x;
    trans_y = object_y - player_y;

    // Lookup sin and cos values for the player's current angle
    sin_theta = sin_lut[player_angle];
    cos_theta = cos_lut[player_angle];

    // Rotate translated position using the lookup values
    // Note: Using 8-bit LUT values extended to 16 bits for calculation
    // The >> 7 operation is to normalize the result of the multiplication
    rel_x <= ((trans_x * cos_theta) - (trans_y * sin_theta)) >>> 7;
    rel_y <= ((trans_x * sin_theta) + (trans_y * cos_theta)) >>> 7;
    
    //for 90 degree FOV
    //-45 deg < arctan( Rx / Ry) < 45 deg
    //.: -Ry < Rx < Ry, where tan(45 deg) = 1;
    
    //object behind player
    if (rel_y < 0) begin
        object_y_relative <= 0;
        object_x_relative <= 0;
    end
    //object in front of player, within 90 degree FOV
    else if (-rel_y < rel_x && rel_x < rel_y) begin
        object_y_relative <= rel_y;
        object_x_relative <= rel_x;
    end  
    //object in front of player, outside 90 degree FOV
    else begin
        object_y_relative <= 0;
        object_x_relative <= 0;
    end
end
endmodule