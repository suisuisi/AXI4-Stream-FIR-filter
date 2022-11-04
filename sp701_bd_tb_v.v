`timescale 1ns / 1ps

module sp701_bd_tb;

    reg clk_p, clk_n, reset;
    
    always begin
        clk_p = 1; clk_n = 0; #5;
        clk_p = 0; clk_n = 1; #5;
    end
    
    always begin
        reset = 1; #40;
        reset = 0; #1000000000;
    end
       
    sp701_bd sp701_bd_i (
        .reset(reset),
        .sys_diff_clock_clk_n(clk_p),
        .sys_diff_clock_clk_p(clk_n)
    );

endmodule