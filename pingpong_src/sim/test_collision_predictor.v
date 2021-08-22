`timescale 1ns / 1ps

`include "../../sources_1/new/collision_predictor.v"

module test_collision_predictor();

reg clock = 0;
reg reset = 0;
reg [9:0] ball_x;
reg [9:0] ball_y;
reg vsync_start;

wire left_collision_valid;
wire [9:0] left_collision_y;

wire ball_move_up;

collision_predictor dut(.clock_in(clock),
                        .reset_in(reset),
                        .vsync_start_in(vsync_start),
                        .ball_current_x_in(ball_x),
                        .ball_current_y_in(ball_y),
                        .predicted_valid_out(left_collision_valid),
                        .predicted_y_out(left_collision_y),
                        .ball_move_up_out(ball_move_up));

initial
  begin
    clock = 0;
    vsync_start = 0;
    reset = 0; #2;
    reset = 1; #2;
    reset = 0;

    forever #5 clock = ~clock;
  end

initial
  begin
    vsync_start = 0; #5;
    vsync_start = 1; #12;
    vsync_start = 0;
  end

initial
  begin
    ball_x = 460;
    ball_y = 150; #10;

    while (ball_y > 2)
      begin
        ball_x = ball_x - 2;
        ball_y = ball_y - 2;
        #10;
      end

   while (ball_x > 2)
     begin
       ball_x = ball_x - 2;
       ball_y = ball_y + 2;
       #10;
     end

   while (ball_y < 480 - 16 - 2)
     begin
       ball_x = ball_x + 2;
       ball_y = ball_y + 2;
       #10;
     end

    $finish;
  end

endmodule
