module alu_assertions(
    input  logic[2:0] Op,
    input  logic[7:0] A,
    input  logic[7:0] B,
    input  logic[7:0] Y,
    input  logic      F
);


    bit clk = 0;
    
    always #10 clk = ~clk;

    // clocking block
    default clocking cb @(posedge clk);
    endclocking

endmodule
