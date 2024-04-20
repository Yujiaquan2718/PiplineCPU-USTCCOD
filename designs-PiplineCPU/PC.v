`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/01 21:16:10
// Design Name:
// Module Name: PC
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


module PC #(parameter WIDTH = 32)
  (input [0 : 0] clk,
   input [0 : 0] rst,
   input [0 : 0] en,
   input [WIDTH - 1 : 0] npc,
   input [0 : 0] stall,
   output reg [WIDTH - 1 : 0] pc);

  always @(posedge clk)
  begin
    if (en)
    begin
      if (rst)
      begin
        pc <= 32'h00400000;
      end
      else if (!stall)
        pc <= npc;
    end
  end

endmodule
