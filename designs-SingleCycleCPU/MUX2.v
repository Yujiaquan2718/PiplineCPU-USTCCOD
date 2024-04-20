`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/14 15:24:54
// Design Name:
// Module Name: MUX2
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


module MUX2 #(parameter WIDTH = 32)
            (input [WIDTH-1 : 0] src0,
              src1,
              src2,
              src3,
              input [1 : 0] sel,
              output [WIDTH-1 : 0] res);
    
    assign res = sel[1] ? (sel[0] ? src3 : src2) : (sel[0] ? src1 : src0);
    
endmodule
