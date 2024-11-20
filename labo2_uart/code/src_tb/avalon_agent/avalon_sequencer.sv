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

        for (int i = 0; i < 4; i++) begin
            $display("*****************************************************************");

            transaction = new();
            transaction.timestamp = $time;
            transaction.transaction_type = (i % 2 == 0) ? UART_SEND : UART_READ;
            transaction.address = 16'h0 + (i * 4);

            if (transaction.transaction_type == UART_SEND) begin
                transaction.write_i = 1;
                transaction.writedata_i = i * 8;
                transaction.read_i =  ~transaction.write_i;
            end else begin
                transaction.read_i = 1;
                transaction.write_i = ~transaction.read_i;
            end

            $display("%t [AVL Sequencer] Generated Transaction:\n%s", $time, transaction.toString());

            sequencer_to_driver_fifo.put(transaction);
        end
        
        $display("%t [AVL Sequencer] End", $time);
    endtask : run

endclass : avalon_sequencer

`endif // AVALON_SEQUENCER_SV
