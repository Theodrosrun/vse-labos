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

    // Timestamp and Transaction type
    time timestamp;
    avalon_transaction_type_t type;

    // Address
    logic[13:0] address;

    // Write interface
    logic write_i;
    logic[31:0] writedata_i;

    // Read interface
    logic read_i;
    logic readdatavalid_o;
    logic[7:0] readdata_o;
    logic waitrequest_o;

    // Constructor
    function new();
        this.type = UART_SEND;
        this.timestamp = $time;
        this.address = '0;
        this.write_i = 0;
        this.writedata_i = '0;
        this.read_i = 0;
        this.readdatavalid_o = 0;
        this.readdata_o = '0;
        this.waitrequest_o = 0;
    endfunction

    function string toString();
        string s;
        $sformat(s,
                 "Transaction:\n"
                 "  Timestamp: %t\n"
                 "  Type: %s\n"
                 "  Address: %h\n"
                 "  Write: %b, Writedata: %h\n"
                 "  Read: %b, ReadValid: %b, ReadData: %h\n"
                 "  WaitRequest: %b\n",
                 timestamp, type.name(), address, 
                 write_i, writedata_i, read_i, readdatavalid_o, 
                 readdata_o,waitrequest_o);
        return s;
    endfunction

endclass : avalon_transaction

typedef mailbox #(avalon_transaction) avalon_fifo_t;

`endif // AVALON_TRANSACTION_SV
