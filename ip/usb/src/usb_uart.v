`ifdef SYNTHESIS

`define PlATFORM_i40
`ifdef PlATFORM_i40
`include "plat/usb_uart_i40.v"
`endif

`else

`include "plat/usb_uart_dummy.v"

`endif
