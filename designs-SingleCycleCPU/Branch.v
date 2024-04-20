`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/14 15:01:30
// Design Name:
// Module Name: Branch
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


module Branch(input [3:0] br_type,
              input [31:0] br_src0,
              input [31:0] br_src1,
              output reg [1:0] npc_sel);

always @(*)
begin
    npc_sel = 2'b00;
    case (br_type)
        4'b0001:
        if (br_src0 == br_src1)
        begin
            npc_sel = 2'b01;
        end
        //beq
        4'b0010:
        if (br_src0 != br_src1)
        begin
            npc_sel = 2'b01;
        end
        //bne
        4'b0011:
        if ($signed(br_src0) < $signed(br_src1))
        begin
            npc_sel = 2'b01;
        end
        //blt
        4'b0100:
        if ($signed(br_src0) >= $signed(br_src1))
        begin
            npc_sel = 2'b01;
        end
        //bge
        4'b0101:
        if (br_src0 < br_src1)
        begin
            npc_sel = 2'b01;
        end
        //bltu
        4'b0110:
        if (br_src0 >= br_src1)
        begin
            npc_sel = 2'b01;
        end
        //bgeu
        4'b1001:
        npc_sel = 2'b01;
        //jal
        4'b1000:
        npc_sel = 2'b10;
        //jalr
        default:
        ;
    endcase
end

endmodule
