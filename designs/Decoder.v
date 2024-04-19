`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/04/01 21:29:29
// Design Name:
// Module Name: Decoder
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


module Decoder(input [31:0] inst,
               output reg [4:0] alu_op,
               output reg [31:0] imm,
               output reg [4:0] rf_ra0,
               output reg [4:0] rf_ra1,
               output reg [4:0] rf_wa,
               output reg rf_we,
               output reg alu_src0_sel,
               output reg alu_src1_sel,
               output reg [3:0] dmem_access,
               output reg [1:0] rf_wd_sel,
               output reg [3:0] br_type,
               output reg ifhalt);

// Define operation codes (opcodes)
localparam OPCODE_RTYPE       = 7'b0110011;
localparam OPCODE_ITYPE_ARITH = 7'b0010011;
localparam OPCODE_UTYPE_LUI   = 7'b0110111;
localparam OPCODE_UTYPE_AUIPC = 7'b0010111;
localparam OPCODE_STYPE       = 7'b0100011;
localparam OPCODE_LTYPE       = 7'b0000011;
localparam OPCODE_JTYPE_JAL   = 7'b1101111;
localparam OPCODE_JTYPE_JALR  = 7'b1100111;
localparam OPCODE_BTYPE       = 7'b1100011;

// Define function codes for ALU operations
localparam FUNCT3_ADD_SUB   = 3'b000;
localparam FUNCT3_SLT       = 3'b010;
localparam FUNCT3_SLTU      = 3'b011;
localparam FUNCT3_AND       = 3'b111;
localparam FUNCT3_OR        = 3'b110;
localparam FUNCT3_XOR       = 3'b100;
localparam FUNCT3_SLL       = 3'b001;
localparam FUNCT3_SRL_SRA   = 3'b101;
localparam FUNCT3_ADDI      = 3'b000;
localparam FUNCT3_SLLI      = 3'b001;
localparam FUNCT3_SRLI_SRAI = 3'b101;
localparam FUNCT3_SLTI      = 3'b010;
localparam FUNCT3_SLTIU     = 3'b011;
localparam FUNCT3_ANDI      = 3'b111;
localparam FUNCT3_ORI       = 3'b110;
localparam FUNCT3_XORI      = 3'b100;
localparam FUNCT3_LW        = 3'b010;
localparam FUNCT3_LH        = 3'b001;
localparam FUNCT3_LB        = 3'b000;
localparam FUNCT3_LHU       = 3'b101;
localparam FUNCT3_LBU       = 3'b100;
localparam FUNCT3_SW        = 3'b010;
localparam FUNCT3_SH        = 3'b001;
localparam FUNCT3_SB        = 3'b000;
localparam FUNCT3_BEQ       = 3'b000;
localparam FUNCT3_BNE       = 3'b001;
localparam FUNCT3_BLT       = 3'b100;
localparam FUNCT3_BGE       = 3'b101;
localparam FUNCT3_BLTU      = 3'b110;
localparam FUNCT3_BGEU      = 3'b111;

localparam FUNCT7_ADD  = 7'b0000000;
localparam FUNCT7_SUB  = 7'b0100000;
localparam FUNCT7_SLT  = 7'b0000000;
localparam FUNCT7_SLTU = 7'b0000000;
localparam FUNCT7_AND  = 7'b0000000;
localparam FUNCT7_OR   = 7'b0000000;
localparam FUNCT7_XOR  = 7'b0000000;
localparam FUNCT7_SLL  = 7'b0000000;
localparam FUNCT7_SRL  = 7'b0000000;
localparam FUNCT7_SRA  = 7'b0100000;
localparam FUNCT7_SLLI = 7'b0000000;
localparam FUNCT7_SRLI = 7'b0000000;
localparam FUNCT7_SRAI = 7'b0100000;

// Define ALU operation codes
localparam OPT_ADD     = 5'b00000;
localparam OPT_SUB     = 5'b00010;
localparam OPT_SLT     = 5'b00100;
localparam OPT_SLTU    = 5'b00101;
localparam OPT_AND     = 5'b01001;
localparam OPT_OR      = 5'b01010;
localparam OPT_XOR     = 5'b01011;
localparam OPT_SLL     = 5'b01110;
localparam OPT_SRL     = 5'b01111;
localparam OPT_SRA     = 5'b10000;
localparam OPT_SRC0    = 5'b10001;
localparam OPT_SRC1    = 5'b10010;
localparam OPT_DEFAULT = 5'bzzzzz;

// Define the HALT instruction
`define HALT_INST 32'h00100073

// Decode the instruction
always @(inst)
begin
    // Judge if the instruction is HALT
    if (inst == `HALT_INST)
    begin
        ifhalt = 1'b1;
    end
    else
    begin
        ifhalt = 1'b0;
    end

    // Initialize outputs
    rf_ra0 = inst[19:15];
    rf_ra1 = inst[24:20];
    rf_wa  = inst[11:7];
    rf_we  = 1'b1; // Enable write-back for arithmetic instructions, because arithmetic instructions are the most common
    
    // Initialize ALU source selections and immediate value
    alu_src0_sel = 1'b0;
    alu_src1_sel = 1'b0;
    imm          = 32'b0;
    
    // Initialize ALU operation
    alu_op = OPT_DEFAULT;
    
    // Initialize other control signals
    dmem_access = 4'b0000;
    rf_wd_sel   = 2'b00;
    br_type     = 4'b0000;
    
    // Check the opcode
    case (inst[6:0])
        OPCODE_RTYPE:
        begin
            // R-type instruction
            // These instructions don't use immediate values
            // ALU source selections are both false for R-type instructions
            
            // Set the ALU operation based on funct3 and funct7
            case (inst[14:12])
                FUNCT3_ADD_SUB:
                begin
                    case (inst[31:25])
                        FUNCT7_ADD:
                        alu_op = OPT_ADD; // ADD operation code
                        FUNCT7_SUB:
                        alu_op = OPT_SUB; // SUB operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                FUNCT3_SLT:
                begin
                    case (inst[31:25])
                        FUNCT7_SLT:
                        alu_op = OPT_SLT; // SLT operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                FUNCT3_SLTU:
                begin
                    case (inst[31:25])
                        FUNCT7_SLTU:
                        alu_op = OPT_SLTU; // SLTU operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                FUNCT3_AND:
                begin
                    case (inst[31:25])
                        FUNCT7_AND:
                        alu_op = OPT_AND; // AND operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                FUNCT3_OR:
                begin
                    case (inst[31:25])
                        FUNCT7_OR:
                        alu_op = OPT_OR; // OR operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                FUNCT3_XOR:
                begin
                    case (inst[31:25])
                        FUNCT7_XOR:
                        alu_op = OPT_XOR; // XOR operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                FUNCT3_SLL:
                begin
                    case (inst[31:25])
                        FUNCT7_SLL:
                        alu_op = OPT_SLL; // SLL operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                FUNCT3_SRL_SRA:
                begin
                    case (inst[31:25])
                        FUNCT7_SRL:
                        alu_op = OPT_SRL; // SRL operation code
                        FUNCT7_SRA:
                        alu_op = OPT_SRA; // SRA operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                default:
                rf_we = 1'b0; // Disable write-back if operation is undefined
            endcase
        end
        OPCODE_ITYPE_ARITH:
        begin
            // I-type instruction
            // These instructions use immediate values
            alu_src1_sel = 1'b1; // The second ALU source selection is true for I-type instructions
            imm          = { {20{inst[31]}} , inst[31:20] }; // Sign-extend immediate value, but the instructions SLLI, SRLI and SRAI are different
            rf_ra1       = 0; // Set the second register file read address to zero
            
            // Based on funct3, set the ALU operation
            case (inst[14:12])
                FUNCT3_ADDI:
                alu_op = OPT_ADD; // ADD operation code
                FUNCT3_SLLI:
                begin
                    imm = { {27{inst[24]}} , inst[24:20] }; // Sign-extend immediate value
                    case (inst[31:25])
                        FUNCT7_SLLI:
                        alu_op = OPT_SLL; // SLL operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                FUNCT3_SRLI_SRAI:
                begin
                    imm = { {27{inst[24]}} , inst[24:20] }; // Sign-extend immediate value
                    case (inst[31:25])
                        FUNCT7_SRLI:
                        alu_op = OPT_SRL; // SRL operation code
                        FUNCT7_SRAI:
                        alu_op = OPT_SRA; // SRA operation code
                        default:
                        rf_we = 1'b0; // Disable write-back if operation is undefined
                    endcase
                end
                FUNCT3_SLTI:
                alu_op = OPT_SLT; // SLT operation code
                FUNCT3_SLTIU:
                alu_op = OPT_SLTU; // SLTU operation code
                FUNCT3_ANDI:
                alu_op = OPT_AND; // AND operation code
                FUNCT3_ORI:
                alu_op = OPT_OR; // OR operation code
                FUNCT3_XORI:
                alu_op = OPT_XOR; // XOR operation code
                default:
                rf_we = 1'b0; // Disable write-back if operation is undefined
            endcase
        end
        OPCODE_UTYPE_LUI:
        // U-type instruction: LUI
        // This instruction uses immediate values
        // This instruction doesn't use register file read addresses
        begin
            rf_ra0       = 0; // Set the first register file read address to zero
            rf_ra1       = 0; // Set the second register file read address to zero
            imm          = { inst[31:12], 12'b0 }; // Zero-extend immediate value
            alu_op       = OPT_SRC1; // Pass immediate value as the second ALU operand and ignore the first operand
            alu_src1_sel = 1'b1; // Select immediate value as the second ALU operand
        end
        OPCODE_UTYPE_AUIPC:
        // U-type instruction: AUIPC
        // This instruction uses immediate values
        // This instruction doesn't use register file read addresses
        begin
            rf_ra0       = 0; // Set the first register file read address to zero
            rf_ra1       = 0; // Set the second register file read address to zero
            imm          = { inst[31:12], 12'b0 }; // Zero-extend immediate value
            alu_op       = OPT_ADD; // ADD operation code
            alu_src0_sel = 1'b1; // Select PC as the first ALU operand
            alu_src1_sel = 1'b1; // Select immediate value as the second ALU operand
        end
        // L-type
        OPCODE_LTYPE:
        begin
            rf_wd_sel    = 2'b01;   // Write-back data selects memory access data
            imm          = { {20{inst[31]}}, inst[31:20] }; // Sign-extend immediate value
            rf_ra1       = 0; // Set the second register file read address to zero
            alu_src1_sel = 1'b1; // Select immediate value as the second ALU operand
            alu_op       = OPT_ADD; // ADD operation code, add the data of the first register and the immediate value together
            case (inst[14:12])
                FUNCT3_LW:
                dmem_access = 4'b0001; // Load word
                FUNCT3_LH:
                dmem_access = 4'b0010; // Load half-word
                FUNCT3_LB:
                dmem_access = 4'b0011; // Load byte
                FUNCT3_LHU:
                dmem_access = 4'b0100; // Load half-word unsigned
                FUNCT3_LBU:
                dmem_access = 4'b0101; // Load byte unsigned
                default:
                begin
                    rf_we  = 1'b0; // Disable write-back if operation is undefined
                    alu_op = OPT_DEFAULT; // Disable ALU operation if operation is undefined
                end
            endcase
        end
        // S-type
        OPCODE_STYPE:
        begin
            rf_we        = 1'b0; // Disable write-back for store instructions
            rf_wa        = 0; // Set the write address to zero
            imm          = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // Sign-extend immediate value
            alu_src1_sel = 1'b1; // Select immediate value as the second ALU operand
            alu_op       = OPT_ADD; // ADD operation code, add the data of the first register and the immediate value together
            case (inst[14:12])
                FUNCT3_SW:
                dmem_access = 4'b1001; // Store word
                FUNCT3_SH:
                dmem_access = 4'b1010; // Store half-word
                FUNCT3_SB:
                dmem_access = 4'b1011; // Store byte
                default:
                alu_op = OPT_DEFAULT; // Disable ALU operation if operation is undefined
            endcase
        end
        // J-type instructions: JALR
        OPCODE_JTYPE_JALR:
        begin
            rf_wd_sel    = 2'b10;   // write-back data selects PC+4
            imm          = { {20{inst[31]}}, inst[31:20] }; // Sign-extend immediate value
            alu_op       = OPT_ADD; // ADD operation code
            rf_ra1       = 0; // Set the second register file read address to zero
            alu_src1_sel = 1'b1; // Select immediate value as the second ALU operand
            br_type      = 4'b1000;   // JALR
        end
        // J-type instructions: JAL
        OPCODE_JTYPE_JAL:
        begin
            rf_wd_sel    = 2'b10;   // write-back data selects PC+4
            imm          = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; // J-type immediate value
            alu_op       = OPT_ADD;
            alu_src0_sel = 1'b1; // Select PC as the first ALU operand
            rf_ra0       = 0; // Set the first register file read address to zero
            alu_src1_sel = 1'b1; // Select immediate value as the second ALU operand
            rf_ra1       = 0; // Set the second register file read address to zero
            br_type      = 4'b1001;   // JAL
        end
        //Branch指令
        OPCODE_BTYPE:
        begin
            rf_we        = 1'b0; // Disable write-back for branch instructions
            rf_wa        = 0; // Set the write address to zero
            imm          = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; // B-type immediate value
            alu_src0_sel = 1'b1; // Select PC as the first ALU operand
            alu_src1_sel = 1'b1; // Select immediate value as the second ALU operand
            alu_op       = OPT_ADD; // ADD operation code
            case (inst[14:12])
                FUNCT3_BEQ:
                br_type = 4'b0001; // BEQ
                FUNCT3_BNE:
                br_type = 4'b0010; // BNE
                FUNCT3_BLT:
                br_type = 4'b0011; // BLT
                FUNCT3_BGE:
                br_type = 4'b0100; //BGE
                FUNCT3_BLTU:
                br_type = 4'b0101; //BLTU
                FUNCT3_BGEU:
                br_type = 4'b0110; //BGEU
                default:
                alu_op = OPT_DEFAULT; // Disable ALU operation if operation is undefined
            endcase
        end
        default:
        begin
            rf_we = 1'b0; // Disable write-back if operation is undefined
            rf_wd_sel = 2'b11; // Write-back data selects zero
        end
    endcase
end

endmodule
