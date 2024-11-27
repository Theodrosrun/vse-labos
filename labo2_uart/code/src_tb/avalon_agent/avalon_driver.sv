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

    task wait_slave_ready();
        while (vif.waitrequest_o) begin
        @(posedge vif.clk_i);
        end
    endtask

    task run;
        automatic avalon_transaction transaction;
        $display("%t [AVL Driver] Start", $time);

        vif.rst_i        = 1;
        vif.address_i    = 0;
        vif.byteenable_i = 'hf;
        vif.write_i      = 0;
        vif.writedata_i  = 0;
        vif.read_i       = 0;

        @(posedge vif.clk_i);
        vif.rst_i <= 0;
        @(posedge vif.clk_i);
        @(posedge vif.clk_i);

        // Loop to process transactions
        while (1) begin
            // Get a transaction from the sequencer-to-driver FIFO
            objections_pkg::objection::get_inst().drop();
            sequencer_to_driver_fifo.get(transaction);
            objections_pkg::objection::get_inst().raise();

            $display("*****************************************************************");

            // Handle transactions based on their type
            case (transaction.transaction_type)
                SET_CLK_PER_BIT: begin
                    $display("%t [AVL Driver] Handling SET_CLK_PER_BIT Transaction:\n%s", $time, transaction.toString());
                    wait_slave_ready();
                    vif.address_i   = 3;
                    vif.write_i     = 1;
                    vif.writedata_i = transaction.data;
                    vif.read_i      = 0;
                    @(posedge vif.clk_i);
                    $display("[AVL Driver] SET_CLK_PER_BIT Completed");
                end

                READ_CLK_PER_BIT: begin
                    automatic logic [31:0] clk_per_bit;
                    $display("%t [AVL Driver] Handling READ_CLK_PER_BIT Transaction:\n%s", $time, transaction.toString());
                    wait_slave_ready();
                    vif.address_i   = 3;
                    vif.write_i     = 0;
                    vif.read_i      = 1;
                    while (!vif.readdatavalid_o) begin
                        @(posedge vif.clk_i);
                    end
                    clk_per_bit = vif.readdata_o;
                    $display("[AVL Driver] READ_CLK_PER_BIT Completed: clk_per_bit = %0d", clk_per_bit);
                end

                READ_RX: begin
                    $display("%t [AVL Driver] Handling READ_RX Transaction:\n%s", $time, transaction.toString());
                    wait_slave_ready();
                    vif.address_i   = 1;
                    vif.write_i     = 0;
                    vif.read_i      = 1;
                    avalon_to_scoreboard_tx_fifo.put(transaction);
                    @(posedge vif.clk_i);
                    $display("[AVL Driver] READ_RX Completed");
                end

                WRITE_TX: begin
                    $display("%t [AVL Driver] Handling WRITE_TX Transaction:\n%s", $time, transaction.toString());
                    wait_slave_ready();
                    vif.address_i   = 1;
                    vif.write_i     = 1;
                    vif.writedata_i = transaction.data;
                    vif.read_i      = 0;
                    avalon_to_scoreboard_tx_fifo.put(transaction);
                    @(posedge vif.clk_i);
                    $display("[AVL Driver] WRITE_TX Completed");
                end

                default: begin
                    $display("%t [AVL Driver] Unknown Transaction Type:\n%s", $time, transaction.toString());
                end
            endcase
        end

    endtask : run

endclass : avalon_driver

`endif // AVALON_DRIVER_SV
