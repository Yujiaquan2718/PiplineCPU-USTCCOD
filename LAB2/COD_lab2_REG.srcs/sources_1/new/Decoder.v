`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/03/27 21:29:21
// Design Name:
// Module Name: Decoder
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


module Decoder(
    input   [ 1 : 0]    ctrl,
    input   enable,
    output  reg res_en,
    output  reg src0_en,
    output  reg src1_en,
    output  reg op_en
  );
  always @(*)
  begin
    res_en = 1'b0;
    src0_en = 1'b0;
    src1_en = 1'b0;
    op_en = 1'b0;
    case (ctrl)
      2'b00:
      begin
        op_en = enable;
      end
      2'b01:
      begin
        src0_en = enable;
      end
      2'b10:
      begin
        src1_en = enable;
      end
      2'b11:
      begin
        res_en = enable;
      end
    endcase
  end
endmodule
