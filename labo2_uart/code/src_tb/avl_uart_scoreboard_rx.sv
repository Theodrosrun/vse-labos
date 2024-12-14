/*******************************************************************************  
HEIG-VD  
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud  
School of Business and Engineering in Canton de Vaud  
********************************************************************************  
REDS  
Institute Reconfigurable Embedded Digital Systems  
********************************************************************************  

File     : avl_uart_scoreboard_rx.sv  
Author   : Clément Dieperink  
Date     : 15.10.2024  

Context  : Lab for the verification of an UART  

********************************************************************************  
Description : This file contains the scoreboard responsible for comparing the  
              input/output transactions for RX  

********************************************************************************  
Dependencies : -  

********************************************************************************
Modifications :
Ver   Date        Person                           Comments
1.0   15.10.2024  CDK                              Initial version
1.1   14.12.2024  Theodros Mulugeta & Colin Jaques
*******************************************************************************/

`ifndef UART_TRANSCEIVER_SCOREBOARD_RX_SV  
`define UART_TRANSCEIVER_SCOREBOARD_RX_SV  

class avl_uart_scoreboard_rx#(int DATASIZE=20, int FIFOSIZE=10);  

    // Testcase identifier  
    int testcase;  

    // FIFOs for transactions from Avalon and UART  
    avalon_fifo_t avalon_to_scoreboard_rx_fifo;  
    uart_fifo_t uart_to_scoreboard_rx_fifo;  

    // Counts for verification  
    int total_checks;  
    int passed_checks;  
    int failed_checks;  

    // Allow to know if there is one Avalon transaction get from the FIFO
    // that has not yet a corresponding UART one at the end of simulation
    logic waiting_avalon_trans = 0;  

    // Constructor to initialize scoreboard  
    function new();  
        total_checks = 0;  
        passed_checks = 0;  
        failed_checks = 0;  
        waiting_avalon_trans = 0;  
    endfunction  

    // Main task to compare Avalon and UART transactions  
    task run;  
        automatic avalon_transaction avalon_transaction;  
        automatic uart_transaction uart_transaction;  

        $display("%t [Scoreboard RX] Start monitoring transactions", $time);  

        while (1) begin  
            uart_to_scoreboard_rx_fifo.get(uart_transaction);  
            waiting_avalon_trans = 1;
            avalon_to_scoreboard_rx_fifo.get(avalon_transaction);  
            objections_pkg::objection::get_inst().raise();
            waiting_avalon_trans = 0;

            $display("*****************************************************************");

            total_checks++;  
            compare_transactions(avalon_transaction.data, uart_transaction.data);
            objections_pkg::objection::get_inst().drop();    
        end  

        $display("%t [Scoreboard RX] Monitoring complete", $time);  
    endtask : run  

    function void compare_transactions(logic[19:0] data, logic[19:0] driver_data);
        if (data === driver_data) begin
            passed_checks++;
        end else begin
            failed_checks++;
            $error("%t [Scoreboard RX] Verification FAILED: data = 0x%h, driver_data = 0x%h", $time, data, driver_data);
        end
    endfunction : compare_transactions

    task end_display;  
        $display("*****************************************************************");  
        $display("RX Scoreboard: Total=%0d, Passed=%0d, Failed=%0d", total_checks, passed_checks, failed_checks);  
        $display("*****************************************************************\n");  
    endtask : end_display  

endclass : avl_uart_scoreboard_rx  

`endif // UART_TRANSCEIVER_SCOREBOARD_RX_SV  
