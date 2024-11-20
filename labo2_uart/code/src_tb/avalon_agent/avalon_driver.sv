/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : avalon_driver.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the driver representing the avalon access
              behavior

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/


`ifndef AVALON_DRIVER_SV
`define AVALON_DRIVER_SV

import objections_pkg::*;

class avalon_driver#(int DATASIZE=20, int FIFOSIZE=10);

    int testcase;

    avalon_fifo_t sequencer_to_driver_fifo;
    avalon_fifo_t avalon_to_scoreboard_rx_fifo;
    avalon_fifo_t avalon_to_scoreboard_tx_fifo;

    virtual avalon_itf vif;

    task run;
        automatic avalon_transaction transaction;
        $display("%t [AVL Driver] Start", $time);

        vif.rst_i = 1;
        vif.address_i = 0;
        vif.byteenable_i = 'hf;
        vif.write_i = 0;
        vif.writedata_i = 0;
        vif.read_i = 0;

        @(posedge vif.clk_i);
        vif.rst_i <= 0;
        @(posedge vif.clk_i);
        @(posedge vif.clk_i);

        // Loop to process transactions
        while (1) begin
            // Get a transaction from the sequencer-to-driver FIFO
            sequencer_to_driver_fifo.get(transaction);

            // Handle transactions based on their type
            case (transaction.transaction_type)
                UART_SEND: begin
                    $display("%t [AVL Driver] Handling UART_SEND Transaction: %s", $time, transaction.toString());

                    // Write transaction on the Avalon bus
                    vif.address_i = transaction.address;
                    vif.write_i = 1;
                    vif.writedata_i = transaction.writedata_i;
                    @(posedge vif.clk_i);
                    vif.write_i = 0;

                    $display("%t [AVL Driver] Write Completed: Address=%0d, Data=%0d", 
                        $time, transaction.address, transaction.writedata_i);

                    // Optionally send the transaction to the TX scoreboard
                    avalon_to_scoreboard_tx_fifo.put(transaction);
                end

                UART_READ: begin
                    $display("%t [AVL Driver] Handling UART_READ Transaction: %s", $time, transaction.toString());

                    // Read transaction on the Avalon bus
                    vif.address_i = transaction.address;
                    vif.read_i = 1;
                    @(posedge vif.clk_i);
                    vif.read_i = 0;

                    // Capture the read data
                    transaction.readdata_o = vif.readdata_o;

                    $display("%t [AVL Driver] Read Completed: Address=%0d, Data=%0d", 
                        $time, transaction.address, transaction.readdata_o);

                    // Send the transaction to the RX scoreboard
                    avalon_to_scoreboard_rx_fifo.put(transaction);
                end

                // TODO - Add WRITE_REGISTER
                
                default: begin
                    $display("%t [AVL Driver] Unknown Transaction Type: %s", $time, transaction.toString());
                end
            endcase

            @(posedge vif.clk_i); // Wait for the next clock cycle
        end

    endtask : run

endclass : avalon_driver

`endif // AVALON_DRIVER_SV
