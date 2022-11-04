`timescale 1ns / 1ps

module phase_inc_sm(
    input clk,
    input reset,
    output reg m_axis_phase_tvalid,
    output reg m_axis_phase_tlast,
    input m_axis_phase_tready,
    output reg [31:0] m_axis_phase_tdata
    );

    wire [31:0] carrier_freq_100k;
    wire [31:0] carrier_period_100k;    
    wire [31:0] carrier_freq_200k;
    wire [31:0] carrier_period_200k;
    wire [31:0] carrier_freq_500k;
    wire [31:0] carrier_period_500k; 
    wire [31:0] carrier_freq_750k;
    wire [31:0] carrier_period_750k; 
    wire [31:0] carrier_freq_1m;
    wire [31:0] carrier_period_1m;    
    wire [31:0] carrier_freq_10m;
    wire [31:0] carrier_period_10m;
    wire [31:0] carrier_freq_20m;
    wire [31:0] carrier_period_20m; 
    wire [31:0] carrier_freq_45m;
    wire [31:0] carrier_period_45m;
    wire [31:0] carrier_freq_50m;
    wire [31:0] carrier_period_50m; 
    reg [31:0] carrier_freq;
    reg [31:0] carrier_period;           
    
    // 100 kHz
    assign carrier_freq_100k = 32'h83126;  //32'h418937;
    assign carrier_period_100k = 32'd1000;       
    
    // 200 kHz
    assign carrier_freq_200k = 32'h10624D; //32'h83126e;
    assign carrier_period_200k = 32'd500;
    
    // 500 kHz 
    assign carrier_freq_500k = 32'h28F5C2; //32'h147ae14;
    assign carrier_period_500k = 32'd200;
    
    // 750 kHz C0000000
    assign carrier_freq_750k = 32'h3D70A3; //32'h1eb851e;
    assign carrier_period_750k = 32'd133;
    
    // 1 MHz
    assign carrier_freq_1m = 32'h51EB85; //32'h28F5C28;
    assign carrier_period_1m = 32'd100; 
    
    // 10 MHz
    assign carrier_freq_10m = 32'h3333333; //32'h19999999;
    assign carrier_period_10m = 32'd10; 
    
    // 20 MHz
    assign carrier_freq_20m = 32'h6666666; //32'h33333333;
    assign carrier_period_20m = 32'd5;
    
    // 45 MHz
    assign carrier_freq_45m = 32'hE666666; //32'h73333333;
    assign carrier_period_45m = 32'd3;
    
    // 50 MHz
    assign carrier_freq_50m = 32'h10000000; //32'h80000000;
    assign carrier_period_50m = 32'd2;
    
    reg [2:0] state_reg;
    reg [31:0] period_wait_cnt;
    reg [3:0] cycle_cnt;
    
    parameter init               = 3'd0;
    parameter SetCarrierFreq     = 3'd1;
    parameter SetTvalidHigh      = 3'd2;
    parameter SetSlavePhaseValue = 3'd3;
    parameter CheckTready        = 3'd4;
    parameter WaitState          = 3'd5;   
    parameter SetTlastHigh       = 3'd6;
    parameter SetTlastLow        = 3'd7;
    
    initial 
        begin
            state_reg = 3'd0;
            m_axis_phase_tlast = 1'b0;
            m_axis_phase_tvalid = 1'b0;
            m_axis_phase_tdata = 32'd0;
        end
    
        
    
    always @ (posedge clk)
        begin                    
            // Default Outputs   
            
            if (reset == 1'b0)
                begin
                    m_axis_phase_tdata[31:0] <= 32'd0;
                    m_axis_phase_tlast <= 1'b0;
                    m_axis_phase_tvalid <= 1'b0;
                    cycle_cnt <= 4'd0;
                    state_reg <= init;
                end
            else
                begin
                    case(state_reg)
                        init : //0
                            begin
                                cycle_cnt <= 4'd0;
                                period_wait_cnt <= 32'd0;
                                m_axis_phase_tlast <= 1'b0;
                                m_axis_phase_tvalid <= 1'b0;
                                carrier_freq <= carrier_freq_1m;
                                state_reg <= SetCarrierFreq;// WaitForStart;
                            end
                            
                        SetCarrierFreq : //1
                            begin         
                                if (carrier_freq > carrier_freq_20m)
                                    begin
                                        carrier_freq <= carrier_freq_1m;
                                    end
                                else
                                    begin
                                        carrier_freq <= carrier_freq + carrier_freq_1m;
                                    end
                                
                                carrier_period <= carrier_period_1m;
                                state_reg <= SetTvalidHigh;
                            end
                            
                        SetTvalidHigh : //2
                            begin
                                m_axis_phase_tvalid <= 1'b1; //per PG141 - tvalid is set before tready goes high
                                state_reg <= SetSlavePhaseValue;
                            end
                            
                        SetSlavePhaseValue : //3
                            begin
                                m_axis_phase_tdata[31:0] <= carrier_freq;
                                state_reg <= CheckTready;
                            end
                            
                        CheckTready : //4
                            begin
                                if (m_axis_phase_tready == 1'b1)
                                    begin
                                        state_reg <= WaitState;
                                    end
                                else    
                                    begin
                                        state_reg <= CheckTready;
                                    end
                            end
                            
                        WaitState : //5
                            begin
                                if (period_wait_cnt >= carrier_period)
                                    begin
                                        period_wait_cnt <= 32'd0; 
                                        state_reg <= SetTlastHigh;
                                    end
                                else
                                    begin
                                        period_wait_cnt <= period_wait_cnt + 1;
                                        state_reg <= WaitState;
                                    end
                            end
                            
                        SetTlastHigh : //6
                            begin
                                m_axis_phase_tlast <= 1'b1;
                                state_reg <= SetTlastLow;
                            end
                            
                        SetTlastLow : //7
                            begin
                                m_axis_phase_tlast <= 1'b0;
                                state_reg <= SetCarrierFreq; 
                            end
                            
                    endcase 
                end
        end
        
endmodule
