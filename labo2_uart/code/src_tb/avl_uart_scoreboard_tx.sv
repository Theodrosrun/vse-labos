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
            if(avalon_transaction.transaction_type != TX_FIFO_IS_EMPTY) begin
                uart_to_scoreboard_tx_fifo.get(uart_transaction);
            end
            objections_pkg::objection::get_inst().raise();

            $display("*****************************************************************");

            total_checks++;

            case (avalon_transaction.transaction_type)
                SET_CLK_PER_BIT: begin
                end

                READ_CLK_PER_BIT: begin
                end

                WRITE_TX: begin
                    compare_transactions(avalon_transaction.data, uart_transaction.data);
                end

                TX_FIFO_IS_EMPTY: begin
                    compare_transactions(avalon_transaction.data, 32'h00000008);
                end
                
                TX_FIFO_IS_FULL: begin
                    compare_transactions(avalon_transaction.data, 32'h00000001);
                end

                default: begin
                    $display("%t [AVL Driver] Unknown Transaction Type:\n%s", $time, avalon_transaction.toString());
                end
            endcase
        end

        $display("%t [Scoreboard TX] Monitoring complete", $time);
    endtask : run

    function void compare_transactions(logic[31:0] data, logic[31:0] expected_data);
        if (data === expected_data) begin
            passed_checks++;
            $display("%t [Scoreboard TX] Verification PASSED: data = 0x%h, expected_data = 0x%h", $time, data, expected_data);
        end else begin
            failed_checks++;
            $display("%t [Scoreboard TX] Verification FAILED: data = 0x%h, expected_data = 0x%h", $time, data, expected_data);
        end
    endfunction : compare_transactions

    task end_display;
        $display("*****************************************************************");
        $display("TX Scoreboard: Total=%0d, Passed=%0d, Failed=%0d", total_checks, passed_checks, failed_checks);
        $display("*****************************************************************\n");
    endtask : end_display

endclass : avl_uart_scoreboard_tx

`endif // UART_TRANSCEIVER_SCOREBOARD_TX_SV
