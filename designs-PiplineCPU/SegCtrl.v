`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/21 00:16:43
// Design Name: 
// Module Name: SegCtrl
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


module SegCtrl(input rf_we_ex,
                input [1:0] rf_wd_sel_ex,
                input [4:0] rf_wa_ex,
                input [4:0] rf_ra0_id,
                input [4:0] rf_ra1_id,
                input [1:0] npc_sel,
                output reg stall_pc,
                output reg stall_if2id,
                output reg flush_if2id,
                output reg flush_id2ex
    );
    always @(*)
    begin
        stall_pc = 0;
        stall_if2id = 0;
        flush_if2id = 0;
        flush_id2ex = 0;
        if (rf_we_ex && rf_wd_sel_ex == 2'b01 && (rf_wa_ex == rf_ra0_id || rf_wa_ex == rf_ra1_id) && rf_wa_ex)
        begin
            stall_pc = 1;
            stall_if2id = 1;
            flush_id2ex = 1;
        end
        else if (npc_sel == 2'b01 || npc_sel == 2'b10)
        begin
            flush_if2id = 1;
            flush_id2ex = 1;
        end
    end
endmodule
