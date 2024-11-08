module datapath_wrapper(
        input  logic       clk,
        input  logic[63:0] InPort,
        output logic[6:0]  OutPort,
        input  logic[7:0]  Ctrl,
        input  logic[3:0]  Sel,
        input  logic       Wen,
        input  logic[3:0]  WA,
        input  logic[3:0]  RAA,
        input  logic[3:0]  RAB,
        input  logic[2:0]  Op,
        output logic       Flag
);

    // Instantiation of the DUV
    datapath duv(.*);

    // Binding of the DUV and the assertions module
    bind duv datapath_assertions binded(.*);
endmodule
