`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/02 14:48:20
// Design Name:
// Module Name: MUX
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


module MUX #(parameter WIDTH = 32)
           (input [WIDTH-1 : 0] src0,
             src1,
             input [0 : 0] sel,
             output [WIDTH-1 : 0] res);
    
    assign res = sel ? src1 : src0;
    
endmodule
    
