`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/10 21:29:59
// Design Name:
// Module Name: Decoder_testbench
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


module Decoder_testbench();

  // 输入
  reg [31:0] inst;

  // 输出
  wire [4:0] alu_op;
  wire [31:0] imm;
  wire [4:0] rf_ra0, rf_ra1, rf_wa;
  wire rf_we;
  wire alu_src0_sel, alu_src1_sel;
  wire [3:0] dmem_access;
  wire [3:0] br_type;
  wire [1:0] rf_wd_sel;

  // 实例化Decoder模块
  Decoder uut (
            .inst(inst),
            .alu_op(alu_op),
            .imm(imm),
            .rf_ra0(rf_ra0),
            .rf_ra1(rf_ra1),
            .rf_wa(rf_wa),
            .rf_we(rf_we),
            .alu_src0_sel(alu_src0_sel),
            .alu_src1_sel(alu_src1_sel),
            .dmem_access(dmem_access),
            .br_type(br_type),
            .rf_wd_sel(rf_wd_sel)
          );

  initial
  begin
    // 初始化
    inst = 32'b0;
    #100; // 等待100ns观察

    // // R类型指令测试用例: add rd, rs1, rs2
    // // add x10, x20, x30
    // // rs1 = x20, rs2 = x30, rd = x10
    // inst = 32'b0000000_11110_10100_000_01010_0110011;
    // #10; // 等待10ns观察

    // // R类型指令测试用例: sub rd, rs1, rs2
    // // sub x10, x20, x30
    // // rs1 = x20, rs2 = x30, rd = x10
    // inst = 32'b0100000_11110_10100_000_01010_0110011;
    // #10; // 等待10ns观察

    // // I类型指令测试用例: ori rd, rs1, imm
    // // ori x10, x20, 0x64
    // // rs1 = x20, imm = 100 (0x64), rd = x10
    // inst = 32'b000001100100_10100_110_01010_0010011;
    // #10;

    // // I类型指令测试用例: slli rd, rs1, shamt
    // // slli x10, x20, 0x1
    // // rs1 = x20, shamt = 1, rd = x10
    // inst = 32'b0000000_00001_10100_001_01010_0010011;
    // #10;

    // // U类型指令测试用例: lui rd, imm
    // // lui x10, 0x12345
    // // imm = 0x12345000, rd = x10
    // inst = 32'b00010010001101000101_01010_0110111;
    // #10;

    // // U类型指令测试用例: auipc rd, imm
    // // auipc x10, 0x12345
    // // imm = 0x12345000, rd = x10
    // inst = 32'b00010010001101000101_01010_0010111;
    // #10;

    // S类型指令测试用例: sw rs2, imm(rs1)
    // sw x30, 0x10(x20)
    // rs1 = x20, rs2 = x30, imm = 0x10
    inst = 32'b0000000_11110_10100_010_01010_0100011;
    #10;

    // S类型指令测试用例: sb rs2, imm(rs1)
    // sb x30, 0x10(x20)
    // rs1 = x20, rs2 = x30, imm = 0x10
    inst = 32'b0000000_11110_10100_000_01010_0100011;
    #10;

    // B类型指令测试用例: beq rs1, rs2, imm
    // beq x20, x30, 0x10
    // rs1 = x20, rs2 = x30, imm = 0x10
    inst = 32'b0000000_11110_10100_000_01010_1100011;
    #10;

    // B类型指令测试用例: bne rs1, rs2, imm
    // bne x20, x30, 0x10
    // rs1 = x20, rs2 = x30, imm = 0x10
    inst = 32'b0000000_11110_10100_001_01010_1100011;
    #10;

    // J类型指令测试用例: jal rd, imm
    // jal x10, 0x10
    // imm = 0x10, rd = x10
    inst = 32'b00000000000000000001_01010_1101111;
    #10;

    // J类型指令测试用例: jalr rd, rs1, imm
    // jalr x10, x20, 0x10
    // rs1 = x20, imm = 0x10, rd = x10
    inst = 32'b0000000_11110_10100_000_01010_1100111;
    #10;

    // L类型指令测试用例: lw rd, imm(rs1)
    // lw x10, 0x10(x20)
    // rs1 = x20, imm = 0x10, rd = x10
    inst = 32'b000000011110_10100_010_01010_0000011;
    #10;

    // L类型指令测试用例: lb rd, imm(rs1)
    // lb x10, 0x10(x20)
    // rs1 = x20, imm = 0x10, rd = x10
    inst = 32'b0000000_11110_10100_000_01010_0000011;
    #10;

    // 测试结束
    $finish;
  end

endmodule
