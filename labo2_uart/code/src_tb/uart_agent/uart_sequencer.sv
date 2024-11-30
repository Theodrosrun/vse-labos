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

    task generate_transaction(uart_transaction_type_t transaction_type, logic[DATASIZE-1:0] data = '0);
        automatic uart_transaction transaction = new;
        $display("*****************************************************************");
        transaction.transaction_type = transaction_type;
        transaction.data = data;
        $display("%t [UART Sequencer] Generated Transaction:\n%s", $time, transaction.toString());
        sequencer_to_driver_fifo.put(transaction);
    endtask

    // Tâche pour sélectionner et exécuter une transaction spécifique
    task select_transaction(int TESTCASE);
        case (TESTCASE)
            1: generate_transaction(NONE);
            2: generate_transaction(RECEIVE, 20'hAAAAA);
            3: generate_transaction(NONE);
            4: generate_transaction(NONE);
            5: generate_transaction(NONE);
            6: generate_transaction(NONE);
            7: generate_transaction(NONE);
            default: begin
                $display("Unknown TESTCASE: %d", TESTCASE);
            end
        endcase
    endtask

    // Exécute un ou tous les tests en fonction du paramètre TESTCASE
    task run();
        $display("%t [UART Sequencer] Start", $time);

        if (testcase == 0) begin
            for (integer i = 1; i <= 7; i++) begin
                select_transaction(i);
            end
        end else begin
            select_transaction(testcase);
        end

        $display("%t [UART Sequencer] End", $time);
    endtask

endclass : uart_sequencer

`endif // UART_SEQUENCER_SV
