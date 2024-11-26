/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
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

    task run;
        automatic avalon_transaction transaction;
        $display("%t [AVL Sequencer] Start", $time);

        for (int i = 0; i < 2; i++) begin
            $display("*****************************************************************");

            transaction = new();
            transaction.timestamp = $time;
            transaction.transaction_type = WRITE;
            transaction.address          = transaction.transaction_type;

            case (transaction.transaction_type)
                REGISTER: begin
                end

                WRITE: begin
                    transaction.writedata_i = 20'h11111111;
                end

                READ: begin
                end

                CYCLE: begin
                    // transaction.writedata_i = 32'h001000;
                end
                
                default: begin
                    $display("%t [AVL Sequencer] Unknown Transaction Type:\n%s", $time, transaction.toString());
                end
            endcase


            $display("%t [AVL Sequencer] Generated Transaction:\n%s", $time, transaction.toString());

            sequencer_to_driver_fifo.put(transaction);
        end
        
        $display("%t [AVL Sequencer] End", $time);
    endtask : run

endclass : avalon_sequencer

`endif // AVALON_SEQUENCER_SV
