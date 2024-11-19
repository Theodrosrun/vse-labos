/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : uart_sequencer.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the sequencer responsible for generating the
              data test on RX

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef UART_SEQUENCER_SV
`define UART_SEQUENCER_SV

class uart_sequencer#(int DATASIZE=20, int FIFOSIZE=10);

    int testcase;

    uart_fifo_t sequencer_to_driver_fifo;

    task run;
        automatic uart_transaction transaction;
        $display("%t [UART Sequencer] Start", $time);

        begin
            // TODO : Generate something meaningfull
            transaction = new;
            void'(transaction.randomize());

            sequencer_to_driver_fifo.put(transaction);
            $display("%t [UART Sequencer] New transaction sent", $time);
        end

        $display("%t [UART Sequencer] End", $time);
    endtask : run

endclass : uart_sequencer

`endif // UART_SEQUENCER_SV
