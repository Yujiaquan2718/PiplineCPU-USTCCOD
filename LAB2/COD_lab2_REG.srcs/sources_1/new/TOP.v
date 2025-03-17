`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/03/27 21:27:52
// Design Name:
// Module Name: TOP
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


module TOP (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            enable,
    input                   [ 4 : 0]            in,
    input                   [ 1 : 0]            ctrl,

    output                  [ 3 : 0]            seg_data,
    output                  [ 2 : 0]            seg_an
  );

  wire src0_en, src1_en, op_en, res_en;
  wire [ 4 : 0] src0_data;
  wire [31 : 0] src0_data_ex;
  wire [ 4 : 0] src1_data;
  wire [31 : 0] src1_data_ex;
  wire [ 4 : 0] op_data;
  wire [ 4 : 0] res_data;
  wire [31 : 0] res_data_ex;
  wire [ 4 : 0] out_data;
  wire [31 : 0] out_data_ex;

  assign src0_data_ex[4:0]=src0_data;
  assign src0_data_ex[31:5]={27{src0_data[4]}};
  assign src1_data_ex[4:0]=src1_data;
  assign src1_data_ex[31:5]={27{src0_data[4]}};
  assign res_data = res_data_ex[4:0];
  assign out_data_ex[4:0]=out_data;
  assign out_data_ex[31:5]={27{out_data[4]}};

  Decoder decoder (
            .ctrl(ctrl),
            .enable(enable),
            .res_en(res_en),
            .src0_en(src0_en),
            .src1_en(src1_en),
            .op_en(op_en)
          );

  SingleReg src0 (
              .clk(clk),
              .en(src0_en),
              .data_in(in),
              .rst(rst),
              .data_out(src0_data)
            );

  SingleReg src1 (
              .clk(clk),
              .en(src1_en),
              .data_in(in),
              .rst(rst),
              .data_out(src1_data)
            );

  SingleReg op (
              .clk(clk),
              .en(op_en),
              .data_in(in),
              .data_out(op_data)
            );

  ALU alu (
        .alu_src0(src0_data_ex),
        .alu_src1(src1_data_ex),
        .alu_op(op_data),
        .alu_res(res_data_ex)
      );

  SingleReg res (
              .clk(clk),
              .en(res_en),
              .data_in(res_data),
              .rst(rst),
              .data_out(out_data)
            );

  Segment seg (
            .clk(clk),
            .rst(rst),
            .output_data(out_data_ex),
            .seg_data(seg_data),
            .seg_an(seg_an)
          );

endmodule

