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

typedef enum logic [31:0] {
    TX_FIFO_FULL      = 32'h00000001,
    RX_FIFO_FULL      = 32'h00000002,
    RX_FIFO_NOT_EMPTY = 32'h00000004,
    TX_FIFO_EMPTY     = 32'h00000008
    } status_flag_t;

    // ***********************************************
    // ******************* Params ********************
    // ***********************************************

    int CLOCK_PER_BIT = 10;

    // ***********************************************
    // **************** Base methods *****************
    // ***********************************************
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

    // ***********************************************
    // *************** Helper methods ****************
    // ***********************************************

    task set_clock_per_bit(logic [31:0] data);
         write(CLOCK_PER_CYCLE_ADDR, data);
    endtask

    task read_status_flag(logic [31:0] flag);     
        while ((vif.readdata_o & flag) == 0) begin
            @(posedge vif.clk_i);
            read(STATUS_REGISTER_ADDR);
        end
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

            case (testcase)
                1: begin
                    $display("%t [AVL Driver] Handling SET_READ_CLK_PER_BIT Transaction:\n%s", $time, transaction.toString());
                    set_clock_per_bit(CLOCK_PER_BIT);
                    read(CLOCK_PER_CYCLE_ADDR);
                    $display("[AVL Driver] SET_READ_CLK_PER_BIT Completed: %d", vif.readdata_o);
                end

                2: begin
                    $display("%t [AVL Driver] Handling READ_RX Transaction:\n%s", $time, transaction.toString());
                    set_clock_per_bit(CLOCK_PER_BIT);
                    read_status_flag(RX_FIFO_IS_NOT_EMPTY);
                    transaction.data = vif.readdata_o;
                    avalon_to_scoreboard_rx_fifo.put(transaction);
                    $display("[AVL Driver] READ_RX Completed");
                end

                3: begin
                    $display("%t [AVL Driver] Handling WRITE_TX Transaction:\n%s", $time, transaction.toString());
                    set_clock_per_bit(CLOCK_PER_BIT);
                    write(WRITE_ADDR, transaction.data);
                    avalon_to_scoreboard_tx_fifo.put(transaction);
                    $display("[AVL Driver] WRITE_TX Completed");
                end

                4: begin
                    $display("%t [AVL Driver] Handling TX_FIFO_IS_EMPTY Transaction:\n%s", $time, transaction.toString());
                    set_clock_per_bit(CLOCK_PER_BIT);
                    read_status_flag(TX_FIFO_EMPTY);
                    transaction.data = vif.readdata_o;
                    avalon_to_scoreboard_tx_fifo.put(transaction);
                    $display("[AVL Driver] TX_FIFO_IS_EMPTY Completed");
                end
                
                5: begin
                    $display("%t [AVL Driver] Handling TX_FIFO_FULL Transaction:\n%s", $time, transaction.toString());
                    set_clock_per_bit(CLOCK_PER_BIT);
                    for (int i = 0; i < FIFOSIZE + 1; i++) begin
                        write(WRITE_ADDR, transaction.data);
                    end
                    read_status_flag(TX_FIFO_FULL);
                    transaction.data = vif.readdata_o;
                    avalon_to_scoreboard_tx_fifo.put(transaction);
                    $display("[AVL Driver] TX_FIFO_IS_FULL Completed");
                end
                
                6: begin
                    $display("%t [AVL Driver] Handling RX_FIFO_IS_NOT_EMPTY Transaction:\n%s", $time, transaction.toString());
                    set_clock_per_bit(CLOCK_PER_BIT);
                    read_status_flag(RX_FIFO_NOT_EMPTY);
                    transaction.data = vif.readdata_o;
                    avalon_to_scoreboard_rx_fifo.put(transaction);
                    $display("[AVL Driver] RX_FIFO_IS_NOT_EMPTY Completed");
                end

                7: begin
                    $display("%t [AVL Driver] Handling RX_FIFO_IS_FULL Transaction:\n%s", $time, transaction.toString());
                    set_clock_per_bit(CLOCK_PER_BIT);
                    read_status_flag(RX_FIFO_FULL);
                    transaction.data = vif.readdata_o;
                    avalon_to_scoreboard_rx_fifo.put(transaction);
                    $display("[AVL Driver] RX_FIFO_IS_FULL Completed");
                end
                default: begin
                    $display("%t [AVL Driver] Unknown Transaction Type:\n%s", $time, transaction.toString());
                end
            endcase
        end

    endtask : run

endclass : avalon_driver

`endif // AVALON_DRIVER_SV
