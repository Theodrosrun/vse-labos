/*******************************************************************************
 HEIG-VD
 Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 School of Business and Engineering in Canton de Vaud
 ********************************************************************************
 REDS Institute
 Reconfigurable Embedded Digital Systems
 ********************************************************************************

 File     : avalon_wait_request_wrapper.sv
 Author   : Yann Thoma
 Date     : 18.11.2024

 Context  : Formal verification of an UART on Avalon bus

 ********************************************************************************
 Description : This module is a wrapper that binds the DUV with the
 module containing the assertions

 ********************************************************************************
 Dependencies : -

 ********************************************************************************
 Modifications :
 Ver   Date        Person     Comments
 1.0   18.11.2024  YTA        Initial version

 *******************************************************************************/

module avl_uart_interface_wrapper #(
                           int DATASIZE = 20,
                           int FIFOSIZE = 10,
                           int ERRNO = 0)
   (
    input logic         avl_clk_i,
    input logic         avl_reset_i,

    input logic [13:0]  avl_address_i,
    input logic [3:0]   avl_byteenable_i,
    output logic [31:0] avl_readdata_o,
    input logic [31:0]  avl_writedata_i,
    input logic         avl_write_i,
    input logic         avl_read_i,
    output logic        avl_waitrequest_o,
    output logic        avl_readdatavalid_o,
    input logic         rx_i,
    output logic        tx_o
    )
   ;

   // Instantiation of the DUV
   avl_uart_interface #(DATASIZE, FIFOSIZE, ERRNO) duv(.*);

   // Binding of the DUV and the assertions module
   bind duv avl_uart_interface_assertions #(DATASIZE, FIFOSIZE) binded(.*);

endmodule
