module top_tb;

    reg clk = 1'b0;
    parameter PERIOD = 10;
    always #5 clk=~clk;

    reg rst =1'b0;
    reg en = 1'b0;

    wire swim;
    wire swim_en;
    wire swimg_rst;
    wire rdy;
    
    swim_rst swim_rst_i(
        .clk(clk),
        .rst(rst),
        .en(en),
        .swim(swim),
        .swim_en(swim_en),
        .swim_rst(swim_rst),
        .rdy(rdy)
    );

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars(0,top_tb);
    end

    always @(posedge clk) begin
        $display("Format");
        rst = 1'b1;
        #PERIOD;
        rst = 1'b0;
        en = 1'b1;
        #20;
        en = 1'b0;

        wait(rdy);
        wait(rdy==0);
        #2000;
        en = 1'b1;
        #20;
        en = 1'b0;
        wait(rdy);
        //wait(busy==0);

        $finish;
    end
endmodule
