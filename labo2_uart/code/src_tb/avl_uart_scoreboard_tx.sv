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
            avalon_to_scoreboard_tx_fifo.get(avalon_transaction);
            uart_to_scoreboard_tx_fifo.get(uart_transaction);

            // Increment total checks
            total_checks++;

            // Compare Avalon and UART transactions
            if (compare_transactions(avalon_transaction, uart_transaction)) begin
                passed_checks++;
                $display("%t [Scoreboard TX] Transaction check PASSED", $time);
            end else begin
                failed_checks++;
                $error("%t [Scoreboard TX] Transaction check FAILED", $time);
                $display("Avalon Transaction: %s", avalon_transaction.toString());
                $display("UART Transaction  : %s", uart_transaction.toString());
            end
        end

        $display("%t [Scoreboard TX] Monitoring complete", $time);
    endtask : run

    // Function to compare Avalon and UART transactions
    function bit compare_transactions(
        avalon_transaction avalon_transaction,
        uart_transaction uart_transaction
    );
        // Check if data matches
        if (avalon_transaction.writedata_i !== uart_transaction.data) begin
            return 0; // Mismatch in data
        end

        // Check if parity matches
        if (avalon_transaction.transaction_type == UART_SEND &&
            avalon_transaction.writedata_i[0] !== uart_transaction.parity) begin
            return 0; // Mismatch in parity
        end

        // Additional checks can be added here
        return 1; // Transactions match
    endfunction : compare_transactions

        // Task for final checks and display results
    task end_display;
        $display("\n==========================================");
        $display("%t [Scoreboard TX] Final Results", $time);
        $display("Total checks  : %0d", total_checks);
        $display("Passed checks : %0d", passed_checks);
        $display("Failed checks : %0d", failed_checks);

        if (failed_checks > 0) begin
            $error("[Scoreboard TX] There are %0d failed checks!", failed_checks);
        end else begin
            $display("[Scoreboard TX] All checks passed successfully!");
        end
        $display("==========================================\n");
    endtask : end_display

endclass : avl_uart_scoreboard_tx

`endif // UART_TRANSCEIVER_SCOREBOARD_TX_SV
