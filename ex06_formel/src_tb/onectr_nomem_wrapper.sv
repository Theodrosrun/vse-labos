module onectr_nomem_wrapper#(int INPUTSIZE = 64, int PCSIZE = 8)(
        input logic                            clk,
        input logic                            rst,
        input logic                            start_i,
        input logic[INPUTSIZE-1:0]             InPort,
        output logic[$clog2(INPUTSIZE+1)-1:0] OutPort,
        input logic[7:0]                       Ctrl,
        input logic[3:0]                       Sel,
        input logic                            Wen,
        input logic[3:0]                       WA,
        input logic[3:0]                       RAA,
        input logic[3:0]                       RAB,
        input logic[2:0]                       Op,
        input logic                            JP,
        input logic                            JF,
        input logic[PCSIZE-1:0]                JumpAddress,
        output logic[PCSIZE-1:0]               PCAddress
);

    // Instantiation of the DUV
    onectr_nomem#(INPUTSIZE,PCSIZE) duv(.*);

    // Binding of the DUV and the assertions module
    bind duv onectr_nomem_assertions#(INPUTSIZE,PCSIZE) binded(.*);

endmodule
