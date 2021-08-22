`ifndef _DEBOUNCER_V_
  `define _DEBOUNCER_V_

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2021 01:41:17 PM
// Design Name: 
// Module Name: debouncer
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

module clock_enable #(WIDTH = 20)(input i_clock,
                                  input i_reset,
                                  output o_clock_en);
  reg [WIDTH - 1:0] counter;

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      counter <= { WIDTH{1'b0} };
    else
      counter <= counter + 1;

  assign o_clock_en = counter[WIDTH - 1];

endmodule

module debouncer(input i_clock,
                 input i_reset,
                 input i_button,
                 output o_button,
                 output o_push);

  wire clock_en;

  clock_enable clk_en(.i_clock(i_clock),
                      .i_reset(i_reset),
                      .o_clock_en(clock_en));

  reg [2:0] samples;
  reg push;
  reg button_debounced;

  always @(posedge clock_en, posedge i_reset)
    if (i_reset)
      samples <= 0;
    else
      samples <= { samples[1:0], i_button };

  wire current = & samples;
  reg previous;

  always @(posedge i_clock)
    if (i_reset)
      begin
        previous         <= 0;
        push             <= 0;
        button_debounced <= 0;
      end
    else
      begin
        previous         <= current;
        push             <= ({ previous, current } == 2'b01);
        button_debounced <= ({ previous, current } == 2'b11);
      end

  assign o_push = push;
  assign o_button = button_debounced; 

endmodule

`endif // _DEBOUNCER_V_
