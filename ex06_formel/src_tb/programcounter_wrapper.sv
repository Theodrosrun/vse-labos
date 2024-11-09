module programcounter_wrapper#(int N = 8)(
        input  logic        clk,
        input  logic        start,
        input  logic[N-1:0] addr,
        input  logic        JP,
        input  logic        JF,
        input  logic        Flag,
        output logic[N-1:0] PC
);

    // Instantiation of the DUV
    programcounter#(N) duv(.*);

    // Binding of the DUV and the assertions module
    bind duv programcounter_assertions#(N) binded(.*);

endmodule
