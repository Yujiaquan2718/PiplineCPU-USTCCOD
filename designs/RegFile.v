`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/01 20:47:49
// Design Name:
// Module Name: RegFile
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


module RegFile #(parameter WIDTH = 32,
                 parameter DEPTH_B = 5,
                 parameter DEPTH = 32)
                (input [0 : 0] clk,
                 input [DEPTH_B - 1 : 0] rf_ra0,
                 input [DEPTH_B - 1 : 0] rf_ra1,
                 input [DEPTH_B - 1 : 0] rf_wa,
                 input [0 : 0] rf_we,
                 input [WIDTH - 1 : 0] rf_wd,
                 input [DEPTH_B - 1 : 0] debug_reg_ra,
                 output [WIDTH - 1 : 0] rf_rd0,
                 output [WIDTH - 1 : 0] rf_rd1,
                 output [WIDTH - 1 : 0] debug_reg_rd);
    
    reg [WIDTH - 1 : 0] reg_file [0 : DEPTH - 1];
    
    // 用于初始化寄存器
    integer i;
    initial
    begin
        for (i = 0; i < DEPTH; i = i + 1)
            reg_file[i] = 0;
    end
    
    always @(posedge clk)
    begin
        if (rf_we&&rf_wa != 0)
        begin
            reg_file[rf_wa] <= rf_wd;
        end
    end
    
    assign rf_rd0       = reg_file[rf_ra0];
    assign rf_rd1       = reg_file[rf_ra1];
    assign debug_reg_rd = reg_file[debug_reg_ra];
    
endmodule
