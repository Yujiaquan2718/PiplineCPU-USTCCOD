`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/03/30 19:09:43
// Design Name:
// Module Name: TOP_tb
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/03/30 19:11:21
// Design Name:
// Module Name: sm_TOP
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


module TOP_tb();
  reg clk;
  reg rst;
  reg enable;
  reg [4:0] in;
  reg [1:0] ctrl;

  wire [3:0] seg_data;
  wire [2:0] seg_an;

  TOP testTOP (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .in(in),
        .ctrl(ctrl),
        .seg_data(seg_data),
        .seg_an(seg_an)
      );

  initial
  begin
    clk = 0;
    forever
      #5 clk = ~clk;
  end

  initial
  begin
    rst = 1;
    #60
     rst = 0;
  end

  initial
  begin
    enable = 0;

    #100
     ctrl = 2'b00;
    in = 5'b00000;

    #10
     enable = 1;
    #30
     enable = 0;

    #100
     ctrl = 2'b01;
    in = 5'b00001;

    #10
     enable = 1;
    #30
     enable = 0;

    #100
     ctrl = 2'b10;
    in = 5'b00010;

    #10
     enable = 1;
    #30
     enable = 0;

    #100
     enable = 1;
    ctrl = 2'b11;
    in = 5'b00011;

    #10
     enable = 1;
    #30
     enable = 0;
  end
endmodule
