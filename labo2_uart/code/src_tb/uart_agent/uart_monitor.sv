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
            uart_transaction#(DATASIZE, FIFOSIZE) transaction = new;

            // Wait for the start bit (falling edge of tx_o)
            @(negedge vif.tx_o);

            $display("%t [UART Monitor] Start bit detected", $time);

            // Decode the UART frame
           // repeat (ns_per_bit) @(vif.clk); // Wait for the middle of the start bit

            // Capture data bits
            for (int i = 0; i < DATASIZE; i++) begin
               //  @(posedge vif.clk);
                transaction.data[i] = vif.tx_o;
                // repeat (ns_per_bit - 1) @(vif.clk); // Wait for next bit's timing
            end

            // Capture the parity bit
            //@(posedge vif.clk);
            transaction.parity = vif.tx_o;
            // repeat (ns_per_bit - 1) @(vif.clk);

            // Capture the stop bit
            //@(posedge vif.clk);
            transaction.stop = vif.tx_o;

            // Check stop bit validity
            if (transaction.stop !== 1'b1) begin
                $error("%t [UART Monitor] Invalid stop bit detected", $time);
            end

            // Send transaction to the scoreboard
            uart_to_scoreboard_tx_fifo.put(transaction);

            $display("%t [UART Monitor] Transaction captured and sent to scoreboard: %s", $time, transaction.toString());
        end
    endtask

endclass : uart_monitor

`endif // UART_MONITOR_SV
