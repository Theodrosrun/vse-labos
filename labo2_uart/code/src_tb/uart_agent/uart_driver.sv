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
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

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
        automatic uart_transaction transaction;
        $display("%t [UART Driver] Start", $time);

        vif.rx_i = 1;

        // Allow setup of the DUV baudrate
        #1000;

        // Loop to process transactions
        while (1) begin
            // Get a transaction from the sequencer-to-driver FIFO
            objections_pkg::objection::get_inst().drop();
            sequencer_to_driver_fifo.get(transaction);
            objections_pkg::objection::get_inst().raise();

            $display("*****************************************************************");

            case (testcase)
                1: begin
                end

                2: begin
                    vif.rx_i = 0;
                    #200;

                    for (int i = 0; i < DATASIZE; i++) begin
                        vif.rx_i = transaction.data[i];
                        #200;
                    end

                    vif.rx_i = 1;
                    #200;

                    $display("[UART Driver] RECEIVE Completed");
                end

                3: begin

                end

                4: begin
                end

                5: begin
                end

                6: begin
                    vif.rx_i = 0;
                    #200;

                    for (int i = 0; i < DATASIZE; i++) begin
                        vif.rx_i = transaction.data[i];
                        #200;
                    end

                    vif.rx_i = 1;
                    #200;
                    $display("[UART Driver] RECEIVE Completed");
                end

                7: begin
                    for (int i = 0; i < FIFOSIZE + 1; i++) begin
                        vif.rx_i = 0;
                        #200;

                        for (int i = 0; i < DATASIZE; i++) begin
                            vif.rx_i = transaction.data[i];
                            #200;
                        end

                        vif.rx_i = 1;
                        #200;
                    end
                    $display("[UART Driver] RECEIVE Completed");
                end

                default: begin
                    $display("%t [UART Driver] Unknown test case:\n%d", $time, testcase);
                end
            endcase

            uart_to_scoreboard_rx_fifo.put(transaction);
        end

        $display("%t [UART Driver] End", $time);
    endtask : run

endclass : uart_driver

`endif // UART_DRIVER_SV
