module avalon_assertions #(
                           int AVALONMODE = 0,
                           int TESTCASE = 0,
                           int NBDATABYTES = 2,
                           int NBADDRBITS = 8,
                           int WRITEDELAY = 2,  // Delay for fixed delay write operation
                           int READDELAY = 1,   // Delay for fixed delay read operation
                           int FIXEDDELAY = 2)  // Delay for pipeline operation
   (
    input logic                     clk,
    input logic                     rst,

    input logic [NBADDRBITS-1:0]    address,
    input logic [NBDATABYTES:0]     byteenable,
    input logic [2^NBDATABYTES-1:0] readdata,
    input logic [2^NBDATABYTES-1:0] writedata,
    input logic                     read,
    input logic                     write,
    input logic                     waitrequest,
    input logic                     readdatavalid,
    input logic [7:0]               burstcount,
    input logic                     beginbursttransfer
    );


    // clocking block
    default clocking cb @(posedge clk);
    endclocking

    // read et write ne doivent jamais être actifs en même temps
    assert_waitreq1:
    assert property (!(read & write));

endmodule
