`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2020 10:20:00 PM
// Design Name: 
// Module Name: text_ball_renderer
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
`include "../../sources_1/new/ball_renderer.v"

module test_ball_renderer();

reg clock = 0;
reg reset = 0;
reg [9:0] hpos = 0;
reg [9:0] vpos = 0;
reg hsync = 0;
reg vsync = 0;
wire bitmap_addr_valid;
wire [15:0] bitmap;
wire [3:0] addr_out;
wire ball_gfx_on;

bitmap_file ball(.addr_in(addr_out),
                 .addr_valid_in(bitmap_addr_valid),
                 .bitmap_out(bitmap));

renderer_fsm dut(.clock_in(clock),
                 .reset_in(reset),
                 .hpos_in(hpos),
                 .vpos_in(vpos),
                 .hsync_in(hsync),
                 .vsync_in(vsync),
                 .bitmap_in(bitmap),
                 .addr_valid_out(bitmap_addr_valid),
                 .addr_out(addr_out),
                 .ball_gfx_on_out(ball_gfx_on));

integer i;

initial begin
  $dumpfile("render_fsm.out");
  $dumpvars(0, dut);
  
  reset = 1; #2;
  reset = 0; #3;
  

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
            end
        end

      #5;
    end
      
  $finish;
end

endmodule
