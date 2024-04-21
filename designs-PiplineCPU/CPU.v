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

  // Wire and signals declarations to connect the modules within the stage for the pipeline CPU
  wire [31:0] pc_if, pcadd4_if, npc_ex, pc_j, inst_if, rf_wd;
  wire [4:0] rf_ra0_id, rf_ra1_id, rf_ra0_ex, rf_ra1_ex;
  wire ifhalt;
  wire [31:0] alu_src0, alu_src1;
  wire [1:0] npc_sel;
  wire [31:0] dmem_wd_out;
  wire [31:0] dmem_rd_in;
  wire [31:0] inst_id, pcadd4_id, pc_id, imm_id, rf_rd0_id, rf_rd1_id;
  wire [ 4:0] rf_wa_id, alu_op_id;
  wire rf_we_id, alu_src0_sel_id, alu_src1_sel_id;
  wire [ 3:0] dmem_access_id, br_type_id;
  wire [ 1:0] rf_wd_sel_id;
  wire [31:0] pcadd4_ex, pc_ex, imm_ex, rf_rd0_ex, rf_rd1_ex, rf_rd0_ex_df, rf_rd1_ex_df, alu_res_ex;
  wire [ 4:0] rf_wa_ex, alu_op_ex;
  wire rf_we_ex, alu_src0_sel_ex, alu_src1_sel_ex;
  wire [ 3:0] dmem_access_ex, br_type_ex;
  wire [ 1:0] rf_wd_sel_ex;
  wire [31:0] pcadd4_mem, alu_res_mem, rf_rd1_mem, dmem_rd_out_mem;
  wire [ 4:0] rf_wa_mem;
  wire rf_we_mem;
  wire [ 3:0] dmem_access_mem;
  wire [ 1:0] rf_wd_sel_mem;
  wire [31:0] pcadd4_wb, alu_res_wb, dmem_rd_out_wb;
  wire [ 4:0] rf_wa_wb;
  wire rf_we_wb;
  wire [ 1:0] rf_wd_sel_wb;
  wire stall_pc, stall_if2id, flush_if2id, flush_id2ex;

  // Register declarations for the commit stage
  reg  [0 : 0]   commit_reg          ;
  reg  [31 : 0]   commit_pc_reg       ;
  reg  [31 : 0]   commit_inst_reg     ;
  reg  [0 : 0]   commit_halt_reg     ;
  wire commit_if, commit_id, commit_ex, commit_mem, commit_wb;
  wire [31 : 0]  pc_mem, pc_wb, inst_ex, inst_mem, inst_wb;


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
      commit_reg      <= commit_wb;
      commit_pc_reg   <= pc_wb;                       // Current PC
      commit_inst_reg <= inst_wb;                         // Current instruction
      commit_halt_reg <= (inst_wb == `HALT_INST);        // Check if the current instruction is HALT
    end
  end

  // Assign the outputs of the commit stage
  assign commit            = commit_reg;
  assign commit_pc         = commit_pc_reg;
  assign commit_inst       = commit_inst_reg;
  assign commit_halt       = commit_halt_reg;



  // The Instruction Fetch Stage

  assign commit_if = 1'b1; // Commit signal for the IF stage

  // Instantiate the PC module
  // This module is responsible for updating the program counter (PC)
  PC pc_module(
       .clk(clk),          // Clock signal
       .rst(rst),          // Reset signal
       .en(global_en),     // Global enable signal
       .npc(npc_ex),      // Next program counter
       .pc(pc_if)         // Current program counter
     );

  // Instantiate the ADD4 module
  // This module adds 4 to the current PC
  ADD4 add4_module(
         .pc_in(pc_if),     // Input: Current PC
         .stall(stall_pc || ifhalt),  // Stall signal
         .pc_out(pcadd4_if)   // Output: PC + 4
       );

  // Connect to Instruction Memory
  assign imem_raddr = pc_if;       // Assign the current program counter to the instruction memory read address
  assign inst_if    = imem_rdata;   // Assign the data read from instruction memory to the current instruction

  // Instantiate the Intersegment Register module between IF and ID
  Intersegment_register IF2ID(
                          .clk(clk),
                          .rst(rst),
                          .en(global_en),
                          .stall(ifhalt || stall_if2id),
                          .flush(flush_if2id),
                          .pcadd4_in(pcadd4_if),
                          .inst_in(inst_if),
                          .pc_in(pc_if),
                          .pcadd4_out(pcadd4_id),
                          .pc_out(pc_id),
                          .inst_out(inst_id),
                          .imm_in(0),
                          .rf_rd0_in(0),
                          .rf_rd1_in(0),
                          .alu_res_in(0),
                          .dmem_rd_out_in(0),
                          .rf_wa_in(0),
                          .alu_op_in(0),
                          .rf_ra0_in(0),
                          .rf_ra1_in(0),
                          .rf_we_in(0),
                          .alu_src0_sel_in(0),
                          .alu_src1_sel_in(0),
                          .dmem_access_in(0),
                          .br_type_in(0),
                          .rf_wd_sel_in(0),
                          .commit_in(commit_if),
                          .commit_out(commit_id)
                        );

  // The Instruction Decode Stage

  // Instantiate the Decoder module
  // This module decodes the instruction
  Decoder decoder_module(
            .inst(inst_id),                // Instruction
            .alu_op(alu_op_id),            // ALU operation
            .imm(imm_id),                  // Immediate value
            .rf_ra0(rf_ra0_id),            // Register file read address 0
            .rf_ra1(rf_ra1_id),            // Register file read address 1
            .rf_wa(rf_wa_id),              // Register file write address
            .rf_we(rf_we_id),              // Register file write enable
            .alu_src0_sel(alu_src0_sel_id),// Select signal for ALU source 0
            .alu_src1_sel(alu_src1_sel_id),// Select signal for ALU source 1
            .dmem_access(dmem_access_id),  // Data memory access type
            .rf_wd_sel(rf_wd_sel_id),      // Select signal for register file write data
            .br_type(br_type_id),          // Branch type
            .ifhalt(ifhalt)                 // Halt signal
          );

  // Instantiate the SegCtrl module
  // This module handles the data hazard detection and stall/flush signals
  SegCtrl segctrl_module(
            .rf_we_ex(rf_we_ex),          // Register file write enable
            .rf_wd_sel_ex(rf_wd_sel_ex),    // Select signal for register file write data
            .rf_wa_ex(rf_wa_ex),          // Register file write address
            .rf_ra0_id(rf_ra0_id),        // Register file read address 0
            .rf_ra1_id(rf_ra1_id),        // Register file read address 1
            .npc_sel(npc_sel),          // Select signal for next program counter
            .stall_pc(stall_pc),          // Stall signal for the PC module
            .stall_if2id(stall_if2id),      // Stall signal for the IF2ID module
            .flush_if2id(flush_if2id),      // Flush signal for the IF2ID module
            .flush_id2ex(flush_id2ex)       // Flush signal for the ID2EX module
          );

  // Instantiate the Register File module
  // This module handles the read/write operations to the registers
  RegFile regfile_module(
            .clk(clk),              // Clock signal
            .rf_ra0(rf_ra0_id),        // Register file read address 0
            .rf_ra1(rf_ra1_id),        // Register file read address 1
            .rf_wa(rf_wa_wb),          // Register file write address
            .rf_we(rf_we_wb),          // Register file write enable
            .rf_wd(rf_wd),      // Register file write data
            .rf_rd0(rf_rd0_id),        // Register file read data 0
            .rf_rd1(rf_rd1_id),        // Register file read data 1
            .debug_reg_ra(debug_reg_ra), // Register address for debugging
            .debug_reg_rd(debug_reg_rd)  // Register data for debugging
          );

  // Instantiate the Intersegment Register module between ID and EX
  Intersegment_register ID2EX(
                          .clk(clk),
                          .rst(rst),
                          .en(global_en),
                          .stall(0),
                          .flush(flush_id2ex),
                          .pcadd4_in(pcadd4_id),
                          .pc_in(pc_id),
                          .imm_in(imm_id),
                          .rf_rd0_in(rf_rd0_id),
                          .rf_rd1_in(rf_rd1_id),
                          .rf_wa_in(rf_wa_id),
                          .alu_op_in(alu_op_id),
                          .rf_ra0_in(rf_ra0_id),
                          .rf_ra1_in(rf_ra1_id),
                          .rf_we_in(rf_we_id),
                          .alu_src0_sel_in(alu_src0_sel_id),
                          .alu_src1_sel_in(alu_src1_sel_id),
                          .dmem_access_in(dmem_access_id),
                          .br_type_in(br_type_id),
                          .rf_wd_sel_in(rf_wd_sel_id),
                          .pcadd4_out(pcadd4_ex),
                          .pc_out(pc_ex),
                          .imm_out(imm_ex),
                          .rf_rd0_out(rf_rd0_ex),
                          .rf_rd1_out(rf_rd1_ex),
                          .rf_wa_out(rf_wa_ex),
                          .alu_op_out(alu_op_ex),
                          .rf_ra0_out(rf_ra0_ex),
                          .rf_ra1_out(rf_ra1_ex),
                          .rf_we_out(rf_we_ex),
                          .alu_src0_sel_out(alu_src0_sel_ex),
                          .alu_src1_sel_out(alu_src1_sel_ex),
                          .dmem_access_out(dmem_access_ex),
                          .br_type_out(br_type_ex),
                          .rf_wd_sel_out(rf_wd_sel_ex),
                          .alu_res_in(0),
                          .dmem_rd_out_in(0),
                          .commit_in(commit_id),
                          .commit_out(commit_ex),
                          .inst_in(inst_id),
                          .inst_out(inst_ex)
                        );

  // The Execute Stage

  // Instantiate the DFU module
  // This module handles the data forwarding and data hazard detection
  DFU dfu_0(
        .rf_ra(rf_ra0_ex),        // Register address for data forwarding
        .rf_wa_mem(rf_wa_mem),      // Register address for data hazard detection
        .rf_wa_wb(rf_wa_wb),        // Register address for data hazard detection
        .rf_we_mem(rf_we_mem),      // Write enable signal for data hazard detection
        .rf_we_wb(rf_we_wb),        // Write enable signal for data hazard detection
        .rf_wd_sel(rf_wd_sel_mem),    // Select signal for data forwarding
        .alu_res_mem(alu_res_mem),    // Result from ALU
        .rf_wd(rf_wd),          // Data to be written to the register file
        .rf_rd(rf_rd0_ex),        // Data read from the register file
        .rf_rd_out(rf_rd0_ex_df)      // Data to be forwarded to the ALU
      );

  DFU dfu_1(
        .rf_ra(rf_ra1_ex),        // Register address for data forwarding
        .rf_wa_mem(rf_wa_mem),      // Register address for data hazard detection
        .rf_wa_wb(rf_wa_wb),        // Register address for data hazard detection
        .rf_we_mem(rf_we_mem),      // Write enable signal for data hazard detection
        .rf_we_wb(rf_we_wb),        // Write enable signal for data hazard detection
        .rf_wd_sel(rf_wd_sel_mem),    // Select signal for data forwarding
        .alu_res_mem(alu_res_mem),    // Result from ALU
        .rf_wd(rf_wd),          // Data to be written to the register file
        .rf_rd(rf_rd1_ex),        // Data read from the register file
        .rf_rd_out(rf_rd1_ex_df)      // Data to be forwarded to the ALU
      );

  // Instantiate the MUX modules for selecting ALU inputs
  MUX #(.WIDTH(32)) mux0(
        .src0(rf_rd0_ex_df),         // Source 0: Data read from register file
        .src1(pc_ex),         // Source 1: Current PC
        .sel(alu_src0_sel_ex),    // Select signal
        .res(alu_src0)         // Result: ALU source 0
      );

  MUX #(.WIDTH(32)) mux1(
        .src0(rf_rd1_ex_df),         // Source 0: Data read from register file
        .src1(imm_ex),            // Source 1: Immediate value
        .sel(alu_src1_sel_ex),    // Select signal
        .res(alu_src1)         // Result: ALU source 1
      );

  // Instantiate the ALU module
  // This module performs the arithmetic and logic operations
  ALU alu_module(
        .alu_src0(alu_src0),    // ALU source 0
        .alu_src1(alu_src1),    // ALU source 1
        .alu_op(alu_op_ex),        // ALU operation
        .alu_res(alu_res_ex)       // ALU result
      );

  // Instantiate the Branch module
  // This module determines the type of branch and the next PC
  Branch branch_module(
           .br_type(br_type_ex),  // Branch type
           .br_src0(rf_rd0_ex_df),   // Source 0 for branch comparison
           .br_src1(rf_rd1_ex_df),   // Source 1 for branch comparison
           .npc_sel(npc_sel)   // Select signal for next PC
         );

  assign pc_j = alu_res_ex & 32'hFFFFFFFE; // Make the last bit of pc_j 0

  // Instantiate the MUX2 module for selecting the next program counter which is based on the branch type
  MUX2 #(.WIDTH(32)) npc_mux(
         .src0(pcadd4_if),    // Source 0: PC + 4
         .src1(alu_res_ex),     // Source 1: Jump address, which is the result from ALU
         .src2(pc_j),        // Source 2: Jump address, which is ALU_res with the last bit as 0
         .sel(npc_sel),      // Select signal
         .res(npc_ex)       // Result: Next program counter
       );

  // Instantiate the Intersegment Register module between EX and MEM
  Intersegment_register EX2MEM(
                          .clk(clk),
                          .rst(rst),
                          .en(global_en),
                          .stall(0),
                          .flush(0),
                          .pcadd4_in(pcadd4_ex),
                          .rf_rd1_in(rf_rd1_ex_df),
                          .alu_res_in(alu_res_ex),
                          .rf_wa_in(rf_wa_ex),
                          .rf_we_in(rf_we_ex),
                          .dmem_access_in(dmem_access_ex),
                          .rf_wd_sel_in(rf_wd_sel_ex),
                          .pcadd4_out(pcadd4_mem),
                          .rf_rd1_out(rf_rd1_mem),
                          .alu_res_out(alu_res_mem),
                          .rf_wa_out(rf_wa_mem),
                          .rf_we_out(rf_we_mem),
                          .dmem_access_out(dmem_access_mem),
                          .rf_wd_sel_out(rf_wd_sel_mem),
                          .imm_in(0),
                          .rf_rd0_in(0),
                          .dmem_rd_out_in(0),
                          .alu_op_in(0),
                          .alu_src0_sel_in(0),
                          .alu_src1_sel_in(0),
                          .br_type_in(0),
                          .commit_in(commit_ex),
                          .commit_out(commit_mem),
                          .inst_in(inst_ex),
                          .inst_out(inst_mem),
                          .pc_in(pc_ex),
                          .pc_out(pc_mem)
                        );

  // The Memory Opration Stage

  // Instantiate the SLU module
  // This module handles the load/store operations
  SLU slu_module(
        .addr(dmem_addr),       // Address for data memory
        .dmem_access(dmem_access_mem), // Data memory access type
        .rd_in(dmem_rd_in),     // Data read from data memory
        .wd_in(rf_rd1_mem),         // Data to be written to data memory
        .rd_out(dmem_rd_out_mem),   // Data read from data memory which has been dealt by SLU with load operations
        .wd_out(dmem_wd_out),   // Data to be written to data memory which has been dealt by SLU with store operations
        .dmem_we(dmem_we)       // Data memory write enable
      );

  // Connect to Data Memory
  assign dmem_addr  = alu_res_mem;      // Assign the result from ALU to the data memory address
  assign dmem_wdata = dmem_wd_out;  // Assign the data which has been dealt by SLU with store operations to the data memory write data
  assign dmem_rd_in = dmem_rdata;   // Assign the data read from data memory to the SLU to deal with load operations

  // Instantiate the Intersegment Register module between MEM and WB
  Intersegment_register MEM2WB(
                          .clk(clk),
                          .rst(rst),
                          .en(global_en),
                          .stall(0),
                          .flush(0),
                          .pcadd4_in(pcadd4_mem),
                          .alu_res_in(alu_res_mem),
                          .dmem_rd_out_in(dmem_rd_out_mem),
                          .rf_wa_in(rf_wa_mem),
                          .rf_we_in(rf_we_mem),
                          .rf_wd_sel_in(rf_wd_sel_mem),
                          .pcadd4_out(pcadd4_wb),
                          .alu_res_out(alu_res_wb),
                          .dmem_rd_out_out(dmem_rd_out_wb),
                          .rf_wa_out(rf_wa_wb),
                          .rf_we_out(rf_we_wb),
                          .rf_wd_sel_out(rf_wd_sel_wb),
                          .imm_in(0),
                          .rf_rd0_in(0),
                          .rf_rd1_in(0),
                          .alu_op_in(0),
                          .alu_src0_sel_in(0),
                          .alu_src1_sel_in(0),
                          .dmem_access_in(0),
                          .br_type_in(0),
                          .commit_in(commit_mem),
                          .commit_out(commit_wb),
                          .inst_in(inst_mem),
                          .inst_out(inst_wb),
                          .pc_in(pc_mem),
                          .pc_out(pc_wb)
                        );

  //The Write Back stage

  // Instantiate the MUX2 module for selecting the data to be written to the register file
  MUX2 #(.WIDTH(32)) rf_wd_mux(
         .src0(alu_res_wb),         // Source 0: Result from ALU
         .src1(dmem_rd_out_wb),     // Source 1: Data read from SLU
         .src2(pcadd4_wb),        // Source 2: PC + 4
         .src3(0),               // Source 3: 0
         .sel(rf_wd_sel_wb),        // Select signal
         .res(rf_wd)         // Result: Data to be written to the register file
       );


endmodule
