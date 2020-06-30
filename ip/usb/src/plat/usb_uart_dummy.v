/*
  dummy uart for testing purposes
*/

module usb_uart (
  input  clk_48mhz,
  input reset,

  // USB pins
  inout  pin_usb_p,
  inout  pin_usb_n,

  // uart pipeline in (out of the device, into the host)
  input [7:0] uart_in_data,
  input       uart_in_valid,
  output      uart_in_ready,

  // uart pipeline out (into the device, out of the host)
  output [7:0] uart_out_data,
  output       uart_out_valid,
  input        uart_out_ready,

  output [11:0] debug
);

endmodule
