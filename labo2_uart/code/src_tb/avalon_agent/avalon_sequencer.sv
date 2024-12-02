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

    // ***********************************************
    // ******************* Params ********************
    // ***********************************************

    int CLOCK_PER_BIT = (1_000_000_000 / 9600) / 20;

    // ***********************************************
    // ****************** Methods ********************
    // ***********************************************

    task set_clk_per_bit();
        automatic avalon_transaction transaction = new;

        transaction.transaction_type = SET_CLK_PER_BIT;
        transaction.data = CLOCK_PER_BIT;
        sequencer_to_driver_fifo.put(transaction);
    endtask

    task test_write();
        automatic avalon_transaction transaction;

        set_clk_per_bit();

        transaction = new;
        transaction.transaction_type = TX_FIFO_IS_EMPTY;
        sequencer_to_driver_fifo.put(transaction);

        transaction = new;
        transaction.transaction_type = WRITE_TX;
        transaction.data = 32'hAAAAA;
        sequencer_to_driver_fifo.put(transaction);

        transaction = new;
        transaction.transaction_type = TX_FIFO_IS_NOT_EMPTY;
        sequencer_to_driver_fifo.put(transaction);
    endtask

    task test_read;
        automatic avalon_transaction transaction;

        set_clk_per_bit();

        transaction = new;
        transaction.transaction_type = WAIT_BEFORE_READ;
        sequencer_to_driver_fifo.put(transaction);

        transaction = new;
        transaction.transaction_type = RX_FIFO_IS_EMPTY;
        sequencer_to_driver_fifo.put(transaction);

        transaction = new;
        transaction.transaction_type = READ_RX;
        sequencer_to_driver_fifo.put(transaction);

        transaction = new;
        transaction.transaction_type = RX_FIFO_IS_EMPTY;
        sequencer_to_driver_fifo.put(transaction);
    endtask

    task test_tx_fifo_is_full;
        automatic avalon_transaction transaction;

        set_clk_per_bit();

        transaction = new;
        transaction.transaction_type = TX_FIFO_IS_EMPTY;
        sequencer_to_driver_fifo.put(transaction);

        for (int i = 0; i < FIFOSIZE + 1; ++i) begin
            transaction = new;
            transaction.transaction_type = WRITE_TX;
            transaction.data = i + FIFOSIZE;
            sequencer_to_driver_fifo.put(transaction);
        end

        transaction = new;
        transaction.transaction_type = TX_FIFO_IS_FULL;
        sequencer_to_driver_fifo.put(transaction);
    endtask

   task test_rx_fifo_is_full;
        automatic avalon_transaction transaction;

        set_clk_per_bit();

        transaction = new;
        transaction.transaction_type = WAIT_BEFORE_READ;
        sequencer_to_driver_fifo.put(transaction);

        transaction = new;
        transaction.transaction_type = RX_FIFO_IS_FULL;
        sequencer_to_driver_fifo.put(transaction);
    endtask
    
    task select_test(int TESTCASE);
        case (TESTCASE)
            1: test_write();
            2: test_read();
            3: test_tx_fifo_is_full();
            4: test_rx_fifo_is_full();
            default: begin
                $display("Unknown TESTCASE: %d", TESTCASE);
            end
        endcase
    endtask

    // Execute single or all tests based on TESTCASE parameter
    task run();
        $display("%t [AVL Sequencer] Start", $time);

        if (testcase == 0) begin
            for (integer i = 1; i <= 7; i++) begin
                select_test(i);
            end
        end else begin
            select_test(testcase);
        end

        $display("%t [AVL Sequencer] End", $time);
    endtask

endclass : avalon_sequencer

`endif // AVALON_SEQUENCER_SV
