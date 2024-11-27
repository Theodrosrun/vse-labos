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

typedef enum int {SET_CLK_PER_BIT, READ_CLK_PER_BIT, READ_RX, WRITE_TX} avalon_transaction_type_t;

class avalon_transaction#(int DATASIZE=20, int FIFOSIZE=10);

    // Timestamp and
    time timestamp;

    // Transaction type
    avalon_transaction_type_t transaction_type;

    // Data
    logic[31:0] data;

    // Constructor
    function new();
        this.timestamp        = $time;
        this.transaction_type = SET_CLK_PER_BIT;
        this.data      = '0;
    endfunction

    // Get the name of the transaction type
    function string get_type_name();
        case (this.transaction_type)
            SET_CLK_PER_BIT:  return "SET_CLK_PER_BIT";
            READ_CLK_PER_BIT: return "READ_CLK_PER_BIT";
            READ_RX:          return "READ_RX";
            WRITE_TX:         return "WRITE_TX";
            default:          return "UNKNOWN";
        endcase
    endfunction

    // Return string
    function string toString();
        string s;
        $sformat(s,
            {"Timestamp  : %0t\n",
             "Type       : %s\n",
             "Data       : %h"},
             timestamp, get_type_name(), data);
        return s;
    endfunction

endclass : avalon_transaction

typedef mailbox #(avalon_transaction) avalon_fifo_t;

`endif // AVALON_TRANSACTION_SV
