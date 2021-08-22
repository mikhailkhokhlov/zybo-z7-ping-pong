`ifndef _PADDLE_BAR_V_
  `define  _PADDLE_BAR_V_

`timescale 1ns / 1ps

`include "defines.vh"

module paddle_bar_position #(parameter X_INIT = 0,
                             parameter Y_INIT = 0) 
                           (input i_clock,
                            input i_reset,
                            input i_vsync_pulse,
                            input i_move_paddle_up,
                            input i_move_paddle_down,
                            output [9:0] o_paddle_x,
                            output [9:0] o_paddle_y);

  reg [9:0] reg_paddle_x;
  reg [9:0] reg_paddle_y;
  reg [9:0] next_paddle_x;
  reg [9:0] next_paddle_y;

  // TODO:
  // These registers are not needed.
  // Only for meet time requiments
  // They have to be removed.
  reg move_up;
  reg move_down;

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      begin
        move_up   <= 0;
        move_down <= 0;
      end
    else
      begin
        move_up   <= i_move_paddle_up;
        move_down <= i_move_paddle_down;
      end

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      begin
        reg_paddle_x <= X_INIT;
        reg_paddle_y <= Y_INIT;
      end
    else
      begin
        reg_paddle_x <= next_paddle_x;
        reg_paddle_y <= next_paddle_y;
      end

  always @*
    begin
      next_paddle_y = reg_paddle_y;
      next_paddle_x = reg_paddle_x;
/*
      if (i_vsync_pulse)
        if (i_move_paddle_up & (reg_paddle_y - 2 > 0))
          next_paddle_y = reg_paddle_y - 2;
        else if (i_move_paddle_down & (reg_paddle_y + `PADDLE_HEIGHT + 2 < `VVIDEO_ON))
          next_paddle_y = reg_paddle_y + 2;
*/
      if (i_vsync_pulse)
        if (move_up & (reg_paddle_y - 2 > 0))
          next_paddle_y = reg_paddle_y - 2;
        else if (move_down & (reg_paddle_y + `PADDLE_HEIGHT + 2 < `VVIDEO_ON))
          next_paddle_y = reg_paddle_y + 2;
    end

  assign o_paddle_x = reg_paddle_x;
  assign o_paddle_y = reg_paddle_y;

endmodule

module paddle_renderer(input [9:0] i_hpos,
                       input [9:0] i_vpos,
                       input [9:0] i_paddle_x,
                       input [9:0] i_paddle_y,
                       output o_paddle_gfx_on);

  assign o_paddle_gfx_on = (i_hpos >= i_paddle_x) &&
                           (i_hpos <= i_paddle_x + `PADDLE_WIDTH) && 
                           (i_vpos >= i_paddle_y) &&
                           (i_vpos <= i_paddle_y + `PADDLE_HEIGHT);
endmodule

`endif // _PADDLE_BAR_V_
