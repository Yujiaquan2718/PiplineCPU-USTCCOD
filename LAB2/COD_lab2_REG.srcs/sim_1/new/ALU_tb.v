`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/03/27 20:10:55
// Design Name:
// Module Name: ALU_tb
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



module ALU_tb();
  reg [31:0] src0, src1;
  reg [4:0] sel;
  wire [31:0] res;
  ALU alu(
        .alu_src0(src0),
        .alu_src1(src1),
        .alu_op(sel),
        .alu_res(res)
      );
  initial
  begin
    src0=32'h009c;
    src1=32'hffffffb7;
    sel=4'H0;
    repeat(19)
    begin
      #10
       $display("src0=%h, src1=%h, sel=%h, res=%h", src0, src1, sel, res);
      sel = sel + 1;
      #20;
    end
  end
endmodule
