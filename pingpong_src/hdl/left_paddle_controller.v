`ifndef _LEFT_PADDLE_CONTROLLER_V_
  `define _LEFT_PADDLE_CONTROLLER_V_

`timescale 1ns / 1ps

`include "defines.vh"

module game_left_paddle_controller(input i_clock,
                                   input i_reset,
                                   input i_collision_predicted,
                                   input [9:0] i_collision_predicted_y,
                                   input [9:0] i_left_paddle_bar_y,
                                   input i_left_paddle_collision,
                                   input i_ball_move_up,
                                   output o_move_up,
                                   output o_move_down);
  localparam IDLE      = 2'b00;
  localparam MOVE_UP   = 2'b01;
  localparam MOVE_DOWN = 2'b10;

  reg [1:0] reg_state;
  reg [1:0] next_state;
  
  wire [9:0] paddle_middle_y;
  wire [9:0] paddle_dock_y;

  wire paddle_docked;
  wire top_position;
  wire bottom_position;
  wire positioned;

  wire signed [9:0] delta;
  wire signed [9:0] diff;

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
        reg_state <= IDLE;
    else
        reg_state <= next_state;

  assign top_position = (i_left_paddle_bar_y <= 2);
  assign bottom_position = (i_left_paddle_bar_y >= `VVIDEO_ON - 2);

  assign paddle_middle_y = (i_left_paddle_bar_y + `PADDLE_HEIGHT / 2);

  assign paddle_dock_y = i_ball_move_up ? (i_collision_predicted_y + `X_PADDLE_INIT_LEFT)
                                        : (i_collision_predicted_y - `X_PADDLE_INIT_LEFT - `PADDLE_WIDTH);

  assign diff = paddle_dock_y - paddle_middle_y;
  assign delta = (diff[9] == 1) ? -diff : diff;
  assign positioned = (delta < 2) ? 1'b1 : 1'b0;

  assign paddle_docked = (positioned | top_position | bottom_position) ? 1'b1 : 1'b0;

  always @*
    case (reg_state)
      IDLE:
        if (i_collision_predicted & ~positioned)
          next_state = (diff < 0) ? MOVE_UP : MOVE_DOWN;
        else
          next_state = reg_state;
      MOVE_UP:
        next_state = (paddle_docked | i_left_paddle_collision | ~i_collision_predicted) ? IDLE : MOVE_UP;
      MOVE_DOWN:
        next_state = (paddle_docked | i_left_paddle_collision | ~i_collision_predicted) ? IDLE : MOVE_DOWN;
      default:
        next_state = reg_state;
    endcase

  assign o_move_up   = (reg_state == MOVE_UP)   & i_collision_predicted;
  assign o_move_down = (reg_state == MOVE_DOWN) & i_collision_predicted;

endmodule

module start_left_paddle_controller(input i_clock,
                                    input i_reset,
                                    input [9:0] i_left_paddle_bar_y,
                                    input [9:0] i_random,
                                    input i_left_player_start,
                                    input i_ball_in_game,
                                    output o_move_up,
                                    output o_move_down,
                                    output o_ckick,
                                    output [2:0] o_state);

  localparam IDLE       = 3'b000;
  localparam SELECT_POS = 3'b001;
  localparam MOVE_UP    = 3'b010;
  localparam MOVE_DOWN  = 3'b011;
  localparam CKICK_BALL = 3'b100;

  wire left_playe_start_tick; 

  reg [2:0] reg_state;
  reg [2:0] next_state;

  reg [9:0] reg_random_y;
  wire [9:0] next_random_y;

  wire signed [9:0] diff;
  wire signed [9:0] delta;

  reg reg_left_player_start_delay;
  wire left_player_start_pulse;

  always @(posedge i_clock)
    reg_left_player_start_delay <= i_left_player_start;

  assign left_player_start_pulse = i_left_player_start & ~reg_left_player_start_delay;

//  assign next_random_y = 350;
  assign next_random_y =
    (~left_player_start_pulse) ? reg_random_y
                               : (i_random > (`VVIDEO_ON - `PADDLE_HEIGHT) ? (`VVIDEO_ON - `PADDLE_HEIGHT - 2) : i_random);

  assign diff = reg_random_y - i_left_paddle_bar_y;
  assign delta = (diff[9] == 1) ? -diff : diff;
  assign positioned = (delta < 2) ? 1'b1 : 1'b0; 

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      reg_state <= IDLE;
    else
      reg_state <= next_state;

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      reg_random_y <= 0;
    else
      reg_random_y <= next_random_y;

  always @*
    begin
      next_state = reg_state;
      case (reg_state)
        IDLE:
          next_state = i_left_player_start ? SELECT_POS : IDLE;
        SELECT_POS:
          if (diff > 0)
            next_state = MOVE_DOWN;
          else if (diff < 0)
            next_state = MOVE_UP;
          else
            next_state = CKICK_BALL;
        MOVE_UP:
          next_state = positioned ? CKICK_BALL : MOVE_UP;
        MOVE_DOWN:
          next_state = positioned ? CKICK_BALL : MOVE_DOWN;
        CKICK_BALL:
          next_state = i_ball_in_game ? IDLE : CKICK_BALL;
      endcase
    end

  assign o_move_down = (reg_state == MOVE_DOWN)  ? 1'b1 : 1'b0;
  assign o_move_up   = (reg_state == MOVE_UP)    ? 1'b1 : 1'b0;
  assign o_ckick     = (reg_state == CKICK_BALL && i_left_player_start) ? 1'b1 : 1'b0;

  assign o_state = reg_state;

endmodule

module left_paddle_controller(input i_clock,
                              input i_reset,
                              input i_collision_predicted,
                              input [9:0] i_collision_predicted_y,
                              input [9:0] i_left_paddle_bar_y,
                              input i_left_paddle_collision,
                              input i_ball_move_up,
                              input i_ball_in_game,
                              input i_left_player_start,
                              input [9:0] i_random,
                              output o_move_up,
                              output o_move_down,
                              output o_ckick_ball,
                              output [2:0] o_state);

  wire move_up_game;
  wire move_down_game;
  wire move_up_start;
  wire move_down_start;

//  TODO: debug only
//  assign move_up_start   = 1'b0;
//  assign move_down_start = 1'b0;

  start_left_paddle_controller start_left_paddle_controller0(.i_clock(i_clock),
                                                             .i_reset(i_reset),
                                                             .i_left_paddle_bar_y(i_left_paddle_bar_y),
                                                             .i_random(i_random),
                                                             .i_left_player_start(i_left_player_start),
                                                             .i_ball_in_game(i_ball_in_game),
                                                             .o_move_up(move_up_start),
                                                             .o_move_down(move_down_start),
                                                             .o_ckick(o_ckick_ball),
                                                             .o_state(o_state));

  game_left_paddle_controller game_left_paddle_controller0(.i_clock(i_clock),
                                                           .i_reset(i_reset),
                                                           .i_collision_predicted(i_collision_predicted),
                                                           .i_collision_predicted_y(i_collision_predicted_y),
                                                           .i_left_paddle_bar_y(i_left_paddle_bar_y),
                                                           .i_left_paddle_collision(i_left_paddle_collision),
                                                           .i_ball_move_up(i_ball_move_up),
                                                           .o_move_up(move_up_game),
                                                           .o_move_down(move_down_game));

  assign o_move_up   = i_ball_in_game ? move_up_game   : (i_left_player_start ? move_up_start   : 1'b0);
  assign o_move_down = i_ball_in_game ? move_down_game : (i_left_player_start ? move_down_start : 1'b0);

endmodule

`endif // _LEFT_PADDLE_CONTROLLER_V_
