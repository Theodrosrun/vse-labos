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

    // ***********************************************
    // ****************** Methods ********************
    // ***********************************************

    task send_transaction(uart_transaction_type_t transaction_type, logic[DATASIZE-1:0] data = 20'h00000);
        automatic uart_transaction transaction = new;
        transaction.transaction_type = transaction_type;
        transaction.data = data;
        sequencer_to_driver_fifo.put(transaction);
    endtask

    // ***********************************************
    // ******************* Tests *********************
    // ***********************************************

    task test_read;
        send_transaction(RECEIVE, 20'h54321);
    endtask

    task test_rx_fifo_is_full;
        for (int i = 0; i < FIFOSIZE + 1; ++i) begin
            send_transaction(RECEIVE, i + FIFOSIZE);
        end
    endtask

    task test_read_boundaries;
        send_transaction(RECEIVE, 20'hFFFFF);
        send_transaction(RECEIVE, 20'h00000);
    endtask

    task test_rx_randomization;
        automatic uart_transaction coverage = new;
        automatic uart_transaction transaction = new;
        automatic int counter = 0;

        while ((coverage.cg.get_inst_coverage() < 100) && (counter < 10)) begin
            counter++;
            assert (coverage.randomize());
            coverage.cg.sample();            
            transaction.data = coverage.data;
            send_transaction(RECEIVE, transaction.data);
        end
    endtask

    task select_test(int TESTCASE);
        case (TESTCASE)
            1: test_read();
            2: ;
            3: ;
            4: ;
            5: test_rx_fifo_is_full();
            6: ;
            7: test_read_boundaries();
            8: ;
            9: test_rx_randomization();
            10:;
            default: begin
                $display("Unknown TESTCASE: %d", TESTCASE);
            end
        endcase
    endtask

    task run();
        $display("%t [UART Sequencer] Start", $time);

        if (testcase == 0) begin
            for (integer i = 1; i <= 8; i++) begin
                select_test(i);
            end
        end else begin
            select_test(testcase);
        end

        $display("%t [UART Sequencer] End", $time);
    endtask

endclass : uart_sequencer

`endif // UART_SEQUENCER_SV
