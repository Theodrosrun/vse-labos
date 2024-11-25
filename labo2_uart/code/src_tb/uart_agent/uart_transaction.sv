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

// Enum for UART transaction type
typedef enum {SEND, RECEIVE, CONFIGURE} uart_transaction_type_t;

class uart_transaction#(int DATASIZE=20, int FIFOSIZE=10);

    // Timestamp and transaction type
    time timestamp;
    uart_transaction_type_t transaction_type;

    // UART-specific data
    logic [DATASIZE-1:0] data;  // Data to be sent or received
    logic parity;               // Parity bit
    logic stop;                 // Stop bit
    logic [31:0] clk_per_bit;   // Number of clock cycles per bit (timing)

    // Status bits
    logic [3:0] status_bits;    // Status of FIFOs (full, empty, etc.)

    // FIFO interface
    logic fifo_full;            // Indicates if the FIFO is full
    logic fifo_empty;           // Indicates if the FIFO is empty
    logic fifo_data_available;  // Indicates if data is available in the FIFO

    // Constructor
    function new();
        this.timestamp         = $time;
        this.transaction_type  = SEND;
        this.data              = '0;
        this.parity            = 0;
        this.stop              = 0;
        this.clk_per_bit       = 8;
        this.status_bits       = 4'b0000;
        this.fifo_full         = 0;
        this.fifo_empty        = 1;
        this.fifo_data_available = 0;
    endfunction

    // Get the name of the transaction type
    function string get_type_name();
        case (this.transaction_type)
            SEND:       return "SEND";
            RECEIVE:    return "RECEIVE";
            CONFIGURE:  return "CONFIGURE";
            default:    return "UNKNOWN";
        endcase
    endfunction

    // Return a string representation for debugging
    function string toString();
        string s;
        $sformat(s,
            {"Timestamp   : %0t\n",
             "Type        : %s\n",
             "Data        : %h\n",
             "Parity      : %b\n",
             "Stop        : %b\n",
             "ClkPerBit   : %d\n",
             "StatusBits  : %b\n",
             "FIFO Full   : %b\n",
             "FIFO Empty  : %b\n",
             "Data Avail. : %b"},
             timestamp, get_type_name(), data, parity, stop, clk_per_bit,
             status_bits, fifo_full, fifo_empty, fifo_data_available);
        return s;
    endfunction

endclass : uart_transaction

// Typedef for mailbox used between components
typedef mailbox #(uart_transaction) uart_fifo_t;

`endif // UART_TRANSACTION_SV
