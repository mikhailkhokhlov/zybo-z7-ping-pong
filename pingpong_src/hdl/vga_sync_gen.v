`ifndef _VGA_SYNQ_GEN_V_VGA_
  `define _VGA_SYNQ_GEN_V_VGA_

`timescale 1ns / 1ps

`include "defines.vh"

module vga_sync_gen (input i_pixel_clock,
                     input i_reset,
                     output o_hsync,
                     output o_vsync,
                     output o_video_on,
                     output [9:0] o_hpos,
                     output [9:0] o_vpos);
/*
localparam HSYNC        = 96;
localparam HBACK_PORCH  = 48;
localparam HFRONT_PORCH = 16;
localparam HVIDEO_ON    = 640;

localparam VSYNC        = 2;
localparam VBACK_PORCH  = 33;
localparam VFRONT_PORCH = 10;
localparam VVIDEO_ON    = 480;
*/
reg [9:0] reg_o_hpos, next_o_hpos;
reg [9:0] reg_o_vpos, next_o_vpos;
reg reg_o_hsync;
wire next_o_hsync;
reg reg_o_vsync; 
wire next_o_vsync;

wire end_of_line;
wire end_of_frame;

always @(posedge i_pixel_clock, posedge i_reset)
begin
  if (i_reset)
    begin
      reg_o_hpos <= 0;
      reg_o_vpos <= 0;
      reg_o_hsync <= 0;
      reg_o_vsync <= 0;
    end
  else
    begin
      reg_o_hpos <= next_o_hpos; 
      reg_o_vpos <= next_o_vpos;
      reg_o_hsync <= next_o_hsync;
      reg_o_vsync <= next_o_vsync;
    end
end

assign end_of_line = (reg_o_hpos == (`HSYNC + `HBACK_PORCH + `HVIDEO_ON + `HFRONT_PORCH));
assign end_of_frame = (reg_o_vpos == (`VSYNC + `VBACK_PORCH + `VVIDEO_ON + `VFRONT_PORCH));

always @*
begin
  if (end_of_line)
    next_o_hpos = 0;
  else
    next_o_hpos = reg_o_hpos + 1;
end

always @*
begin
  next_o_vpos = reg_o_vpos;

  if (end_of_frame)
    next_o_vpos = 0;
  else if (end_of_line)
    next_o_vpos = reg_o_vpos + 1;
end

assign o_hpos = reg_o_hpos;
assign o_vpos = reg_o_vpos;

assign next_o_hsync = (reg_o_hpos >= (`HVIDEO_ON + `HFRONT_PORCH)) && 
                    (reg_o_hpos <= (`HVIDEO_ON + `HFRONT_PORCH + `HSYNC - 1));

assign next_o_vsync = (reg_o_vpos >= (`VVIDEO_ON + `VFRONT_PORCH)) &&
                    (reg_o_vpos >= (`VVIDEO_ON + `VFRONT_PORCH + `VSYNC - 1));

assign o_video_on = (reg_o_hpos < `HVIDEO_ON) && (reg_o_vpos < `VVIDEO_ON);
assign o_hsync = reg_o_hsync;
assign o_vsync = reg_o_vsync;

endmodule

`endif // _VGA_SYNQ_GEN_V_VGA_

