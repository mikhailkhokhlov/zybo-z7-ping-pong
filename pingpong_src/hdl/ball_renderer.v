`ifndef _BALL_RENDERER_V_
  `define _BALL_RENDERER_V_

`timescale 1ns / 1ps

`include "defines.vh"

module bitmap_file(input wire [3:0] i_addr,
                   input wire i_addr_valid,
                   output wire [15:0] o_bitmap);

  reg [15:0] reg_bitmap;

  always @*
    case(i_addr)
      4'b0000: reg_bitmap = 16'b0000_0111_1110_0000;
      4'b0001: reg_bitmap = 16'b0001_1111_1111_1000;
      4'b0010: reg_bitmap = 16'b0011_1111_1111_1100;
      4'b0011: reg_bitmap = 16'b0111_1111_1111_1110;
      4'b0100: reg_bitmap = 16'b0111_1111_1111_1110;
      4'b0101: reg_bitmap = 16'b0111_1111_1111_1110;
      4'b0110: reg_bitmap = 16'b1111_1111_1111_1111;
      4'b0111: reg_bitmap = 16'b1111_1111_1111_1111;

      4'b1000: reg_bitmap = 16'b1111_1111_1111_1111;
      4'b1001: reg_bitmap = 16'b1111_1111_1111_1111;
      4'b1010: reg_bitmap = 16'b0111_1111_1111_1110;
      4'b1011: reg_bitmap = 16'b0111_1111_1111_1110;
      4'b1100: reg_bitmap = 16'b0111_1111_1111_1110;
      4'b1101: reg_bitmap = 16'b0011_1111_1111_1100;
      4'b1110: reg_bitmap = 16'b0001_1111_1111_1000;
      4'b1111: reg_bitmap = 16'b0000_0111_1110_0000;
    endcase

  assign o_bitmap = (i_addr_valid) ? reg_bitmap : 16'b0000_0000_0000_0000;

endmodule

module start_ball_position(input i_clock,
                           input i_vsync_pulse,
                           input i_reset,
                           input [9:0] i_right_paddle_x_pos,
                           input [9:0] i_right_paddle_y_pos,
                           input [9:0] i_left_paddle_x_pos,
                           input [9:0] i_left_paddle_y_pos,
                           input i_left_player_start,
                           input i_right_player_start,
                           output [9:0] o_ball_pos_x,
                           output [9:0] o_ball_pos_y);

  reg [9:0] next_ball_pos_x, reg_ball_pos_x;
  reg [9:0] next_ball_pos_y, reg_ball_pos_y;

  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      begin
        reg_ball_pos_x <= 0;
        reg_ball_pos_y <= 0;
      end
    else if (i_vsync_pulse)
      begin
        reg_ball_pos_x <= next_ball_pos_x;
        reg_ball_pos_y <= next_ball_pos_y;
      end

  always @*
    case ({i_left_player_start, i_right_player_start})
      2'b00,
      2'b11:
        begin
          next_ball_pos_x = reg_ball_pos_x;
          next_ball_pos_y = reg_ball_pos_y;
        end
      2'b01:
        begin
          next_ball_pos_x = i_right_paddle_x_pos - `BALL_WIDTH;
          next_ball_pos_y = i_right_paddle_y_pos + (`PADDLE_HEIGHT / 2)  - (`BALL_HEIGHT / 2);
        end
      2'b10:
        begin
          next_ball_pos_x = i_left_paddle_x_pos + `PADDLE_WIDTH;
          next_ball_pos_y = i_left_paddle_y_pos + (`PADDLE_HEIGHT / 2)  - (`BALL_HEIGHT / 2);
        end
    endcase

  assign o_ball_pos_x = reg_ball_pos_x;
  assign o_ball_pos_y = reg_ball_pos_y;

endmodule

module game_ball_position(input i_clock,
                          input i_vsync_pulse,
                          input i_reset,
                          input i_ball_in_game,
                          input i_left_player_start,
                          input i_right_player_start, 
                          input [9:0] i_right_paddle_pos_x,
                          input [9:0] i_right_paddle_pos_y,
                          input [9:0] i_left_paddle_pos_x,
                          input [9:0] i_left_paddle_pos_y,
                          input [9:0] i_ball_x_init,
                          input [9:0] i_ball_y_init,
                          output [9:0] o_ball_pos_x,
                          output [9:0] o_ball_pos_y,
                          output o_left_paddle_collision,
                          output o_left_miss,
                          output o_right_miss);

  reg [9:0] reg_pos_x;
  reg [9:0] reg_pos_y;
  reg [9:0] next_pos_x;
  reg [9:0] next_pos_y;

  // TODO: delta can be 2 bits width
  // next_pos = reg_pos + {6zero, delta}
  reg signed [9:0] reg_delta_x;
  reg signed [9:0] reg_delta_y;
  reg signed [9:0] next_delta_x;
  reg signed [9:0] next_delta_y;

  reg reg_left_miss;
  reg reg_right_miss;
  reg next_left_miss;
  reg next_right_miss;

  wire top_collision;
  wire bottom_collision;
  wire left_collision;
  wire right_collision;

  wire right_paddle_collision;
  wire left_paddle_collision;
  
  always @(posedge i_clock, posedge i_reset)
    if (i_reset)
      begin
        reg_pos_x      <= 0;
        reg_pos_y      <= 0;
        reg_delta_x    <= -2;
        reg_delta_y    <= 2;
        reg_left_miss  <= 0;
        reg_right_miss <= 0;
      end
    else if (i_vsync_pulse)
      begin
        reg_pos_x      <= next_pos_x;
        reg_pos_y      <= next_pos_y;
        reg_delta_x    <= next_delta_x;
        reg_delta_y    <= next_delta_y;
        reg_left_miss  <= next_left_miss;
        reg_right_miss <= next_right_miss;
      end

  always @*
    begin
      next_pos_x = i_ball_in_game ? (reg_pos_x + reg_delta_x) : i_ball_x_init;
      next_pos_y = i_ball_in_game ? (reg_pos_y + reg_delta_y) : i_ball_y_init;
    end
 
  assign top_collision    = (reg_pos_y <= 2);
  assign bottom_collision = (reg_pos_y >= `VVIDEO_ON - `BALL_HEIGHT);
  assign left_collision   = (reg_pos_x <= 2);
  assign right_collision  = (reg_pos_x >= `HVIDEO_ON - `BALL_WIDTH);

  assign right_paddle_collision = reg_pos_x + `BALL_WIDTH >= i_right_paddle_pos_x + 2 &
                                  reg_pos_y + 16 >= i_right_paddle_pos_y + 2 & 
                                  reg_pos_y + 16 <= i_right_paddle_pos_y + `PADDLE_HEIGHT - 2;

  // TODO: reg_pos_y + 16 >= left_paddle_y_pos + 16 ???
  assign left_paddle_collision = reg_pos_x <= i_left_paddle_pos_x + `PADDLE_WIDTH + 2  &
                                 reg_pos_y + `BALL_HEIGHT >= i_left_paddle_pos_y + `BALL_HEIGHT + 2 & 
                                 reg_pos_y + `BALL_HEIGHT <= i_left_paddle_pos_y + `PADDLE_HEIGHT - 2;

  always @*
    begin
      next_delta_x = reg_delta_x;
      next_delta_y = reg_delta_y;
      next_left_miss = i_ball_in_game ? reg_left_miss : 1'b0;
      next_right_miss = i_ball_in_game ? reg_right_miss : 1'b0;

      if (i_right_player_start )
        begin
          next_delta_x = -2;
          next_delta_y = 2;
        end

      if (i_left_player_start)
        begin
          next_delta_x = 2;
          next_delta_y = 2;
       end

      if (top_collision && i_ball_in_game)
        next_delta_y = 2;

      if (bottom_collision && i_ball_in_game)
        next_delta_y = -2;

      if (left_collision && i_ball_in_game)
      begin
        next_delta_x = 2;
        next_left_miss = 1'b1;
      end

      if (right_collision && i_ball_in_game)
      begin
        next_delta_x = -2;
        next_right_miss = 1'b1;
      end

      if (right_paddle_collision && i_ball_in_game)
        next_delta_x = -2;

      if (left_paddle_collision && i_ball_in_game)
        next_delta_x = 2;
    end

  assign o_ball_pos_x = reg_pos_x;
  assign o_ball_pos_y = reg_pos_y;

  assign o_left_paddle_collision = left_paddle_collision;

  assign o_left_miss = reg_left_miss;
  assign o_right_miss = reg_right_miss;
 
endmodule

module ball_position(input i_clock,
                     input i_vsync_pulse,
                     input i_reset,
                     input [9:0] i_right_paddle_pos_x,
                     input [9:0] i_right_paddle_pos_y,
                     input [9:0] i_left_paddle_pos_x,
                     input [9:0] i_left_paddle_pos_y,
                     input i_left_player_start,
                     input i_right_player_start,
                     input i_ball_in_game,
                     output [9:0] o_ball_pos_x,
                     output [9:0] o_ball_pos_y,
                     output o_left_paddle_collision,
                     output o_left_miss,
                     output o_right_miss);

  wire [9:0] ball_start_pos_x;
  wire [9:0] ball_start_pos_y;
  wire [9:0] ball_game_pos_x;
  wire [9:0] ball_game_pos_y;

  wire left_paddle_collision;
  wire left_miss;
  wire right_miss;

  start_ball_position start_ball_position0(.i_clock(i_clock),
                                           .i_vsync_pulse(i_vsync_pulse),
                                           .i_reset(i_reset),
                                           .i_right_paddle_x_pos(i_right_paddle_pos_x),
                                           .i_right_paddle_y_pos(i_right_paddle_pos_y),
                                           .i_left_paddle_x_pos(i_left_paddle_pos_x),
                                           .i_left_paddle_y_pos(i_left_paddle_pos_y),
                                           .i_left_player_start(i_left_player_start),
                                           .i_right_player_start(i_right_player_start),
                                           .o_ball_pos_x(ball_start_pos_x),
                                           .o_ball_pos_y(ball_start_pos_y));

  game_ball_position game_ball_position0(.i_clock(i_clock),
                                         .i_reset(i_reset),
                                         .i_vsync_pulse(i_vsync_pulse),
                                         .i_ball_in_game(i_ball_in_game),
                                         .i_left_player_start(i_left_player_start),
                                         .i_right_player_start(i_right_player_start),
                                         .i_right_paddle_pos_x(i_right_paddle_pos_x),
                                         .i_right_paddle_pos_y(i_right_paddle_pos_y),
                                         .i_left_paddle_pos_x(i_left_paddle_pos_x),
                                         .i_left_paddle_pos_y(i_left_paddle_pos_y),
                                         .i_ball_x_init(ball_start_pos_x),
                                         .i_ball_y_init(ball_start_pos_y),
                                         .o_ball_pos_x(ball_game_pos_x),
                                         .o_ball_pos_y(ball_game_pos_y),
                                         .o_left_paddle_collision(left_paddle_collision),
                                         .o_left_miss(left_miss),
                                         .o_right_miss(right_miss));

  assign o_ball_pos_x = i_ball_in_game ? ball_game_pos_x : ball_start_pos_x;
  assign o_ball_pos_y = i_ball_in_game ? ball_game_pos_y : ball_start_pos_y;

  assign o_left_miss = i_ball_in_game ? left_miss : 1'b0;
  assign o_right_miss = i_ball_in_game ? right_miss : 1'b0;

  assign o_left_paddle_collision = i_ball_in_game ? left_paddle_collision : 1'b0;

endmodule

module renderer_fsm(input i_clock,
                    input i_reset,
                    input [9:0] i_hpos,
                    input [9:0] i_vpos,
                    input [9:0] i_ball_x,
                    input [9:0] i_ball_y,
                    input i_hsync,
                    input [15:0] i_bitmap,
                    output o_addr_valid,
                    output [3:0] o_addr,
                    output o_ball_gfx_on);
                    
  localparam WAIT_FOR_LINE  = 0;
  localparam WAIT_FOR_HSYNC = 1;
  localparam LOAD_BITMAP    = 2;
  localparam DRAW_LINE      = 3;

  reg [2:0] reg_state;
  reg [2:0] next_state;

  reg [3:0] reg_x_offset;
  reg [3:0] reg_y_offset;
  reg [3:0] next_x_offset;
  reg [3:0] next_y_offset;

  reg [15:0] reg_bitmap;
  reg [15:0] next_bitmap;

  wire load;
  wire hsync;
  wire start_draw;
  wire end_of_line;
  wire end_of_sprite;

  always @(posedge i_clock, posedge i_reset)
  begin
    if (i_reset)
      begin
        reg_state <= WAIT_FOR_LINE;
        reg_x_offset <= 4'b0000;
        reg_y_offset <= 4'b0000;
        reg_bitmap <= 16'b0000_0000_0000_0000;
      end
    else
      begin
        reg_state <= next_state;
        reg_x_offset <= next_x_offset;
        reg_y_offset <= next_y_offset;
        reg_bitmap <= next_bitmap;
      end
  end

  assign load = (i_vpos == i_ball_y && i_hpos == 0);
  assign start_draw = (i_hpos == i_ball_x) && (i_vpos >= i_ball_y && i_vpos <= i_ball_y + 16);
  assign end_of_line = (reg_x_offset == 15);
  assign end_of_sprite = (reg_y_offset == 15);

  always @*
  begin
    next_state = reg_state;

    case(reg_state)
      WAIT_FOR_LINE:
        if (load)
          next_state = WAIT_FOR_HSYNC; 
      WAIT_FOR_HSYNC:
        if (i_hsync)
          next_state = LOAD_BITMAP;
      LOAD_BITMAP:
        if (start_draw)
          next_state = DRAW_LINE;
      DRAW_LINE:
        if (end_of_sprite && end_of_line)
          next_state = WAIT_FOR_LINE;
        else if (end_of_line)
          next_state = WAIT_FOR_HSYNC;
    endcase
  end

  always @*
  begin
    next_x_offset = reg_x_offset;
    next_y_offset = reg_y_offset;
    next_bitmap = reg_bitmap;
    
    case(reg_state)
      WAIT_FOR_LINE:
        next_y_offset = 0;
      WAIT_FOR_HSYNC:
        next_x_offset = 0;
      LOAD_BITMAP:
        next_bitmap = i_bitmap;
      DRAW_LINE:
        begin
          next_x_offset = reg_x_offset + 1;
          if (end_of_line)
            next_y_offset = reg_y_offset + 1;
        end
    endcase
  end

  assign o_addr_valid = (reg_state == LOAD_BITMAP) ? 1'b1 : 1'b0;
  assign o_addr = (reg_state == LOAD_BITMAP) ? reg_y_offset : 4'b0000;
  assign o_ball_gfx_on = (reg_state == DRAW_LINE) ? reg_bitmap[reg_x_offset] : 1'b0;

//assign o_ball_gfx_on = ((i_hpos >= 1 && i_hpos < 16) && (i_vpos >= 7 && i_vpos < 23)) ||
//                         ((i_hpos >= 623 && i_hpos < 639) && (i_vpos >= 463 && i_vpos < 479));
                     
endmodule

module ball_renderer(input i_clock,
                     input i_reset,
                     input [9:0] i_hpos,
                     input [9:0] i_vpos,
                     input [9:0] i_ball_x,
                     input [9:0] i_ball_y,
                     input i_hsync,
                     output o_ball_gfx_on);

  wire [3:0] sprite_line_addr;
  wire addr_valid;
  wire [15:0] line_bitmap;

  bitmap_file bitmap(.i_addr(sprite_line_addr),
                     .i_addr_valid(addr_valid),
                     .o_bitmap(line_bitmap));

  renderer_fsm fsm(.i_clock(i_clock),
                   .i_reset(i_reset),
                   .i_hpos(i_hpos),
                   .i_vpos(i_vpos),
                   .i_ball_x(i_ball_x),
                   .i_ball_y(i_ball_y),
                   .i_hsync(i_hsync),
                   .i_bitmap(line_bitmap),
                   .o_addr_valid(addr_valid),
                   .o_addr(sprite_line_addr),
                   .o_ball_gfx_on(o_ball_gfx_on));
endmodule

`endif // _BALL_RENDERER_V_
