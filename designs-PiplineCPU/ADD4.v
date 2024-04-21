`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/02 16:08:30
// Design Name:
// Module Name: ADD4
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


module ADD4(input wire [31:0] pc_in,    // 当前PC值
              input stall,    // 暂停信号
              output wire [31:0] pc_out); // 下一个PC值

  assign pc_out = stall ? pc_in : pc_in + 4; // 下一个PC值为当前PC值加4

endmodule
