////////////////////////////////////////////////////////
`ifndef _DEFINES_HV_
`define _DEFINES_HV_

`ifndef HSYNC
  `define HSYNC 96
`endif

`ifndef HBACK_PORCH
  `define HBACK_PORCH  48
`endif

`ifndef HFRONT_PORCH
  `define HFRONT_PORCH 16
`endif

`ifndef HVIDEO_ON
  `define HVIDEO_ON    640
`endif

`ifndef VSYNC
  `define VSYNC        2
`endif

`ifndef VBACK_PORCH
  `define VBACK_PORCH  33
`endif

`ifndef VFRONT_PORCH
  `define VFRONT_PORCH 10
`endif

`ifndef VVIDEO_ON
  `define VVIDEO_ON    480
`endif

/////////////////////////////////////////////////////////

`ifndef PADDLE_WIDTH
  `define PADDLE_WIDTH 5
`endif

`ifndef PADDLE_HEIGHT
  `define PADDLE_HEIGHT 100
`endif

`ifndef X_PADDLE_INIT_RIGHT
  `define X_PADDLE_INIT_RIGHT 600
`endif

`ifndef Y_PADDLE_INIT_RIGHT
  `define Y_PADDLE_INIT_RIGHT ((`VVIDEO_ON / 2) - (`PADDLE_HEIGHT / 2))
`endif

`ifndef X_PADDLE_INIT_LEFT
  `define X_PADDLE_INIT_LEFT 35
`endif

`ifndef Y_PADDLE_INIT_LEFT
  `define Y_PADDLE_INIT_LEFT ((`VVIDEO_ON / 2) - (`PADDLE_HEIGHT / 2))
`endif

`ifndef BALL_WIDTH
  `define BALL_WIDTH 16
`endif

`ifndef BALL_HEIGHT
  `define BALL_HEIGHT 16
`endif

`endif // _DEFINES_NV_

