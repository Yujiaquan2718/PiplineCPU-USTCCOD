`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/03/27 19:14:09
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


module RegFile (
    input                   [ 0 : 0]        clk,

    input                   [ 4 : 0]        rf_ra0,
    input                   [ 4 : 0]        rf_ra1,
    input                   [ 4 : 0]        rf_wa,
    input                   [ 0 : 0]        rf_we,
    input                   [31 : 0]        rf_wd,

    output                  [31 : 0]        rf_rd0,
    output                  [31 : 0]        rf_rd1
  );

  reg [31 : 0] reg_file [0 : 31];

  // 用于初始化寄存器
  integer i;
  initial
  begin
    for (i = 0; i < 32; i = i + 1)
      reg_file[i] = 0;
  end

  always @(posedge clk)
  begin
    if (rf_we && rf_wa)
    begin
      reg_file[rf_wa] <= rf_wd;
    end
  end

  assign rf_rd0 = reg_file[rf_ra0];
  assign rf_rd1 = reg_file[rf_ra1];

endmodule
