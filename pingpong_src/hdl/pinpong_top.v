`timescale 1ns / 1ps

`include "vga_sync_gen.v"
`include "game_controller.v"
`include "ball_renderer.v"
`include "debouncer.v"
`include "paddle_bar.v"
`include "collision_predictor.v"
`include "left_paddle_controller.v"
`include "lfsr.v"
`include "defines.vh"

module pinpong_top(input i_system_clock,
                   input i_reset_btn,
                   input i_move_up_btn,
                   input i_move_down_btn,
                   input i_ckick_btn,
                   output [3:0] o_red,
                   output [3:0] o_green,
                   output [3:0] o_blue,
                   output o_hsync,
                   output o_vsync,
                   output [3:0] o_led);

  wire pixel_clock;
  wire video_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  wire hsync;
  wire vsync;

  wire ball_gfx_on;
  wire right_paddle_gfx_on;
  wire left_paddle_gfx_on;

  wire reset_db;
  wire move_up_db;
  wire move_down_db;
  wire ckick_db;

  wire [9:0] right_paddle_x;
  wire [9:0] right_paddle_y;
  wire [9:0] left_paddle_x;
  wire [9:0] left_paddle_y;
  wire [9:0] random;

  wire [9:0] left_collision_y;
  wire left_collision_y_valid;

  wire left_paddle_move_up;
  wire left_paddle_move_down;
  wire left_paddle_collision;
  wire ball_move_up;

  wire left_ckick;
  wire left_miss;
  wire right_miss;
  wire left_will_start;
  wire right_will_start;
  wire ball_in_game;

  wire [9:0] x_ball;
  wire [9:0] y_ball;

  reg [3:0] red;
  reg [3:0] green;
  reg [3:0] blue;

  reg vsync_delay;
  wire vsync_start;

  reg reg_reset0;
  reg reg_reset1;
  reg reg_move_down0;
  reg reg_move_down1;
  reg reg_move_up0;
  reg reg_move_up1;
  reg reg_ckick0;
  reg reg_ckick1;
    
  clk_wiz_0 mmcm0(.system_clock(i_system_clock),
                  .pixel_clock(pixel_clock));

  debouncer debouncer0(.i_clock(i_system_clock),
                       .i_reset(reset_db),
                       .i_button(i_reset_btn),
                       .o_button(reset_db));

  debouncer debouncer1(.i_clock(i_system_clock),
                       .i_reset(reset_db),
                       .i_button(i_move_up_btn),
                       .o_button(move_up_db));

  debouncer debouncer2(.i_clock(i_system_clock),
                       .i_reset(reset_db),
                       .i_button(i_move_down_btn),
                       .o_button(move_down_db));

  debouncer debouncer3(.i_clock(i_system_clock),
                       .i_reset(reset_db),
                       .i_button(i_ckick_btn),
                       .o_button(ckick_db));

  always @(posedge pixel_clock)
    begin
      vsync_delay    <= vsync;

      reg_reset0     <= reset_db;
      reg_reset1     <= reg_reset0;
      reg_move_down0 <= move_down_db;
      reg_move_down1 <= reg_move_down0;
      reg_move_up0   <= move_up_db;
      reg_move_up1   <= reg_move_up0;
      reg_ckick0     <= ckick_db;
      reg_ckick1     <= reg_ckick0;

    end

  assign vsync_start = vsync_delay & ~vsync;

  // TODO: debug only
  wire [2:0] state;

  vga_sync_gen vga_sync_gen0(.i_pixel_clock(pixel_clock),
                             .i_reset(reg_reset1),
                             .o_hsync(hsync),
                             .o_vsync(vsync),
                             .o_video_on(video_on),
                             .o_hpos(hpos),
                             .o_vpos(vpos));

  lfsr lfsr0(.i_clock(pixel_clock),
             .i_reset(reg_reset1),
             .o_q(random));

  game_controller game_controller0(.i_reset(reg_reset1),
                                   .i_clock(pixel_clock),
                                   .i_left_ckick(left_ckick),
                                   .i_right_ckick(reg_ckick1),
                                   .i_left_miss(left_miss),
                                   .i_right_miss(right_miss),
                                   .o_left_will_start(left_will_start),
                                   .o_right_will_start(right_will_start),
                                   .o_ball_in_game(ball_in_game));
//                                   .o_state(state));

  paddle_bar_position #(.X_INIT(`X_PADDLE_INIT_RIGHT), .Y_INIT(`Y_PADDLE_INIT_RIGHT)) 
                      paddle_bar_position_right(.i_clock(pixel_clock),
                                                .i_reset(reg_reset1),
                                                .i_vsync_pulse(vsync_start),
                                                .i_move_paddle_up(reg_move_up1),
                                                .i_move_paddle_down(reg_move_down1),
                                                .o_paddle_x(right_paddle_x),
                                                .o_paddle_y(right_paddle_y));

  paddle_bar_position #(.X_INIT(`X_PADDLE_INIT_LEFT), .Y_INIT(`Y_PADDLE_INIT_LEFT)) 
                      paddle_bar_position_left(.i_clock(pixel_clock),
                                               .i_reset(reg_reset1),
                                               .i_vsync_pulse(vsync_start),
                                               .i_move_paddle_up(left_paddle_move_up),
                                               .i_move_paddle_down(left_paddle_move_down),
                                               .o_paddle_x(left_paddle_x),
                                               .o_paddle_y(left_paddle_y));

  ball_position ball_position0(.i_clock(pixel_clock),
                               .i_reset(reg_reset1),
                               .i_vsync_pulse(vsync_start),
                               .i_right_paddle_pos_x(right_paddle_x),
                               .i_right_paddle_pos_y(right_paddle_y),
                               .i_left_paddle_pos_x(left_paddle_x),
                               .i_left_paddle_pos_y(left_paddle_y),
                               .i_left_player_start(left_will_start),
                               .i_right_player_start(right_will_start),
                               .i_ball_in_game(ball_in_game),
                               .o_ball_pos_x(x_ball),
                               .o_ball_pos_y(y_ball),
                               .o_left_paddle_collision(left_paddle_collision),
                               .o_left_miss(left_miss),
                               .o_right_miss(right_miss));

  collision_predictor left_collision_predictor(.i_clock(pixel_clock),
                                               .i_reset(reg_reset1),
                                               .i_vsync_start(vsync_start),
                                               .i_ball_current_x(x_ball),
                                               .i_ball_current_y(y_ball),
                                               .o_predicted_valid(left_collision_y_valid),
                                               .o_predicted_y(left_collision_y),
                                               .o_ball_move_up(ball_move_up));

  left_paddle_controller left_paddle_controller0(.i_clock(pixel_clock),
                                                 .i_reset(reg_reset1),
                                                 .i_collision_predicted(left_collision_y_valid),
                                                 .i_collision_predicted_y(left_collision_y),
                                                 .i_left_paddle_bar_y(left_paddle_y),
                                                 .i_left_paddle_collision(left_paddle_collision),
                                                 .i_ball_move_up(ball_move_up),
                                                 .i_ball_in_game(ball_in_game),
                                                 .i_left_player_start(left_will_start),
                                                 .i_random(random),
                                                 .o_move_up(left_paddle_move_up),
                                                 .o_move_down(left_paddle_move_down),
                                                 .o_ckick_ball(left_ckick),
                                                 .o_state(state));

  paddle_renderer paddle_renderer_right(.i_hpos(hpos),
                                        .i_vpos(vpos),
                                        .i_paddle_x(right_paddle_x),
                                        .i_paddle_y(right_paddle_y),
                                        .o_paddle_gfx_on(right_paddle_gfx_on));

  paddle_renderer paddle_renderer_left(.i_hpos(hpos),
                                       .i_vpos(vpos),
                                       .i_paddle_x(left_paddle_x),
                                       .i_paddle_y(left_paddle_y),
                                       .o_paddle_gfx_on(left_paddle_gfx_on));

  ball_renderer ball_renderer0(.i_clock(pixel_clock),
                               .i_reset(reg_reset1),
                               .i_hpos(hpos),
                               .i_vpos(vpos),
                               .i_ball_x(x_ball),
                               .i_ball_y(y_ball),
                               .i_hsync(hsync),
                               .o_ball_gfx_on(ball_gfx_on));

  assign o_hsync = hsync;
  assign o_vsync = vsync;

  assign o_red   = (video_on & ~ball_gfx_on & ~right_paddle_gfx_on & ~left_paddle_gfx_on) ? 4'b1111 : 4'b0000;
  assign o_green = (video_on & ~ball_gfx_on & ~right_paddle_gfx_on & ~left_paddle_gfx_on) ? 4'b1111 : 4'b0000;
  assign o_blue  = (video_on & ~ball_gfx_on & ~right_paddle_gfx_on & ~left_paddle_gfx_on) ? 4'b1111 : 4'b0000;

  assign o_led[0] = state[0];
  assign o_led[1] = state[1];
  assign o_led[2] = state[2];
  assign o_led[3] = right_miss;

endmodule
