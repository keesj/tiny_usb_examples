module fifo #
(
    parameter FIFO_WIDTH=8,
    parameter FIFO_DEPTH=4
)(
        input  clk,
        input  rst,
        input  [FIFO_WIDTH-1:0] data_in,
        input data_in_en,

        /* output side of things */
        output reg [FIFO_WIDTH-1:0] data_out,
        input data_out_en,

        /* signaling */
        output full,
        output empty
    );

    reg [FIFO_WIDTH-1:0] data [FIFO_DEPTH-1:0];
    reg [1:0] fifo_start = 2'b00;
    reg [1:0] fifo_end = 2'b00;
    assign full = (fifo_end + 1 == fifo_start);
    assign empty = (fifo_start  == fifo_end);

    always @(posedge clk)
    begin
        if (rst) begin
            fifo_start <= 2'b00;
            fifo_end <= 2'b00;
            data_out <= 8'b00000000;
        end else begin

          /* fifo read from portion */
          if(data_out_en && !empty) begin
              fifo_start <= fifo_start +1;
              data_out <= data[fifo_start +1];
          end

          /* fifo write into portion */
          if(data_in_en && !full) begin
              data[fifo_end] <= data_in;
              fifo_end <= fifo_end +1;
              if (empty) begin
                    data_out <= data_in;
              end 
          end
        end
    end
  
endmodule
