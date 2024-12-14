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
Ver   Date        Person                           Comments
1.0   15.10.2024  CDK                              Initial version
1.1   14.12.2024  Theodros Mulugeta & Colin Jaques
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

    // Number of clock cycle to wait before write
    // Add margin for ensuring that TX is ready
    int NB_CLK_CYCLE_BEFORE_WRITE = CLOCK_PER_BIT * 20 * 2;

    int MAX_ITERATION = 50;

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

    task wait_before_read();
        send_transaction(WAIT_CLK_CYCLE, NB_CLK_CYCLE_BEFORE_READ);
    endtask

    task wait_before_write();
        send_transaction(WAIT_CLK_CYCLE, NB_CLK_CYCLE_BEFORE_WRITE);
    endtask

    // ***********************************************
    // ******************* Tests *********************
    // ***********************************************

    task test_read;
        set_clk_per_bit();
        wait_before_read();
        send_transaction(RX_FIFO_IS_EMPTY);
        send_transaction(READ_RX);
        send_transaction(RX_FIFO_IS_EMPTY);
    endtask

    task test_write();
        set_clk_per_bit();
        send_transaction(TX_FIFO_IS_EMPTY);
        send_transaction(WRITE_TX, 20'h11111);
        send_transaction(TX_FIFO_IS_NOT_EMPTY);
    endtask

    task test_rx_fifo_is_empty;
        set_clk_per_bit();
        send_transaction(RX_FIFO_IS_EMPTY);
    endtask

    task test_tx_fifo_is_empty;
        set_clk_per_bit();
        send_transaction(TX_FIFO_IS_EMPTY);
    endtask

    task test_rx_fifo_is_full;
        set_clk_per_bit();
        send_transaction(RX_FIFO_IS_EMPTY);

        for (int i = 0; i < FIFOSIZE; ++i) begin
            wait_before_read();
            send_transaction(RX_FIFO_IS_NOT_EMPTY);
        end

        send_transaction(RX_FIFO_IS_FULL);
    endtask

    task test_tx_fifo_is_full;
        set_clk_per_bit();
        send_transaction(TX_FIFO_IS_EMPTY);

        for (int i = 0; i < FIFOSIZE + 1; ++i) begin
            send_transaction(WRITE_TX, i + FIFOSIZE);
            send_transaction(TX_FIFO_IS_NOT_EMPTY);
        end

        send_transaction(TX_FIFO_IS_FULL);
    endtask
    
    task test_read_boundaries;
        set_clk_per_bit();
        wait_before_read();
        send_transaction(READ_RX);
        wait_before_read();
        send_transaction(READ_RX);
        send_transaction(RX_FIFO_IS_EMPTY);
    endtask

    task test_write_boundaries;
        set_clk_per_bit();
        send_transaction(WRITE_TX, 20'hFFFFF);
        send_transaction(TX_FIFO_IS_NOT_EMPTY);
        wait_before_write();
        send_transaction(WRITE_TX, 20'h00000);
        send_transaction(TX_FIFO_IS_NOT_EMPTY);
    endtask

    task test_rx_randomization;
        automatic int counter = 0;

        set_clk_per_bit();

        while (counter < MAX_ITERATION) begin
            counter++;
            wait_before_read();
            send_transaction(READ_RX);
        end
    endtask

    task test_tx_randomization;
        automatic avalon_transaction coverage = new;
        automatic avalon_transaction transaction = new;
        automatic int counter = 0;

        set_clk_per_bit();
        while ((coverage.cg.get_coverage() < 100) && (counter < MAX_ITERATION)) begin
            counter++;
            assert (coverage.randomize());
            coverage.cg.sample();            
            transaction.data = coverage.data;
            wait_before_write();
            send_transaction(WRITE_TX, transaction.data);
        end
    endtask

    task select_test(int TESTCASE);
        case (TESTCASE)
            1:  test_read();
            2:  test_write();
            3:  test_rx_fifo_is_empty();
            4:  test_tx_fifo_is_empty();
            5:  test_rx_fifo_is_full();
            6:  test_tx_fifo_is_full();
            7:  test_read_boundaries();
            8:  test_write_boundaries();
            9:  test_rx_randomization();
            10: test_tx_randomization();
            default: begin
                $display("Unknown TESTCASE: %d", TESTCASE);
            end
        endcase
    endtask

    // Execute single or all tests based on TESTCASE parameter
    task run();
        $display("%t [AVL Sequencer] Start", $time);

        if (testcase == 0) begin
            for (integer i = 1; i <= 10; i++) begin
                select_test(i);
            end
        end else begin
            select_test(testcase);
        end

        $display("%t [AVL Sequencer] End", $time);
    endtask

endclass : avalon_sequencer

`endif // AVALON_SEQUENCER_SV
