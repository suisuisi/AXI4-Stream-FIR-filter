`timescale 1ns / 1ps

module mem_dump_sm(
    input clk,
    input reset,
    input signed [31:0] s_axis_mem_tdata,
    input [3:0] s_axis_mem_tkeep,
    input s_axis_mem_tlast,
    input s_axis_mem_tvalid,
    output s_axis_mem_tready
    );
    
    assign s_axis_mem_tready = 1'b1;
    
    reg signed [31:0] mem_location;
    
    always @ (posedge clk)
        begin
            if (s_axis_mem_tkeep == 4'hf && s_axis_mem_tvalid == 1'b1)
                begin
                    mem_location <= s_axis_mem_tdata;
                end
            else
                begin
                    mem_location <= mem_location;
                end
        end
endmodule
