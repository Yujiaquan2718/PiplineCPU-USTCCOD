`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/14 15:29:23
// Design Name:
// Module Name: SLU
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


module SLU (input wire [31:0] addr,       // Address input
              input wire [3:0] dmem_access, // Memory access type
              input wire [31:0] rd_in,      // Read data input
              input wire [31:0] wd_in,      // Write data input
              output reg [31:0] rd_out,     // Read data output
              output reg [31:0] wd_out,     // Write data output
              output reg dmem_we);          // Memory write enable signal

  reg half_word_aligned ; // Flag for half-word alignment
  reg whole_word_aligned; // Flag for whole-word alignment
  always @(*)
  begin

    rd_out             = 32'b0; // Initialize read data output
    wd_out             = 32'b0; // Initialize write data output
    dmem_we            = 1'b0; // Initialize memory write enable signal
    half_word_aligned  = (addr[0] == 1'b0); // Check if address is half-word aligned
    whole_word_aligned = (addr[1:0] == 2'b00); // Check if address is whole-word aligned

    // Depending on the memory access type
    case (dmem_access)
      4'b0001:
      begin
        // If address is whole-word aligned
        if (whole_word_aligned)
        begin
          // Read whole word
          rd_out = rd_in;
        end
      end
      4'b0010:
      begin
        // If address is half-word aligned
        if (half_word_aligned)
        begin
          // If it's the lower half-word, return the lower half-word, otherwise return the upper half-word
          rd_out = (addr[1] == 1'b0) ? {{16{rd_in[15]}},rd_in[15:0]} : {{16{rd_in[31]}},rd_in[31:16]};
        end
      end
      4'b0011:
      begin
        // Depending on the lower two bits of the address
        case (addr[1:0])
          2'b00:
            rd_out = {{24{rd_in[7]}} , rd_in[7:0]};
          2'b01:
            rd_out = {{24{rd_in[15]}} , rd_in[15:8]};
          2'b10:
            rd_out = {{24{rd_in[23]}} , rd_in[23:16]};
          2'b11:
            rd_out = {{24{rd_in[31]}} , rd_in[31:24]};
        endcase
      end
      4'b0100:
      begin
        // If address is half-word aligned
        if (half_word_aligned)
        begin
          // If it's the lower half-word, return the lower half-word, otherwise return the upper half-word
          rd_out = (addr[1] == 1'b0) ? {16'b0,rd_in[15:0]} : {16'b0,rd_in[31:16]};
        end
      end
      4'b0101:
      begin
        // Depending on the lower two bits of the address
        case (addr[1:0])
          2'b00:
            rd_out = {24'b0 , rd_in[7:0]};
          2'b01:
            rd_out = {24'b0 , rd_in[15:8]};
          2'b10:
            rd_out = {24'b0 , rd_in[23:16]};
          2'b11:
            rd_out = {24'b0 , rd_in[31:24]};
        endcase
      end
      4'b1001:
      begin
        // If address is whole-word aligned
        if (whole_word_aligned)
        begin
          // Write whole word
          wd_out  = wd_in;
          dmem_we = 1'b1;
        end
      end
      4'b1010:
      begin
        // If address is half-word aligned
        if (half_word_aligned)
        begin
          // Enable memory write
          dmem_we = 1'b1;
          // Depending on the second bit of the address
          case (addr[1])
            1'b0:
              wd_out = {rd_in[31:16] , wd_in[15:0]};
            1'b1:
              wd_out = {wd_in[15:0] , rd_in[15:0]};
            default:
              dmem_we = 1'b0;
          endcase
        end
      end
      4'b1011:
      begin
        // Enable memory write
        dmem_we = 1'b1;
        // Depending on the lower two bits of the address
        case (addr[1:0])
          2'b00:
            wd_out = {rd_in[31:8] , wd_in[7:0]};
          2'b01:
            wd_out = {rd_in[31:16] , wd_in[7:0] , rd_in[7:0]};
          2'b10:
            wd_out = {rd_in[31:24] , wd_in[7:0] , rd_in[15:0]};
          2'b11:
            wd_out = {wd_in[7:0] , rd_in[23:0]};
          default :
            dmem_we = 1'b0;
        endcase
      end
      default:
        ;
    endcase
  end

endmodule
