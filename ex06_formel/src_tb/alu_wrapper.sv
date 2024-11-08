module alu_wrapper(
    input  logic[2:0] Op,
    input  logic[7:0] A,
    input  logic[7:0] B,
    output logic[7:0] Y,
    output logic      F
);

    // Instantiation of the DUV
    alu duv(.*);

    // Binding of the DUV and the assertions module
    bind duv alu_assertions binded(.*);

endmodule
