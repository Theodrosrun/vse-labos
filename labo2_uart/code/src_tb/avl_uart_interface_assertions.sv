module avl_uart_interface_assertions #(
                           int DATASIZE = 20,
                           int FIFOSIZE = 10)
   (
    input logic        avl_clk_i,
    input logic        avl_reset_i,

    input logic [13:0] avl_address_i,
    input logic [3:0]  avl_byteenable_i,
    input logic [31:0] avl_readdata_o,
    input logic [31:0] avl_writedata_i,
    input logic        avl_write_i,
    input logic        avl_read_i,
    input logic        avl_waitrequest_o,
    input logic        avl_readdatavalid_o,
    input logic        rx_i,
    input logic        tx_o
    );

    // clocking block
    default clocking cb @(posedge avl_clk_i);
    endclocking

    // read and write shall never be active at the same time
    assume_readwrite:
    assume property (!(avl_write_i & avl_read_i));

    // An example of assume that would trigger an error
    // assume_nowrite:
    // assume property (!(avl_write_i));

endmodule
