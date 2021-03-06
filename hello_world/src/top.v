/*
    USB Serial
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
    reg [24:0] ledCounter;
    always @(posedge clk_48mhz) begin
        ledCounter <= ledCounter + 1;
    end
    assign pin_led = ledCounter[ 24 ];

    // Generate reset signal
    wire reset;
    global_reset rsti(
        .clk(clk_48mhz),
        .rst_in(clk_locked),
        .rst(reset)
   );

  parameter TEXT_LEN=14;
  // Create the text string
  reg [7:0] text [0:TEXT_LEN-1];
  reg [3:0] char_count =4'b0;

  // uart pipeline in
  reg [7:0] uart_in_data;
  reg       uart_in_valid = 1'b1;
  wire       uart_in_ready;

  initial begin
    text[0]  <= "H";
    text[1]  <= "e";
    text[2]  <= "l";
    text[3]  <= "l";
    text[4]  <= "o";
    text[5]  <= " ";
    text[6]  <= "W";
    text[7]  <= "o";
    text[8]  <= "r";
    text[9]  <= "l";
    text[10] <= "d";
    text[11] <= "!";
    text[12] <= "\r";
    text[13] <= "\n";
  end

/*
    wire [7:0] uart_out_data;
    wire       uart_out_valid;
    wire       uart_out_ready;
    // assign debug = { uart_in_valid, uart_in_ready, reset, clk_48mhz };
*/


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
        .uart_in_ready( uart_in_ready )

/*
        .uart_out_data( uart_out_data ),
        .uart_out_valid( uart_out_valid ),
        .uart_out_ready( uart_out_ready  )
*/

        //.debug( debug )
    );


  parameter STATE_WAIT = 1'b0;
  parameter STATE_TX = 1'b1;

  reg state = STATE_WAIT;
  reg [23:0] cnt = 24'b0;

  always @(posedge clk_48mhz)
  begin
      cnt <= cnt +1'b1;
      case(state)
      STATE_WAIT:
        begin
            uart_in_valid <= 0;
            if (cnt == 24'hffffff)
            begin
                state <= STATE_TX;
            end
        end
      STATE_TX:
        begin
          if (uart_in_ready || (~uart_in_valid && ~uart_in_ready))
          /* While a bit counter intuitive uart_in_ready will not become valid 
           * unless we send data hence, we are allowed to change state either
           * when uart_in_valid: we are already transmitting and because of
           * the pipeline interface we are allowed to change the values or
           * We where not transmitting and need to bootstrap.
           */
          begin
            uart_in_data <= text[char_count];
            uart_in_valid <= 1;
            char_count <= char_count +1;
            if (char_count +1 == TEXT_LEN)
            begin 
                char_count <= 0;
                state <= STATE_WAIT;
                cnt <= 24'b0;
            end 
          end
        end
      endcase
  end

  // USB Host Detect Pull Up
  assign pin_pu = 1'b1;

endmodule
