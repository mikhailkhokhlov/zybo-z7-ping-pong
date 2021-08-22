`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2021 04:31:33 PM
// Design Name: 
// Module Name: test_ball_position
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
`include "../../sources_1/new/positions.v"

module test_ball_position();

  reg clock = 0;
  reg reset = 0;
  reg [9:0] hpos = 0;
  reg [9:0] vpos = 0;
  reg hsync = 0;
  reg vsync = 0;

  wire [9:0] x_ball;
  wire [9:0] y_ball;

  reg ckick = 0;

  reg [9:0] paddle_x;
  reg [9:0] paddle_y;

  reg vsync_start;

  ball_position dut(.clock_in(clock),
                    .vsync_start_in(vsync_start),
                    .reset_in(reset),
                    .ckick_in(ckick),
                    .right_paddle_x_pos_in(paddle_x),
                    .right_paddle_y_pos_in(paddle_y),
                    .left_paddle_x_pos_in(paddle_x),
                    .left_paddle_y_pos_in(paddle_y),
                    .current_x_pos_out(x_ball),
                    .current_y_pos_out(y_ball));

  integer i;

  initial begin
    ckick = 0; #4;
    ckick = 1; #12;
    ckick = 0;
  end

  initial begin
    reset = 0; #2;
    reset = 1; #4;
    reset = 0;
  end

  initial begin
    $dumpfile("position.out");
    $dumpvars(0, dut);

    paddle_x = 600;
    paddle_y = 0;
 
    for (i = 0; i < 3 * 16 * 800 * 492; i = i + 1)
      begin
        clock = ~clock;
      
        if (i == 0)
          begin
            hpos = 1'b0;
            vpos = 1'b0;
            hsync = 1'b0;
            vsync = 1'b0;
          end
        else
          begin
            if (clock)
              begin
                hpos = (hpos == 800) ? 0 : hpos + 1;
                vpos = (vpos == 525) ? 0 : ((hpos == 800) ? vpos + 1 : vpos);
                hsync = (hpos >= 656 && hpos <= 751) ? 1'b1 : 1'b0;
                vsync = (vpos >= 490 && vpos <= 491) ? 1'b1 : 1'b0;
                vsync_start = (vpos == 490 && hpos == 800 && clock);
              end
          end
        #5;
      end
      
    $finish;
  end

endmodule
