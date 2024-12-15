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
Ver   Date        Person                           Comments
1.0   15.10.2024  CDK                              Initial version
1.1   14.12.2024  Theodros Mulugeta & Colin Jaques
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

            @(negedge vif.tx_o);
            objections_pkg::objection::get_inst().raise();

            $display("%t [UART Monitor] Detected start bit on tx_o", $time);

            // Add offset to ensure bit is stable
            #(ns_per_bit + (ns_per_bit / 2));
            for (int i = DATASIZE; i > 0; i--) begin
                transaction.data[i-1] = vif.tx_o;
                #ns_per_bit;
            end

            transaction.timestamp = $time;
            transaction.transaction_type = SEND;
            uart_to_scoreboard_tx_fifo.put(transaction);
            $display("%t [UART Monitor] Transaction captured and sent to scoreboard: %s", $time, transaction.toString());

            objections_pkg::objection::get_inst().drop();
        end
    endtask

endclass : uart_monitor

`endif // UART_MONITOR_SV
