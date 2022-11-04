`timescale 1ns / 1ps

module FIR(
    input clk,
    input reset,
    input enable_fir,
    input signed [15:0] fir_data_in,
    output reg signed [31:0] fir_data_out 
    );
    
    // 15-tap FIR 
    reg signed [15:0] buff0, buff1, buff2, buff3, buff4, buff5, buff6, buff7, buff8, buff9, buff10, buff11, buff12, buff13, buff14;
    wire signed [15:0] tap0, tap1, tap2, tap3, tap4, tap5, tap6, tap7, tap8, tap9, tap10, tap11, tap12, tap13, tap14; 
    reg signed [31:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10, acc11, acc12, acc13, acc14; 

    
    /* Taps for LPF running @ 100MSps with passband from 0 Hz - 10 MHz */
    assign tap0 = 16'hfe64;
    assign tap1 = 16'hfc8a; 
    assign tap2 = 16'hfc04; 
    assign tap3 = 16'hff93; 
    assign tap4 = 16'h0883; 
    assign tap5 = 16'h14ef; 
    assign tap6 = 16'h1ff7; 
    assign tap7 = 16'h2463; 
    assign tap8 = 16'h1ff7; 
    assign tap9 = 16'h14ef;
    assign tap10 = 16'h0883; 
    assign tap11 = 16'hff93; 
    assign tap12 = 16'hfc04; 
    assign tap13 = 16'hfc8a; 
    assign tap14 = 16'hfe64;

	/* Circular buffer w/ multiply stage of FIR */    
	always @ (posedge clk)
        begin
            if(enable_fir == 1'b1)
                begin
                    buff0 <= fir_data_in;
                    acc0 <= tap0 * buff0;
                    
                    buff1 <= buff0;  
                    acc1 <= tap1 * buff1;
                          
                    buff2 <= buff1; 
                    acc2 <= tap2 * buff2;
                            
                    buff3 <= buff2;     
                    acc3 <= tap3 * buff3;
                     
                    buff4 <= buff3;  
                    acc4 <= tap4 * buff4;
                        
                    buff5 <= buff4; 
                    acc5 <= tap5 * buff5;
                          
                    buff6 <= buff5;  
                    acc6 <= tap6 * buff6;
                      
                    buff7 <= buff6; 
                    acc7 <= tap7 * buff7;
                          
                    buff8 <= buff7;  
                    acc8 <= tap8 * buff8;
                         
                    buff9 <= buff8;     
                    acc9 <= tap9 * buff9;
                      
                    buff10 <= buff9;   
                    acc10 <= tap10 * buff10;
                         
                    buff11 <= buff10;    
                    acc11 <= tap11 * buff11;
                       
                    buff12 <= buff11;    
                    acc12 <= tap12 * buff12;
                       
                    buff13 <= buff12;  
                    acc13 <= tap13 * buff13;  
                       
                    buff14 <= buff13;  
                    acc14 <= tap14 * buff14;  
                end
        end   
        
    /* Accumulate stage of FIR */   
    always @ (posedge clk) 
        begin
            if (enable_fir == 1'b1)
                begin
                    fir_data_out <= acc0 + acc1 + acc2 + acc3 + acc4 + acc5 + acc6 + acc7 + acc8 + acc9 + acc10 + acc11 + acc12 + acc13 + acc14;
                end
        end 
    
endmodule
