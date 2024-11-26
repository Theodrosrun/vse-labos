/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : avalon_sequencer.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the sequencer responsible for generating the
              data to test the UART on the Avalon side

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef AVALON_SEQUENCER_SV
`define AVALON_SEQUENCER_SV

class avalon_sequencer#(int DATASIZE=20, int FIFOSIZE=10);

    int testcase;

    avalon_fifo_t sequencer_to_driver_fifo;

    task test_clk_per_bit();
        automatic avalon_transaction transaction = new;
        transaction.transaction_type = CLK_PER_BIT;
        transaction.writedata_i = 10;
        $display("%t [AVL Sequencer] Generated Transaction:\n%s", $time, transaction.toString());
        sequencer_to_driver_fifo.put(transaction);
    endtask

    task test_write();
        automatic avalon_transaction transaction = new;
        transaction.transaction_type = WRITE;
        transaction.writedata_i = 32'h11111111;
        $display("%t [AVL Sequencer] Generated Transaction:\n%s", $time, transaction.toString());
        sequencer_to_driver_fifo.put(transaction);
    endtask


    task test_read;
        automatic avalon_transaction transaction = new;
        transaction.transaction_type = READ;
        $display("%t [AVL Sequencer] Generated Transaction:\n%s", $time, transaction.toString());
        sequencer_to_driver_fifo.put(transaction);
    endtask

    task test_all;
        test_clk_per_bit;
        test_write;
        test_read;
    endtask

    task run;
        $display("%t [AVL Sequencer] Start", $time);

        case (testcase)
            0: test_all;
            default: $display("Unkown test case %d", testcase);
        endcase

        $display("%t [AVL Sequencer] End", $time);
    endtask : run

endclass : avalon_sequencer

`endif // AVALON_SEQUENCER_SV
