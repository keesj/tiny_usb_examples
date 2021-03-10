module top_tb;

    reg clk = 1'b0;
    parameter PERIOD = 10;
    always #PERIOD clk=~clk;

    reg rst =1'b0;
    wire rdy;

    delay   #(.CLK_COUNT(10)) div(
        .clk(clk),
        .en(1'b1),
        .rst(rst),
        .rdy(rdy)
    );

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars(0,top_tb);
    end

    always begin
        $display("Format");
        rst = 1'b1;
        #1;
        rst = 1'b0;
        #200;
        wait(rdy);
        wait(rdy==0);
        wait(rdy);
        wait(rdy==0);
        
        $finish;
    end
endmodule
