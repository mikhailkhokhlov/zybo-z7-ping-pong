`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2021 04:10:03 PM
// Design Name: 
// Module Name: test_debouncer
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
`include "../../sources_1/new/debouncer.v"

module test_debouncer();

reg btn_input;
wire btn_db;
wire btn_up;
wire btn_down;

reg clock;

debouncer #(20) dut (.clock_in(clock),
                     .btn_in(btn_input),
                     .btn_out(btn_db),
                     .btn_up_out(btn_up),
                     .btn_down_out(btn_down));

initial
begin
  clock = 0;

  forever #10 clock = ~clock;
end

initial
begin
  btn_input = 0; #12
  btn_input = 1; #1
  btn_input = 0; #1
  btn_input = 1; #1
  btn_input = 0; #2
  btn_input = 1; #200

  btn_input = 0; #1
  btn_input = 1; #2
  btn_input = 0; #1
  btn_input = 1; #1
  btn_input = 0;
end

endmodule
