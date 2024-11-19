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

        while (1) begin
            sequencer_to_driver_fifo.get(transaction);

            // TODO : Do something

        end

    endtask : run

endclass : avalon_driver

`endif // AVALON_DRIVER_SV
