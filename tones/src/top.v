module top (
  input  pin_clk,

  inout  pin_usb_p,
  inout  pin_usb_n,
  output pin_pu,

  output pin_led
);

  reg audio_left;
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////
  //////// generate 48 mhz clock
  ////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  wire clk_48mhz;

  pll pll48( 
    .clock_in(pin_clk), 
    .clock_out(clk_48mhz), 
    .locked( clk_locked ) );

  // Generate reset signal based on clk_locked
  wire reset;
  global_reset rsti(
      .clk(clk_48mhz),
      .rst_in(clk_locked),
      .rst(reset)
 );

    // uart pipeline in
    reg [7:0] uart_in_data;
    reg       uart_in_valid = 1'b0;
    wire       uart_in_ready;

    wire [7:0] uart_out_data;
    wire       uart_out_valid;
    reg       uart_out_ready = 1'b1;
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
    );

  localparam  C = 262, D = 294, E = 330, F = 349, G = 392, A = 440 , B = 494, c = 523;

  reg [31:0] frequency;
  reg [31:0] duration = 0;
  reg [21:0] beat_counter = 0;
  reg [2:0] note_counter = 0;
  reg bar_counter = 0;
  wire done;

  reg delay_count;
  reg [1:0] state = 0;

  reg toggle = 1'b1;

  assign pin_led = toggle;

  always @(posedge clk_48mhz) begin
      if (done) begin
        
      end
      if (uart_out_valid) begin
        duration <= 400;
        toggle <= ~toggle;
        case (uart_out_data)
          "A" : frequency <= A;
          "B" : frequency <= B;
          "C" : frequency <= C;
          "D" : frequency <= D;
          "E" : frequency <= E;
          "F" : frequency <= F;
          "G" : frequency <= G;
          "c" : frequency <= c;
        endcase
      end
  end


  assign pin_pu = 1'b1;

  tone t(.clk (clk_48mhz), .duration(duration), .freq (frequency), .tone_out (audio_left), .done(done));

endmodule
