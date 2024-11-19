/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : avalon_transaction.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the definition of the Avalon possible
              transaction

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef AVALON_TRANSACTION_SV
`define AVALON_TRANSACTION_SV

typedef enum {UART_SEND, UART_READ, WRITE_REGISTER} avalon_transaction_type_t;

class avalon_transaction#(int DATASIZE=20, int FIFOSIZE=10);

    // TODO : Populate this transaction

endclass : avalon_transaction


typedef mailbox #(avalon_transaction) avalon_fifo_t;

`endif // AVALON_TRANSACTION_SV
