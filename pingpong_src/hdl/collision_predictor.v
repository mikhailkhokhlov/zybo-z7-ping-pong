`ifndef _COLLISION_PREDICTOR_V_
  `define _COLLISION_PREDICTOR_V_

`timescale 1ns / 1ps

`include "defines.vh"

module collision_predictor(input i_clock,
                           input i_reset,
                           input i_vsync_start,
                           input [9:0] i_ball_current_x,
                           input [9:0] i_ball_current_y,
                           output o_predicted_valid,
                           output [9:0] o_predicted_y,
                           output o_ball_move_up);

  localparam IDLE           = 3'b000;
  localparam BOTTOM         = 3'b001;
  localparam TOP            = 3'b010;
  localparam LAST_BALL_DOWN = 3'b011;
  localparam LAST_BALL_UP   = 3'b100;

  reg [2:0] reg_state;
  reg [2:0] next_state;

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      reg_state <= IDLE;
    else
      reg_state <= next_state;

  reg [9:0] reg_ball_x;
  reg [9:0] reg_ball_y;

  wire signed [9:0] delta_x;
  wire signed [9:0] delta_y;
  wire move_up;
  wire move_down;
  wire move_left;

  reg [9:0] vert_collision_x;

  reg [9:0] reg_predicted_y;
  reg [9:0] next_predicted_y;

  reg last_collision;

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      begin
        reg_ball_x <= 0;
        reg_ball_y <= 0;
      end
    else if (i_vsync_start)
      begin
        reg_ball_x <= i_ball_current_x;
        reg_ball_y <= i_ball_current_y;
      end

  assign delta_x = (reg_ball_x > 0) ? (i_ball_current_x - reg_ball_x) : 0;
  assign delta_y = (reg_ball_y > 0) ? (i_ball_current_y - reg_ball_y) : 0;

  assign move_up    = (delta_y < 0);
  assign move_down  = (delta_y > 0);
  assign move_left  = (delta_x < 0);

  always @*
    begin
      next_predicted_y = reg_predicted_y;
      last_collision = 1'b0;

      if (reg_state == BOTTOM)
        begin
          vert_collision_x = reg_ball_x - (`VVIDEO_ON - reg_ball_y + `BALL_HEIGHT);
          last_collision = (vert_collision_x < `VVIDEO_ON) ? 1 : 0;
          if (last_collision)
            next_predicted_y = `VVIDEO_ON - vert_collision_x;
        end
      else if (reg_state == TOP)
        begin
          vert_collision_x = reg_ball_x - reg_ball_y;
          last_collision = (vert_collision_x < `VVIDEO_ON) ? 1 : 0;
          if (last_collision)
            next_predicted_y = vert_collision_x;
        end
    end

  always @(posedge i_clock, posedge i_reset)
     if (i_reset)
      reg_predicted_y <= `VVIDEO_ON / 2;
    else
      reg_predicted_y <= next_predicted_y;

  always @*
    begin
      next_state = reg_state;

      case (reg_state)
        IDLE:
          if (move_left & move_down)
            next_state = BOTTOM;
          else if (move_left & move_up)
            next_state = TOP;
        BOTTOM:
          if (last_collision)
            next_state = LAST_BALL_UP;
          else
            next_state = TOP;
        TOP:
          if (last_collision)
            next_state = LAST_BALL_DOWN;
          else
            next_state = BOTTOM;
        LAST_BALL_DOWN:
          if (~move_left)
            next_state = IDLE;
        LAST_BALL_UP:
          if (~move_left)
            next_state = IDLE;
      endcase
    end

  assign o_predicted_valid = (reg_state == LAST_BALL_DOWN || reg_state == LAST_BALL_UP) ? 1 : 0;
  assign o_predicted_y = reg_predicted_y;
  assign o_ball_move_up = (o_predicted_valid & (reg_state == LAST_BALL_UP)) ? 1 : 0;

endmodule

`endif //_COLLISION_PREDICTOR_V_
