module swim_rst(
  input clk,
  input rst,
  input en,
  inout swim,
  output swim_en,
  output reg rdy = 1'b0
);
  reg [44:0] data =45'b00000000111111100110011001100110010101010001;
  assign swim = current_data == 1'b1;
  reg current_data ;
  
  reg [6:0] cnt =0;
  
  wire clk_tick;
  wire in; 


  assign swim_en = cnt > 0 && current_data == 1'b0; 

  /* Generate clock ticks */
`ifdef SYNTHESIS  
  delay #(.CLK_COUNT(12000)) myclk (
    .clk(clk),
    .en(1'b1),
    .rst(rst),
    .rdy(clk_tick)
  );
`else
  delay #(.CLK_COUNT(12)) myclk (
    .clk(clk),
    .en(1'b1),
    .rst(rst),
    .rdy(clk_tick)
  );
`endif

  //reg [3:0] state;
  //parameter phase_0,;

  always @(posedge clk)
  begin
    rdy <= 1'b0;
    if (rst) begin
    	cnt <= 0;
      current_data <= 1'b0;
    end else begin
        if ( (en  ) && cnt == 0) begin
            cnt <=43;
            current_data <= data[44];
        end
        if (cnt == 0 && clk_tick) begin
           current_data <= 1'b0;
           rdy <= 1'b1;
        end
        if (cnt > 0 && clk_tick) begin
            cnt <= cnt -  1'b1;
            current_data <= data[cnt];
        end
    end
  end
endmodule

module swim_rst_wrap(
  input clk,
  input rst,
  input en,
  inout swim_1,
  inout swim_2,
  inout swim_3
);

  wire swim;
  wire swim_en;
  swim_rst swim_rst_i(
    .clk(clk),
    .rst(rst),
    .en(en),
    .swim(swim),
    .swim_en(swim_en)
  );
`ifdef SYNTHESIS

    SB_IO #(
        .PIN_TYPE(6'b 1010_01), // PIN_OUTPUT_TRISTATE - PIN_INPUT
        .PULLUP(1'b 0)
    ) iobuf_swim1 (
        .PACKAGE_PIN(swim_1),
        .OUTPUT_ENABLE(swim_en),
        .D_OUT_0(1'b0)
    );

    SB_IO #(
        .PIN_TYPE(6'b 1010_01), // PIN_OUTPUT_TRISTATE - PIN_INPUT
        .PULLUP(1'b 0)
    ) iobuf_swim2 (
        .PACKAGE_PIN(swim_2),
        .OUTPUT_ENABLE(swim_en),
        .D_OUT_0(1'b0)
    );

    SB_IO #(
        .PIN_TYPE(6'b 1010_01), // PIN_OUTPUT_TRISTATE - PIN_INPUT
        .PULLUP(1'b 0)
    ) iobuf_swim3 (
        .PACKAGE_PIN(swim_3),
        .OUTPUT_ENABLE(swim_en),
        .D_OUT_0(1'b0)
    );
`endif
endmodule




module top (
        input  pin_clk,

        inout  pin_usb_p,
        inout  pin_usb_n,
        output pin_pu,

        output pin_led,
        inout pin_1,
        inout pin_2,
        inout pin_3
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

  reg en =1'b0;

  swim_rst_wrap swim_rst_wrap_i(
        .clk(clk_48mhz),
        .rst(reset),
        .en(en),
        .swim_1(pin_1),
        .swim_2(pin_2),
        .swim_3(pin_3)
  );
  
  /* fifo to store X bytes, where X it a power of 2*/
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

    if (reset) begin
    end else begin
            //clk_out <= ~clk_out;
            en <= 1'b0;

            if (uart_out_valid && ~fifo_full)
              begin
                  // when data is available push it into the fifo
                  //fifo[fifo_end] = uart_out_data;
                  fifo[fifo_end] ="a";
                  fifo_end <= fifo_end +1;
                  en <= 1'b1; /* enable sending the reset signal */
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
  end
  // USB Host Detect Pull Up
  assign pin_pu = 1'b1;

endmodule
