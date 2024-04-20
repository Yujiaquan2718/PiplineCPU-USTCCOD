`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/20 13:41:37
// Design Name:
// Module Name: Intersegment_register
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

// The Intersegment Register Module. It is designed to pass the input to the output at each clock rising edge.
// Four additional interfaces are added for subsequent operations: rst, en, stall, and flush.
// rst: Synchronous reset. When this signal is high, all registers of the intersegment register will be cleared. It is connected to the CPU's rst signal.
// en: Enable signal. This allows the intersegment register to be controlled by the PDU, ensuring its synchronization with the PC register's en port. The en port of the intersegment register is also connected to global_en.
// stall: Stall signal. If this signal is high at the clock rising edge, the output will maintain the previous value unchanged, rather than receiving the input. It acts as a reverse write enable signal.
// flush: Synchronous clear. If this signal is high at the clock rising edge, all registers of the intersegment register will be cleared.

module Intersegment_register(
    input clk, rst, en, stall, flush,
    input [31:0] pcadd4_in, inst_in, pc_in, imm_in, rf_rd0_in, rf_rd1_in, alu_res_in, dmem_rd_out_in,
    input [4:0] rf_wa_in, alu_op_in,
    input [4:0] rf_ra0_in, rf_ra1_in,
    input rf_we_in, alu_src0_sel_in, alu_src1_sel_in,
    input [3:0] dmem_access_in, br_type_in,
    input [1:0] rf_wd_sel_in,
    input commit_in,
    output reg [31:0] pcadd4_out, inst_out, pc_out, imm_out, rf_rd0_out, rf_rd1_out, alu_res_out, dmem_rd_out_out,
    output reg [4:0] rf_wa_out, alu_op_out,
    output reg [4:0] rf_ra0_out, rf_ra1_out,
    output reg rf_we_out, alu_src0_sel_out, alu_src1_sel_out,
    output reg [3:0] dmem_access_out, br_type_out,
    output reg [1:0] rf_wd_sel_out,
    output reg commit_out
  );

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      // Asynchronous reset operation, clears all output registers when rst is high.
      pcadd4_out     <= 32'b0;
      inst_out       <= 32'b0;
      pc_out         <= 32'b0;
      imm_out        <= 32'b0;
      rf_rd0_out     <= 32'b0;
      rf_rd1_out     <= 32'b0;
      alu_res_out    <= 32'b0;
      dmem_rd_out_out <= 32'b0;
      rf_wa_out      <= 5'b0;
      alu_op_out     <= 5'bz;
      rf_ra0_out     <= 5'b0;
      rf_ra1_out     <= 5'b0;
      rf_we_out      <= 1'b0;
      alu_src0_sel_out <= 1'b0;
      alu_src1_sel_out <= 1'b0;
      dmem_access_out <= 4'b0;
      br_type_out    <= 4'b0;
      rf_wd_sel_out  <= 2'b11;
      commit_out     <= 1'b0;
    end
    else if (flush)
    begin
      // Clear all output registers when the flush signal is high.
      pcadd4_out     <= 32'b0;
      inst_out       <= 32'b0;
      pc_out         <= 32'b0;
      imm_out        <= 32'b0;
      rf_rd0_out     <= 32'b0;
      rf_rd1_out     <= 32'b0;
      alu_res_out    <= 32'b0;
      dmem_rd_out_out <= 32'b0;
      rf_wa_out      <= 5'b0;
      alu_op_out     <= 5'bz;
      rf_ra0_out     <= 5'b0;
      rf_ra1_out     <= 5'b0;
      rf_we_out      <= 1'b0;
      alu_src0_sel_out <= 1'b0;
      alu_src1_sel_out <= 1'b0;
      dmem_access_out <= 4'b0;
      br_type_out    <= 4'b0;
      rf_wd_sel_out  <= 2'b11;
      commit_out     <= 1'b0;
    end
    else if (en && !stall)
    begin
      // Update output registers only if the enable signal is high and not stalled.
      pcadd4_out     <= pcadd4_in;
      inst_out       <= inst_in;
      pc_out         <= pc_in;
      imm_out        <= imm_in;
      rf_rd0_out     <= rf_rd0_in;
      rf_rd1_out     <= rf_rd1_in;
      alu_res_out    <= alu_res_in;
      dmem_rd_out_out <= dmem_rd_out_in;
      rf_wa_out      <= rf_wa_in;
      alu_op_out     <= alu_op_in;
      rf_ra0_out     <= rf_ra0_in;
      rf_ra1_out     <= rf_ra1_in;
      rf_we_out      <= rf_we_in;
      alu_src0_sel_out <= alu_src0_sel_in;
      alu_src1_sel_out <= alu_src1_sel_in;
      dmem_access_out <= dmem_access_in;
      br_type_out    <= br_type_in;
      rf_wd_sel_out  <= rf_wd_sel_in;
      commit_out     <= commit_in;
    end
    // When stall is high, keep output registers unchanged.
  end

endmodule
