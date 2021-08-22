`ifndef _GAME_CONTROLLER_V_
  `define _GAME_CONTROLLER_V_

`timescale 1ns / 1ps

module game_controller(input i_clock,
                       input i_reset,
                       input i_left_ckick,
                       input i_right_ckick,
                       input i_left_miss,
                       input i_right_miss,
                       output o_left_will_start,
                       output o_right_will_start,
                       output o_ball_in_game,
                       output [1:0] o_state);

  localparam IDLE             = 2'b00;
  localparam LEFT_WILL_START  = 2'b01;
  localparam RIGHT_WILL_START = 2'b10;
  localparam BALL_IN_GAME     = 2'b11;

  reg [1:0] reg_state;
  reg [1:0] next_state;

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      reg_state <= IDLE;
    else
      reg_state <= next_state;

  always @*
    begin
      next_state = reg_state;
      case (reg_state)
        IDLE: next_state = LEFT_WILL_START; //RIGHT_WILL_START;
        RIGHT_WILL_START: next_state = i_right_ckick ? BALL_IN_GAME : RIGHT_WILL_START;
        LEFT_WILL_START:  next_state = i_left_ckick  ? BALL_IN_GAME : LEFT_WILL_START;
        BALL_IN_GAME:     next_state = i_left_miss   ? 
                                       RIGHT_WILL_START : 
                                       (i_right_miss ? LEFT_WILL_START : BALL_IN_GAME);
      endcase
    end

  assign o_left_will_start  = (reg_state == LEFT_WILL_START)  ? 1'b1 : 1'b0;
  assign o_right_will_start = (reg_state == RIGHT_WILL_START) ? 1'b1 : 1'b0;
  assign o_ball_in_game     = (reg_state == BALL_IN_GAME)     ? 1'b1 : 1'b0;

  assign o_state = reg_state;

endmodule

`endif // _GAME_CONTROLLER_V_
