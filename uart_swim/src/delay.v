module delay
  #(parameter CLK_COUNT=10)
  (input clk,
  input rst,
  input en,
  output reg rdy =1'b0,
  output busy);

  reg [31:0] counter =0;
  
  assign busy = counter > 0;
  
  always @(posedge clk) begin
    rdy <= 1'b0; // ready is only ever high for a single sample
    if(rst) begin
      counter <= 0;
    end else begin
      if (en && counter == 0) begin
        counter <= CLK_COUNT -1;
      end 
      if (counter > 0) begin
        counter <= counter -1;
        
        if (counter == 1) begin
          rdy <= 1'b1;
          if (en) begin
            counter <= CLK_COUNT;
          end
        end
      end
      
    end
  end

endmodule