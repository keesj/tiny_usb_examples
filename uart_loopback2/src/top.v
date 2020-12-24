/*
    USB Serial
    Wrapping usb/usb_uart_ice40.v to create a loopback but with a fifo this time.
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

  /* fifo to store 4 bytes  */
  reg [7:0] fifo [3:0]; // 
  reg [1:0]  fifo_start = 2'b00;
  reg [1:0]  fifo_end = 2'b00;
  wire fifo_full;
  wire fifo_empty;
  assign fifo_full = (fifo_end + 1 == fifo_start);
  assign fifo_empty = (fifo_start == fifo_end);

  assign uart_out_ready = ~fifo_full; /* as long as the fifo is not full there is room */
  
  always @(posedge clk_48mhz)
  begin       

    if (uart_out_valid && ~fifo_full)
      begin
          // when data is available push it into the fifo
          fifo[fifo_end] = uart_out_data;
          fifo_end <= fifo_end +1;
      end

    if (uart_in_ready || (~uart_in_valid && ~uart_in_ready))
      begin
        if (~fifo_empty)
          begin
                uart_in_data <= fifo[fifo_start];
                fifo_start <= fifo_start +1;              
                uart_in_valid <= 1;
          end
        else
          begin
                uart_in_valid <= 0;
          end
      end
  end
  // USB Host Detect Pull Up
  assign pin_pu = 1'b1;

endmodule
