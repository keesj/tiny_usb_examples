/*
    USB Serial
    Wrapping usb/usb_uart_ice40.v to create a loopback but with a fifo this time.
    This code show a more realistic case where we get a change do modify the data 
    in between.
*/

module top (
        input  pin_clk,

        inout  pin_usb_p,
        inout  pin_usb_n,
        output pin_pu,

        output pin_led,

        output [3:0] debug
    );

    wire clk_48mhz;
    wire clk_locked;

    // Use an icepll generated pll
    pll pll48( .clock_in(pin_clk), .clock_out(clk_48mhz), .locked( clk_locked ) );

    // LED
    reg [22:0] ledCounter;
    always @(posedge clk_48mhz) begin
        ledCounter <= ledCounter + 1;
    end
    assign pin_led = ledCounter[ 22 ];

    // Generate reset signal
    wire reset;
    global_reset grst(
        .clk(clk_48mhz),
        .rst_in(clk_locked),
        .rst(reset));

    // uart pipeline in
    reg [7:0] uart_in_data;
    reg       uart_in_valid = 1'b0;
    wire      uart_in_ready;

    wire [7:0] uart_out_data;
    wire       uart_out_valid;
    wire       uart_out_ready;
    // assign debug = { uart_in_valid, uart_in_ready, reset, clk_48mhz };

    // usb uart - this instanciates the entire USB device.
    usb_uart uart (
        .clk_48mhz  (clk_48mhz),
        .reset      (reset),

        // pins
        .pin_usb_p( pin_usb_p ),
        .pin_usb_n( pin_usb_n ),

        // uart pipeline in
        .uart_in_data( uart_in_data ),
        .uart_in_valid( uart_in_valid ),
        .uart_in_ready( uart_in_ready ),

        .uart_out_data( uart_out_data ),
        .uart_out_valid( uart_out_valid ),
        .uart_out_ready( uart_out_ready  )

        //.debug( debug )
    );

  wire [7:0] from_uart;
  reg from_uart_en = 1'b0;
  wire fifo_in_full;
  wire fifo_in_empty;

  assign uart_out_ready = ~fifo_in_full; /* as long as the fifo is not full there is room to recieve data  */

  fifo fifo_in (
    .clk(clk_48mhz),
    .rst(reset),
    .data_in(uart_out_data), /* direct feed from usb uart */
    .data_in_en(uart_out_valid), /* direct feed from usb uart */

    .data_out(from_uart),
    .data_out_en(from_uart_en),
    .full(fifo_in_full),
    .empty(fifo_in_empty)
  );

  always @(posedge clk_48mhz) begin
    if (uart_in_ready || (~uart_in_valid && ~uart_in_ready)) begin
      if (~fifo_in_empty) begin
              uart_in_data <= from_uart ; //from_uart;
              from_uart_en <= 1'b1;
              uart_in_valid <= 1'b1;
      end else begin
        uart_in_valid <= 1'b0;
        from_uart_en <= 1'b0;
      end
    end
  end
  // USB Host Detect Pull Up
  assign pin_pu = 1'b1;

endmodule
