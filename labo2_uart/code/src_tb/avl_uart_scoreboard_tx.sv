/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : avl_uart_scoreboard_tx.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the scoreboard responsible for comparing the
              input/output transactions for TX

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef UART_TRANSCEIVER_SCOREBOARD_TX_SV
`define UART_TRANSCEIVER_SCOREBOARD_TX_SV

class avl_uart_scoreboard_tx#(int DATASIZE=20, int FIFOSIZE=10);

    int testcase;

    avalon_fifo_t avalon_to_scoreboard_tx_fifo;
    uart_fifo_t uart_to_scoreboard_tx_fifo;

    task end_display;
        // TODO : Maybe some last checks and display
    endtask : end_display

    task run;
        automatic avalon_transaction avalon_trans;
        automatic uart_transaction uart_trans;

        $display("%t [Scoreboard TX] Start", $time);

        while (1) begin
            avalon_to_scoreboard_tx_fifo.get(avalon_trans);
            uart_to_scoreboard_tx_fifo.get(uart_trans);

            // TODO : Something

        end

        $display("%t [Scoreboard TX] End", $time);
    endtask : run

endclass : avl_uart_scoreboard_tx

`endif // UART_TRANSCEIVER_SCOREBOARD_TX_SV
