module regfile_wrapper(
        input  logic      clk,
        input  logic[7:0] W,
        output logic[7:0] A,
        output logic[7:0] B,
        input  logic      Wen,
        input  logic[3:0] WA,
        input  logic[3:0] RAA,
        input  logic[3:0] RAB
);

    // Instantiation of the DUV
    regfile duv(.*);

    // Binding of the DUV and the assertions module
    bind duv regfile_assertions binded(.*);

endmodule
