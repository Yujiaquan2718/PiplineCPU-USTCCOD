`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/02 17:07:51
// Design Name:
// Module Name: CPU
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


module CPU(input clk,                     // Clock signal
             input rst,                     // Reset signal
             input global_en,               // Global enable signal
             output [31:0] imem_raddr,      // Address to instruction memory
             input [31:0] imem_rdata,       // Data from instruction memory
             input [31:0] dmem_rdata,       // Data from data memory
             output dmem_we,                // Data memory write enable
             output [31:0] dmem_addr,       // Address to data memory
             output [31:0] dmem_wdata,      // Data to data memory
             output [0 : 0] commit,         // Commit signal
             output [31 : 0] commit_pc,     // Program counter at commit stage
             output [31 : 0] commit_inst,   // Instruction at commit stage
             output [0 : 0] commit_halt,    // Halt signal at commit stage
             input [4 : 0] debug_reg_ra,    // Register address for debugging
             output [31 : 0] debug_reg_rd); // Register data for debugging

`define HALT_INST 32'h00100073

  // Wire declarations to connect the modules
  wire [31:0] cur_pc, curpcadd, cur_npc, pc_j, inst, alu_res, rf_wd;
  wire [4:0] alu_op;
  wire [31:0] imm;
  wire [4:0] rf_ra0, rf_ra1, rf_wa;
  wire rf_we;
  wire ifhalt;
  wire alu_src0_sel, alu_src1_sel;
  wire [31:0] rf_rd0, rf_rd1;
  wire [31:0] alu_src0, alu_src1;
  wire [3:0] dmem_access;
  wire [1:0] rf_wd_sel;
  wire [3:0] br_type;
  wire [1:0] npc_sel;
  wire [31:0] dmem_wd_out;
  wire [31:0] dmem_rd_out;
  wire [31:0] dmem_rd_in;

  // Register declarations for the commit stage
  reg  [0 : 0]   commit_reg          ;
  reg  [31 : 0]   commit_pc_reg       ;
  reg  [31 : 0]   commit_inst_reg     ;
  reg  [0 : 0]   commit_halt_reg     ;
  // reg  [0 : 0]   commit_reg_we_reg   ;
  // reg  [4 : 0]   commit_reg_wa_reg   ;
  // reg  [31 : 0]   commit_reg_wd_reg   ;
  // reg  [0 : 0]   commit_dmem_we_reg  ;
  // reg  [31 : 0]   commit_dmem_wa_reg  ;
  // reg  [31 : 0]   commit_dmem_wd_reg  ;


  // Always block for the commit stage
  always @(posedge clk)
  begin
    if (rst)
    begin
      // Reset all registers
      commit_reg      <= 1'H0;
      commit_pc_reg   <= 32'H0;
      commit_inst_reg <= 32'H0;
      commit_halt_reg <= 1'H0;
    end
    else if (global_en)
    begin
      // Update all registers
      commit_reg      <= 1'H1;
      commit_pc_reg   <= cur_pc;                       // Current PC
      commit_inst_reg <= inst;                         // Current instruction
      commit_halt_reg <= (inst == `HALT_INST);        // Check if the current instruction is HALT
    end
  end

  // Assign the outputs
  assign commit            = commit_reg;
  assign commit_pc         = commit_pc_reg;
  assign commit_inst       = commit_inst_reg;
  assign commit_halt       = commit_halt_reg;
  // assign commit_reg_we  = commit_reg_we_reg;
  // assign commit_reg_wa  = commit_reg_wa_reg;
  // assign commit_reg_wd  = commit_reg_wd_reg;
  // assign commit_dmem_we = commit_dmem_we_reg;
  // assign commit_dmem_wa = commit_dmem_wa_reg;
  // assign commit_dmem_wd = commit_dmem_wd_reg;

  // Instantiate the PC module
  // This module is responsible for updating the program counter (PC)
  PC pc_module(
       .clk(clk),          // Clock signal
       .rst(rst),          // Reset signal
       .en(global_en),     // Global enable signal
       .npc(cur_npc),      // Next program counter
       .pc(cur_pc)         // Current program counter
     );

  // Instantiate the MUX2 module for selecting the next program counter which is based on the branch type
  MUX2 #(.WIDTH(32)) npc_mux(
         .src0(curpcadd),    // Source 0: PC + 4
         .src1(alu_res),     // Source 1: Jump address, which is the result from ALU
         .src2(pc_j),        // Source 2: Jump address, which is ALU_res with the last bit as 0
         .sel(npc_sel),      // Select signal
         .res(cur_npc)       // Result: Next program counter
       );

  // Instantiate the ADD4 module
  // This module adds 4 to the current PC
  ADD4 add4_module(
         .pc_in(cur_pc),     // Input: Current PC
         .ifhalt(ifhalt),    // Input: Halt signal
         .pc_out(curpcadd)   // Output: PC + 4
       );

  // Instantiate the Branch module
  // This module determines the type of branch and the next PC
  Branch branch_module(
           .br_type(br_type),  // Branch type
           .br_src0(rf_rd0),   // Source 0 for branch comparison
           .br_src1(rf_rd1),   // Source 1 for branch comparison
           .npc_sel(npc_sel)   // Select signal for next PC
         );

  // Instantiate the Decoder module
  // This module decodes the instruction
  Decoder decoder_module(
            .inst(inst),                // Instruction
            .alu_op(alu_op),            // ALU operation
            .imm(imm),                  // Immediate value
            .rf_ra0(rf_ra0),            // Register file read address 0
            .rf_ra1(rf_ra1),            // Register file read address 1
            .rf_wa(rf_wa),              // Register file write address
            .rf_we(rf_we),              // Register file write enable
            .alu_src0_sel(alu_src0_sel),// Select signal for ALU source 0
            .alu_src1_sel(alu_src1_sel),// Select signal for ALU source 1
            .dmem_access(dmem_access),  // Data memory access type
            .rf_wd_sel(rf_wd_sel),      // Select signal for register file write data
            .br_type(br_type),          // Branch type
            .ifhalt(ifhalt)                 // Halt signal
          );

  // Instantiate the SLU module
  // This module handles the load/store operations
  SLU slu_module(
        .addr(dmem_addr),       // Address for data memory
        .dmem_access(dmem_access), // Data memory access type
        .rd_in(dmem_rd_in),     // Data read from data memory
        .wd_in(rf_rd1),         // Data to be written to data memory
        .rd_out(dmem_rd_out),   // Data read from data memory which has been dealt by SLU with load operations
        .wd_out(dmem_wd_out),   // Data to be written to data memory which has been dealt by SLU with store operations
        .dmem_we(dmem_we)       // Data memory write enable
      );

  // Instantiate the MUX2 module for selecting the data to be written to the register file
  MUX2 #(.WIDTH(32)) rf_wd_mux(
         .src0(alu_res),         // Source 0: Result from ALU
         .src1(dmem_rd_out),     // Source 1: Data read from SLU
         .src2(curpcadd),        // Source 2: PC + 4
         .src3(0),               // Source 3: 0
         .sel(rf_wd_sel),        // Select signal
         .res(rf_wd)         // Result: Data to be written to the register file
       );

  // Instantiate the Register File module
  // This module handles the read/write operations to the registers
  RegFile regfile_module(
            .clk(clk),              // Clock signal
            .rf_ra0(rf_ra0),        // Register file read address 0
            .rf_ra1(rf_ra1),        // Register file read address 1
            .rf_wa(rf_wa),          // Register file write address
            .rf_we(rf_we),          // Register file write enable
            .rf_wd(rf_wd),      // Register file write data
            .rf_rd0(rf_rd0),        // Register file read data 0
            .rf_rd1(rf_rd1),        // Register file read data 1
            .debug_reg_ra(debug_reg_ra), // Register address for debugging
            .debug_reg_rd(debug_reg_rd)  // Register data for debugging
          );

  // Instantiate the ALU module
  // This module performs the arithmetic and logic operations
  ALU alu_module(
        .alu_src0(alu_src0),    // ALU source 0
        .alu_src1(alu_src1),    // ALU source 1
        .alu_op(alu_op),        // ALU operation
        .alu_res(alu_res)       // ALU result
      );

  // Instantiate the MUX modules for selecting ALU inputs
  MUX #(.WIDTH(32)) mux0(
        .src0(rf_rd0),         // Source 0: Data read from register file
        .src1(cur_pc),         // Source 1: Current PC
        .sel(alu_src0_sel),    // Select signal
        .res(alu_src0)         // Result: ALU source 0
      );

  MUX #(.WIDTH(32)) mux1(
        .src0(rf_rd1),         // Source 0: Data read from register file
        .src1(imm),            // Source 1: Immediate value
        .sel(alu_src1_sel),    // Select signal
        .res(alu_src1)         // Result: ALU source 1
      );

  // Connect the wires to IM, DM
  assign imem_raddr = cur_pc;       // Assign the current program counter to the instruction memory read address
  assign inst       = imem_rdata;   // Assign the data read from instruction memory to the current instruction
  assign dmem_addr  = alu_res;      // Assign the result from ALU to the data memory address
  assign dmem_wdata = dmem_wd_out;  // Assign the data which has been dealt by SLU with store operations to the data memory write data
  assign dmem_rd_in = dmem_rdata;   // Assign the data read from data memory to the SLU to deal with load operations
  assign pc_j       = alu_res & 32'hFFFFFFFE; // Make the last bit of pc_j 0

  // Assign the outputs to your debug interface and memory interface
  // ...

endmodule
