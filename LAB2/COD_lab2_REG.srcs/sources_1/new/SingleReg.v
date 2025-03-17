`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/03/27 22:15:19
// Design Name:
// Module Name: SingleReg
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


module SingleReg(
    input clk,
    input en,
    input [4:0] data_in,
    input rst,
    output reg [4:0] data_out
  );

  always @(posedge clk)
  begin
    if (rst)
    begin
      data_out <= 5'b0;
    end
    begin
      if (en)
      begin
        data_out <= data_in;
      end
      else
      begin
        data_out <= data_out;
      end
    end

  end
endmodule
