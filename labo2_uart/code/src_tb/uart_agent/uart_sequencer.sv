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

    task test_all;
        test_set_clk_per_bit;
        test_read_clk_per_bit;
        test_read_rx;
        test_write_tx;
    endtask

    task test_set_clk_per_bit();
    endtask

    task test_read_clk_per_bit();
    endtask

    task test_read_rx();
        automatic uart_transaction transaction = new;
        $display("*****************************************************************");
        transaction.transaction_type = SEND;
        transaction.data = 20'h11111;
        $display("%t [UART Sequencer] Generated Transaction:\n%s", $time, transaction.toString());
        sequencer_to_driver_fifo.put(transaction);
    endtask

    task test_write_tx();
    endtask

    task run;
        $display("%t [UART Sequencer] Start", $time);

        case (testcase)
            0: test_all;
            1: test_set_clk_per_bit;
            2: test_read_clk_per_bit;
            3: test_read_rx;
            4: test_write_tx;
            default: $display("Unkown test case %d", testcase);
        endcase

        $display("%t [UART Sequencer] End", $time);
    endtask : run

endclass : uart_sequencer

`endif // UART_SEQUENCER_SV
