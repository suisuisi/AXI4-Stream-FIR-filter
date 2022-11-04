`timescale 1 ns / 1 ps

module AXIS_FIR_v1_0 # 
    (
        // Users to add parameters here
        
        // User parameters ends
        // Do not modify the parameters beyond this line
        
        
        // Parameters of Axi Slave Bus Interface S_AXIS
        parameter integer C_S_AXIS_TDATA_WIDTH	= 16,
        
        // Parameters of Axi Master Bus Interface M_AXIS
        parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
        parameter integer C_M_AXIS_START_COUNT	= 32
    )
    (
        // Users to add ports here
        
        input wire [3:0] s_axis_tkeep,
        output wire [3:0] m_axis_tkeep,
        
        // User ports ends
        // Do not modify the ports beyond this line
        
        
        // Ports of Axi Slave Bus Interface S_AXIS
        input wire  s_axis_aclk,
        input wire  s_axis_aresetn,
        output wire  s_axis_tready,
        input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
        input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] s_axis_tstrb,
        input wire  s_axis_tlast,
        input wire  s_axis_tvalid,
        
        // Ports of Axi Master Bus Interface M_AXIS
        input wire  m_axis_aclk,
        input wire  m_axis_aresetn,
        output wire  m_axis_tvalid,
        output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
        output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tstrb,
        output wire  m_axis_tlast,
        input wire  m_axis_tready
    );
    
    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] fir_data_in;
    wire [C_M_AXIS_TDATA_WIDTH-1 : 0] fir_data_out;

    // Instantiation of Axi Bus Interface S_AXIS
    AXIS_FIR_v1_0_S_AXIS # ( 
        .C_S_AXIS_TDATA_WIDTH(C_S_AXIS_TDATA_WIDTH)
    ) AXIS_FIR_v1_0_S_AXIS_inst (
        .s_axis_tkeep(s_axis_tkeep),
        .enable_fir(enable_fir),
        .fir_data_in(fir_data_in),
        .S_AXIS_ACLK(s_axis_aclk),
        .S_AXIS_ARESETN(s_axis_aresetn),
        .S_AXIS_TREADY(s_axis_tready),
        .S_AXIS_TDATA(s_axis_tdata),
        .S_AXIS_TSTRB(s_axis_tstrb),
        .S_AXIS_TLAST(s_axis_tlast),
        .S_AXIS_TVALID(s_axis_tvalid)
    );

    // Instantiation of Axi Bus Interface M_AXIS
    AXIS_FIR_v1_0_M_AXIS # ( 
        .C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH),
        .C_M_START_COUNT(C_M_AXIS_START_COUNT)
    ) AXIS_FIR_v1_0_M_AXIS_inst (
        .m_axis_tkeep(m_axis_tkeep),
        .enable_fir(enable_fir),
        .fir_data_out(fir_data_out),
        .M_AXIS_ACLK(s_axis_aclk),
        .M_AXIS_ARESETN(s_axis_aresetn),
        .M_AXIS_TVALID(m_axis_tvalid),
        .M_AXIS_TDATA(m_axis_tdata),
        .M_AXIS_TSTRB(m_axis_tstrb),
        .M_AXIS_TLAST(m_axis_tlast),
        .M_AXIS_TREADY(m_axis_tready)
    );

    // Add user logic here	
    FIR LPF_FIR_inst (
        .clk(s_axis_aclk),
        .reset(s_axis_aresetn),
        .enable_fir(enable_fir),
        .fir_data_in(fir_data_in), //16
        .fir_data_out(fir_data_out) //32 
    );
    
    // User logic ends

endmodule
