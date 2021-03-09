module top_tb;
    reg clk;

    parameter PERIOD = 10;
    always #PERIOD clk=~clk;

    always begin
        #1000;
        $finish;
    end
endmodule