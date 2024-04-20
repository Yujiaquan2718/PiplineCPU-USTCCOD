`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/20 22:53:22
// Design Name:
// Module Name: DFU
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


module DFU(input [4:0] rf_ra, rf_wa_mem, rf_wa_wb,
             input rf_we_mem, rf_we_wb,
             input [1:0] rf_wd_sel,
             input [31:0] dmem_rd_out, rf_wd, rf_rd,
             output reg [31:0] rf_rd_out);

  always @(*)
  begin
    if (rf_ra == rf_wa_mem && rf_we_mem && rf_ra && rf_wd_sel == 2'b01)
    begin
      rf_rd_out = dmem_rd_out;
    end
    else if (rf_ra == rf_wa_wb && rf_we_wb && rf_ra)
    begin
      rf_rd_out = rf_wd;
    end
    else
    begin
      rf_rd_out = rf_rd;
    end
  end

endmodule
