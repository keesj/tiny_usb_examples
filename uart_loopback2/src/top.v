/*
    USB Serial

    Wrapping usb/usb_uart_ice40.v to create a loopback.
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
    reg       uart_in_valid;
    wire       uart_in_ready;

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

  /* Simple fifo, store data in fifo, store used entries in fifo_state */
  reg [31:0] fifo = 32'b0; // dead simple fifo
  reg [3:0]  fifo_state = 4'b0000;
  wire fifo_full;
  wire fifo_empty;
  assign fifo_full = (fifo_state == 4'b1111);
  assign fifo_empty = (fifo_state == 4'b0000);
  assign uart_out_ready = ~ fifo_full; /* as long as the fifo is not fill there is room */
  
  always @(posedge clk_48mhz)
  begin
        if (uart_out_valid && ~ fifo_full)
        begin
           //
           fifo = {uart_out_data,fifo[25:0]}; 
           fifo_state = {1'b1,fifo_state[2:0]};
        end
        
        if(uart_in_ready && ~fifo_empty)
       begin
           uart_in_data <= fifo[31:26];
           fifo = {fifo[25:0],8'b0}; 
           fifo_state = {fifo_state[2:0],1'b0};
           uart_in_valid <= 1;
        end
        if (fifo_empty)
        begin
            uart_in_valid <= 0;
        end
        
  end
  // USB Host Detect Pull Up
  assign pin_pu = 1'b1;

endmodule
