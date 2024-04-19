`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/01 20:58:42
// Design Name:
// Module Name: ALU
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


module ALU #(parameter DATA_WIDTH = 32,
             parameter OP_WIDTH = 5)
            (input [DATA_WIDTH - 1 : 0] alu_src0,
             input [DATA_WIDTH - 1 : 0] alu_src1,
             input [OP_WIDTH - 1 : 0] alu_op,
             output reg [DATA_WIDTH - 1 : 0] alu_res);
    
    `define ADD                 5'B00000
    `define SUB                 5'B00010
    `define SLT                 5'B00100
    `define SLTU                5'B00101
    `define AND                 5'B01001
    `define OR                  5'B01010
    `define XOR                 5'B01011
    `define SLL                 5'B01110
    `define SRL                 5'B01111
    `define SRA                 5'B10000
    `define SRC0                5'B10001
    `define SRC1                5'B10010
    
    always @(*)
    begin
        case(alu_op)
            `ADD  :
            alu_res = alu_src0 + alu_src1;
            `SUB  :
            alu_res = alu_src0 - alu_src1;
            `SLT  :
            alu_res = ($signed(alu_src0) < $signed(alu_src1));
            `SLTU :
            alu_res = (alu_src0 < alu_src1);
            `AND  :
            alu_res = alu_src0 & alu_src1;
            `OR   :
            alu_res = alu_src0 | alu_src1;
            `XOR  :
            alu_res = alu_src0 ^ alu_src1;
            `SLL  :
            alu_res = alu_src0 << alu_src1[4:0];
            `SRL  :
            alu_res = alu_src0 >> alu_src1[4:0];
            `SRA  :
            alu_res = $signed(alu_src0) >>> alu_src1[4:0];
            `SRC0 :
            alu_res = alu_src0;
            `SRC1 :
            alu_res = alu_src1;
            default :
            alu_res = 32'H0;
        endcase
    end
    
endmodule
