/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingénierie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : uart_transaction.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the definition of the UART in terms of
              a transaction.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef UART_TRANSACTION_SV
`define UART_TRANSACTION_SV

// Enumeration for UART transaction types
typedef enum {
    SEND, 
    RECEIVE
    } uart_transaction_type_t;

class uart_transaction#(int DATASIZE=20, int FIFOSIZE=10);

    // Timestamp and transaction type
    time timestamp;
    uart_transaction_type_t transaction_type;

    // UART-specific data
    logic [DATASIZE-1:0] data;  // Data to be sent or received (configurable size)

    // Max
    int max = (2 ** DATASIZE) - 1;

    // Covergroup
    covergroup cg;
        option.get_inst_coverage = 1;

        coverpoint data[DATASIZE-1:0]{
            bins min    = {0};
            bins middle = {max/2};
            bins max    = {max};
            bins values[4] = {[0:max]};
        }
    endgroup

    // Constructor
    function new();
        this.timestamp        = $time;
        this.transaction_type = SEND;
        this.data             = '0;
        cg                    = new;
    endfunction

    // Function to get the transaction type as a string
    function string get_type_name();
        case (this.transaction_type)
            SEND:    return "SEND";
            RECEIVE: return "RECEIVE";
            default: return "UNKNOWN";
        endcase
    endfunction

    // Function to display transaction information (for debugging)
    function string toString();
        string s;
        $sformat(s,
            {"Timestamp   : %0t\n",
             "Type        : %s\n",
             "Data        : %h\n"},
             timestamp, get_type_name(), data);
        return s;
    endfunction

endclass : uart_transaction

// Typedef for mailbox used between components
typedef mailbox #(uart_transaction) uart_fifo_t;

`endif // UART_TRANSACTION_SV
