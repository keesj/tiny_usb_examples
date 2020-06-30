/*
 * Global reset signal 
 */
module global_reset(
    input clk,
    input rst_in,
    output rst);

    // Generate reset signal
    reg [5:0] reset_cnt = 0;
    assign rst = ~reset_cnt[5];
    always @(posedge clk)
        if ( rst_in )
            reset_cnt <= reset_cnt + rst;
endmodule
