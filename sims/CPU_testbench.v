`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/14 18:26:44
// Design Name:
// Module Name: CPU_testbench
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


module CPU_testbench();
  // CPU
  reg [ 0 : 0]   clk                     ;
  reg [ 0 : 0]   rst                     ;
  reg [ 0 : 0]   cpu_global_en           ;

  wire [31 : 0]   cpu_imem_raddr          ;
  wire [31 : 0]   imem_cpu_rdata          ;
  wire [31 : 0]   dmem_cpu_rdata          ;
  wire [ 0 : 0]   cpu_dmem_we             ;
  wire [31 : 0]   cpu_dmem_addr           ;
  wire [31 : 0]   cpu_dmem_wdata          ;

  // wire [ 0 : 0]   cpu_commit_en           ;
  // wire [31 : 0]   cpu_commit_pc           ;
  // wire [31 : 0]   cpu_commit_inst         ;
  // wire [ 0 : 0]   cpu_commit_halt         ;

  initial
  begin
    cpu_global_en = 1'b1;
  end

  initial
  begin
    clk = 0;
    forever
      #5 clk = ~clk;
  end

  initial
  begin
    rst = 1;
    #20
     rst = 0;
  end

  CPU cpu (
        .clk                    (clk             )   ,
        .rst                    (rst                    )   ,
        .global_en              (cpu_global_en          )   ,

        // Memory (inst)
        .imem_raddr             (cpu_imem_raddr         )   ,
        .imem_rdata             (imem_cpu_rdata         ),

        // Memory (data)
        .dmem_rdata             (dmem_cpu_rdata         )   ,
        .dmem_we                (cpu_dmem_we            )   ,
        .dmem_addr              (cpu_dmem_addr          )   ,
        .dmem_wdata             (cpu_dmem_wdata         )

        // // Debug
        // .commit                 (cpu_commit_en          )   ,
        // .commit_pc              (cpu_commit_pc          )   ,
        // .commit_inst            (cpu_commit_inst        )   ,
        // .commit_halt            (cpu_commit_halt        )   ,
        // .commit_reg_we          (                       )   ,
        // .commit_reg_wa          (                       )   ,
        // .commit_reg_wd          (                       )   ,
        // .commit_dmem_we         (                       )   ,
        // .commit_dmem_wa         (                       )   ,
        // .commit_dmem_wd         (                       )   ,

        // .debug_reg_ra           (pdu_rf_addr            )   ,
        // .debug_reg_rd           (rf_pdu_data            )
      );

  // Memory (inst)
  // USE IP
  INST_MEM instruction_memory (
             .clk                    (clk             ),
             .a                      (cpu_imem_raddr[10:2]        ),
             .spo                    (imem_cpu_rdata            )
             //  .we                     (imem_we                ),
             //  .d                      (imem_wdata             )
           );

  // Memory (data)
  // USE IP
  DATA_MEM data_memory (
             .clk                    (clk             ),
             .a                      (cpu_dmem_addr[10:2]        ),
             .spo                    (dmem_cpu_rdata            ),
             .we                     (cpu_dmem_we            ),
             .d                      (cpu_dmem_wdata         )
           );

endmodule
