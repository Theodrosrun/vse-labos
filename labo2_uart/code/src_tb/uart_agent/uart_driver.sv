/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
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
Description : This file contains the driver representing the UART remote host

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person                           Comments
1.0   15.10.2024  CDK                              Initial version
1.1   14.12.2024  Theodros Mulugeta & Colin Jaques
*******************************************************************************/


`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV

import objections_pkg::*;

class uart_driver#(int DATASIZE=20, int FIFOSIZE=10);

    int testcase;

    int ns_per_bit;

    uart_fifo_t sequencer_to_driver_fifo;
    uart_fifo_t uart_to_scoreboard_rx_fifo;

    virtual uart_itf vif;

    task run;
        $display("%t [UART Driver] Start", $time);

        vif.rx_i = 1;

        // Allow setup of the DUV baudrate
        #1000;

        // Loop to process transactions
        while (1) begin
            automatic uart_transaction transaction;
            sequencer_to_driver_fifo.get(transaction);
            objections_pkg::objection::get_inst().raise();

            vif.rx_i = 0;
            #ns_per_bit;

            for (int i = 0; i < DATASIZE; i++) begin
                vif.rx_i = transaction.data[DATASIZE - 1 - i];
                #ns_per_bit;
            end

            vif.rx_i = 1;
            #ns_per_bit;

            $display("[UART Driver] RECEIVE Completed");
            
            uart_to_scoreboard_rx_fifo.put(transaction);
            objections_pkg::objection::get_inst().drop();
        end

        $display("%t [UART Driver] End", $time);
    endtask : run

endclass : uart_driver

`endif // UART_DRIVER_SV
