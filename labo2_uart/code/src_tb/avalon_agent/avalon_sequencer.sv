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

    // Clock per bit
    int NS_PER_BIT    = 1_000_000_000 / 9600;      // 104167 ns
    int CLOCK_PERIOD  = 20;                        // 20 ns
    int CLOCK_PER_BIT = NS_PER_BIT / CLOCK_PERIOD; // 104167 / 20 = 5208 clock cycles per bit

    // Number of clock cycle to wait before read
    // Add margin for ensuring that RX is ready
    int NB_CLK_CYCLE_BEFORE_READ = CLOCK_PER_BIT * 20 * 2;

    // ***********************************************
    // ****************** Methods ********************
    // ***********************************************

    task send_transaction(avalon_transaction_type_t transaction_type, logic[31:0] data = 32'h00000000);
        automatic avalon_transaction transaction = new;
        transaction.transaction_type = transaction_type;
        transaction.data = data;
        sequencer_to_driver_fifo.put(transaction);
    endtask

    task set_clk_per_bit();
        send_transaction(SET_CLK_PER_BIT, CLOCK_PER_BIT);
    endtask

    // ***********************************************
    // ******************* Tests *********************
    // ***********************************************

    task test_write();
        set_clk_per_bit();
        send_transaction(TX_FIFO_IS_EMPTY);
        send_transaction(WRITE_TX, 20'h11111);
        send_transaction(TX_FIFO_IS_NOT_EMPTY);
    endtask

    task test_read;
        set_clk_per_bit();
        send_transaction(WAIT_CLK_CYCLE, NB_CLK_CYCLE_BEFORE_READ);
        send_transaction(RX_FIFO_IS_EMPTY);
        send_transaction(READ_RX);
        send_transaction(RX_FIFO_IS_EMPTY);
    endtask

    task test_tx_fifo_is_full;
        set_clk_per_bit();
        send_transaction(TX_FIFO_IS_EMPTY);

        for (int i = 0; i < FIFOSIZE + 1; ++i) begin
            send_transaction(WRITE_TX, i + FIFOSIZE);
        end

        send_transaction(TX_FIFO_IS_FULL);
    endtask

   task test_rx_fifo_is_full;
        set_clk_per_bit();
        for (int i = 0; i < FIFOSIZE + 1; ++i) begin
            send_transaction(WAIT_CLK_CYCLE, NB_CLK_CYCLE_BEFORE_READ);
            send_transaction(READ_RX);
        end
        send_transaction(RX_FIFO_IS_FULL);
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
