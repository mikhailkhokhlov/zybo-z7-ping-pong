`ifndef _LFSR_V_
  `define _LFSR_V_

`define INIT_STATE 9'b0_0000_0001

`timescale 1ns / 1ps

module lfsr(input i_clock,
            input i_reset,
            output reg [9:0] o_q);

  reg [9:0] state;

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      o_q <= `INIT_STATE;
    else
      begin
        o_q[9] <= o_q[0];
        o_q[8] <= o_q[8] ? (o_q[9] ^ o_q[0]) : o_q[9];
        o_q[7] <= o_q[7] ? (o_q[8] ^ o_q[0]) : o_q[8];
        o_q[6] <= o_q[6] ? (o_q[7] ^ o_q[0]) : o_q[7];
        o_q[5] <= o_q[5] ? (o_q[6] ^ o_q[0]) : o_q[6];
        o_q[4] <= o_q[4] ? (o_q[5] ^ o_q[0]) : o_q[5];
        o_q[3] <= o_q[3] ? (o_q[4] ^ o_q[0]) : o_q[4];
        o_q[2] <= o_q[2] ? (o_q[3] ^ o_q[0]) : o_q[3];
        o_q[1] <= o_q[1] ? (o_q[2] ^ o_q[0]) : o_q[2];
        o_q[0] <= o_q[0] ? (o_q[1] ^ o_q[0]) : o_q[1];
      end
endmodule

`endif // _LFSR_V_
