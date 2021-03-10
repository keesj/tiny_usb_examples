module top_tb;

    reg clk = 1'b0;
    parameter PERIOD = 10;
    always #PERIOD clk=~clk;

    reg rst =1'b0;
    wire rdy;

    clk_div   #(.DIVIDER(3)) div(
        .clk(clk),
        .reset(rst),
        .clk_tick(rdy)
    );

    initial
    begin
        $dumpfile("test.vcd");
        $dumpvars(0,top_tb);
//#        # 17 rst = 1;
//#        # 11 rst = 0;
//        # 513 $finish;
    end

    always begin
        $display("Format");
        rst = 1'b1;
        #2;
        rst = 1'b0;
        # 200
        wait(rdy);

        rst = 1'b1;
        #2;
        rst = 1'b0;
        #2;

        wait(rdy);
        
        $finish;
    end
endmodule
