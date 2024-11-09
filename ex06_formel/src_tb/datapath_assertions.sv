module datapath_assertions(
        input  logic       clk,
        input  logic[63:0] InPort,
        input  logic[6:0]  OutPort,
        input  logic[7:0]  Ctrl,
        input  logic[3:0]  Sel,
        input  logic       Wen,
        input  logic[3:0]  WA,
        input  logic[3:0]  RAA,
        input  logic[3:0]  RAB,
        input  logic[2:0]  Op,
        input  logic       Flag
);
endmodule
