/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingénierie et de Gestion du Canton de Vaud
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

    // Testcase identifier
    int testcase;

    // FIFOs for transactions from Avalon and UART
    avalon_fifo_t avalon_to_scoreboard_tx_fifo;
    uart_fifo_t uart_to_scoreboard_tx_fifo;

    // Counts for verification
    int total_checks;
    int passed_checks;
    int failed_checks;

    // Constructor to initialize scoreboard
    function new();
        total_checks = 0;
        passed_checks = 0;
        failed_checks = 0;
    endfunction

    // Main task to compare Avalon and UART transactions
    task run;
        automatic avalon_transaction avalon_transaction;
        automatic uart_transaction uart_transaction;

        $display("%t [Scoreboard TX] Start monitoring transactions", $time);

        while (1) begin
            // Get transactions from FIFOs
            objections_pkg::objection::get_inst().drop();
            avalon_to_scoreboard_tx_fifo.get(avalon_transaction);
            uart_to_scoreboard_tx_fifo.get(uart_transaction);
            objections_pkg::objection::get_inst().raise();

            $display("*****************************************************************");

            // Increment total checks
            total_checks++;

            if (compare_transactions(avalon_transaction, uart_transaction)) begin
                passed_checks++;
                $display("%t [Scoreboard TX] Verification PASSED", $time);
            end else begin
                failed_checks++;
                $display("%t [Scoreboard TX] Verification FAILED", $time);
            end
        end

        $display("%t [Scoreboard TX] Monitoring complete", $time);
    endtask : run

    // Function to compare Avalon and UART transactions
    function bit compare_transactions(avalon_transaction avalon_transaction, uart_transaction uart_transaction);
        return (avalon_transaction.data === uart_transaction.data);
    endfunction : compare_transactions

    // Task for final checks and display results
    task end_display;
        $display("*****************************************************************");
        $display("Results: Total=%0d, Passed=%0d, Failed=%0d", total_checks, passed_checks, failed_checks);
        $display("*****************************************************************");
    endtask : end_display

endclass : avl_uart_scoreboard_tx

`endif // UART_TRANSCEIVER_SCOREBOARD_TX_SV
