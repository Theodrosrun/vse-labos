/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingénierie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : uart_driver.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the monitor observing the UART interface

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef UART_MONITOR_SV
`define UART_MONITOR_SV

import objections_pkg::*;

// Monitor class for the UART interface
class uart_monitor#(int DATASIZE=20, int FIFOSIZE=10);

    // Testcase ID for reference
    int testcase;

    // Timing information for bits
    int ns_per_bit;

    // FIFO for transmitting observed transactions to the scoreboard
    uart_fifo_t uart_to_scoreboard_tx_fifo;

    // Virtual interface for observing UART signals
    virtual uart_itf vif;

    // Run task to monitor and decode UART transactions
    task run;
        $display("%t [UART Monitor] Start monitoring UART interface", $time);

        #20; // Delay for stabilization if needed

        while (1) begin
            automatic uart_transaction#(DATASIZE, FIFOSIZE) transaction = new;
            automatic int i;
            automatic logic [DATASIZE-1:0] reconstructed_data;
            automatic logic parity_bit;
            automatic logic stop_bit;

            @(negedge vif.tx_o);
            $display("%t [UART Monitor] Detected start bit on tx_o", $time);

            for (i = 0; i < DATASIZE; i++) begin
                reconstructed_data[i] = vif.tx_o; // Sample the current data bit
                $display("%t [UART Monitor] Captured bit %0d: %b", $time, i, vif.tx_o); // Print each captured bit
                #8;                            // Wait for the next bit period
            end

            // Create a new transaction and populate its fields
            transaction = new();
            transaction.timestamp = $time;            // Record the timestamp
            transaction.transaction_type = SEND;      // Specify the transaction type
            transaction.data = reconstructed_data;    // Store the reconstructed data
            transaction.parity = parity_bit;          // Store the parity bit
            transaction.stop = stop_bit;              // Store the stop bit

            // Send transaction to the scoreboard
            uart_to_scoreboard_tx_fifo.put(transaction);

            $display("%t [UART Monitor] Transaction captured and sent to scoreboard: %s", $time, transaction.toString());
        end
    endtask

endclass : uart_monitor

`endif // UART_MONITOR_SV
