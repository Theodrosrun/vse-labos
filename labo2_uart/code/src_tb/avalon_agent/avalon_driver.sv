/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : avalon_driver.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the driver representing the avalon access
              behavior

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/


`ifndef AVALON_DRIVER_SV
`define AVALON_DRIVER_SV

import objections_pkg::*;

class avalon_driver#(int DATASIZE=20, int FIFOSIZE=10);

    int testcase;

    avalon_fifo_t sequencer_to_driver_fifo;
    avalon_fifo_t avalon_to_scoreboard_rx_fifo;
    avalon_fifo_t avalon_to_scoreboard_tx_fifo;

    virtual avalon_itf vif;

    typedef enum int {
        STATUS_REGISTER_ADDR, 
        WRITE_ADDR, 
        READ_ADDR, 
        CLOCK_PER_CYCLE_ADDR
    } address_t;

    typedef enum logic [3:0] {
        TX_FIFO_IS_FULL      = 4'b0001,
        RX_FIFO_IS_FULL      = 4'b0010,
        RX_FIFO_IS_NOT_EMPTY = 4'b0100,
        TX_FIFO_IS_EMPTY     = 4'b1000
    } status_flag_t;

    // **********************************
    // ********** Base methods **********
    // **********************************
    task reset_signals();
        vif.address_i    = 0;
        vif.write_i      = 0;
        vif.writedata_i  = 0;
        vif.read_i       = 0;
    endtask

    task wait_slave_ready();
        while (vif.waitrequest_o) begin
            @(posedge vif.clk_i);
        end
    endtask

    task write(logic [13:0] address, logic [31:0] data);
        wait_slave_ready();
        vif.address_i   = address;
        vif.write_i     = 1;
        vif.writedata_i = data;
        @(posedge vif.clk_i);
        vif.write_i = 0;
    endtask

    task read(logic [13:0] address);
        vif.address_i = address;
        vif.read_i    = 1;
        while (!vif.readdatavalid_o) begin
            @(posedge vif.clk_i);
            vif.read_i = 0;
        end
    endtask

    // **********************************
    // ********* Helper methods *********
    // **********************************

    task set_clock_per_bit(logic [31:0] data);
         write(CLOCK_PER_CYCLE_ADDR, data);
    endtask

    task read_status_flag(logic [31:0] flag);
        vif.address_i = STATUS_REGISTER_ADDR;
        vif.read_i    = 1;
        while (!vif.readdatavalid_o || ((vif.readdata_o & flag) == 0)) begin
            @(posedge vif.clk_i);
            vif.read_i = 0;
            @(posedge vif.clk_i);
            vif.read_i = 1;
        end
        @(posedge vif.clk_i);
        vif.read_i = 0;
    endtask

    // **********************************
    // ************** Run ***************
    // **********************************
    task run;
        automatic avalon_transaction transaction;
        $display("%t [AVL Driver] Start", $time);

        vif.rst_i        = 1;
        vif.address_i    = 0;
        vif.byteenable_i = 'hf;
        vif.write_i      = 0;
        vif.writedata_i  = 0;
        vif.read_i       = 0;

        @(posedge vif.clk_i);
        vif.rst_i <= 0;
        @(posedge vif.clk_i);
        @(posedge vif.clk_i);

        // Loop to process transactions
        while (1) begin
            reset_signals();
                    
            // Get a transaction from the sequencer-to-driver FIFO
            objections_pkg::objection::get_inst().drop();
            sequencer_to_driver_fifo.get(transaction);
            objections_pkg::objection::get_inst().raise();

            $display("*****************************************************************");

            // Handle transactions based on their type
            case (transaction.transaction_type)
                SET_CLK_PER_BIT: begin
                    $display("%t [AVL Driver] Handling SET_CLK_PER_BIT Transaction:\n%s", $time, transaction.toString());
                    write(CLOCK_PER_CYCLE_ADDR, transaction.data);
                    $display("[AVL Driver] SET_CLK_PER_BIT Completed");
                end

                READ_CLK_PER_BIT: begin
                    $display("%t [AVL Driver] Handling READ_CLK_PER_BIT Transaction:\n%s", $time, transaction.toString());
                    read(CLOCK_PER_CYCLE_ADDR);
                    $display("[AVL Driver] READ_CLK_PER_BIT Completed: clk_per_bit = %0h", vif.readdata_o);
                end

                READ_RX: begin
                    $display("%t [AVL Driver] Handling READ_RX Transaction:\n%s", $time, transaction.toString());
                    set_clock_per_bit(1);
                    #500
                    read_status_flag(RX_FIFO_IS_NOT_EMPTY);
                    transaction.data = vif.readdata_o;
                    avalon_to_scoreboard_rx_fifo.put(transaction);
                    $display("[AVL Driver] READ_RX Completed");
                end

                WRITE_TX: begin
                    $display("%t [AVL Driver] Handling WRITE_TX Transaction:\n%s", $time, transaction.toString());
                    write(WRITE_ADDR, transaction.data);
                    avalon_to_scoreboard_tx_fifo.put(transaction);
                    $display("[AVL Driver] WRITE_TX Completed");
                end

                default: begin
                    $display("%t [AVL Driver] Unknown Transaction Type:\n%s", $time, transaction.toString());
                end
            endcase
        end

    endtask : run

endclass : avalon_driver

`endif // AVALON_DRIVER_SV
