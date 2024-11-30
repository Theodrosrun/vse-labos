/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingénierie et de Gestion du Canton de Vaud
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

    // Generic task to generate transactions
    task generate_transaction(avalon_transaction_type_t transaction_type, logic[31:0] data = '0);
        automatic avalon_transaction transaction = new;
        $display("*****************************************************************");
        transaction.transaction_type = transaction_type;
        transaction.data = data;
        $display("%t [AVL Sequencer] Generated Transaction:\n%s", $time, transaction.toString());
        sequencer_to_driver_fifo.put(transaction);
    endtask

    // Specific test cases
    task test_all();
        generate_transaction(SET_CLK_PER_BIT, 32'h0000000A);
        generate_transaction(READ_CLK_PER_BIT);
        // generate_transaction(READ_RX);
        generate_transaction(WRITE_TX, 32'h000AAAAA);
        generate_transaction(SEND_FIFO_IS_EMPTY);
        generate_transaction(SEND_FIFO_IS_FULL);
        generate_transaction(RECEIVE_FIFO_IS_NOT_EMPTY);
        generate_transaction(RECEIVE_FIFO_IS_FULL);
    endtask

    task run;
        $display("%t [AVL Sequencer] Start", $time);

        case (testcase)
            0: test_all();
            1: generate_transaction(SET_CLK_PER_BIT, 32'h0000000A);
            2: generate_transaction(READ_CLK_PER_BIT);
            3: generate_transaction(READ_RX);
            4: generate_transaction(WRITE_TX, 32'h000AAAAA);
            5: generate_transaction(SEND_FIFO_IS_EMPTY);
            6: generate_transaction(SEND_FIFO_IS_FULL);
            7: generate_transaction(RECEIVE_FIFO_IS_NOT_EMPTY);
            8: generate_transaction(RECEIVE_FIFO_IS_FULL);
            default: $display("Unknown test case %d", testcase);
        endcase

        $display("%t [AVL Sequencer] End", $time);
    endtask : run

endclass : avalon_sequencer

`endif // AVALON_SEQUENCER_SV
