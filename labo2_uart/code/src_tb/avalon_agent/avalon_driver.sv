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
    // **************** Base methods *****************
    // ***********************************************

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
        vif.read_i      = 0;
        @(posedge vif.clk_i);
        wait_slave_ready();
        vif.write_i = 0;
    endtask

    task read(logic [13:0] address);
        vif.address_i = address;
        vif.write_i   = 0;
        vif.read_i    = 1;
        while (!vif.readdatavalid_o) begin
            @(posedge vif.clk_i);
            vif.read_i = 0;
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
           @(posedge vif.clk_i);
                        
            // Get a transaction from the sequencer-to-driver FIFO
            sequencer_to_driver_fifo.get(transaction);

            objections_pkg::objection::get_inst().raise();

            $display("*****************************************************************");

            case (transaction.transaction_type)
                SET_CLK_PER_BIT: begin
                    $display("%t [AVL Driver] Handling SET_CLK_PER_BIT Transaction:\n%s", $time, transaction.toString());
                    write(CLOCK_PER_CYCLE_ADDR, transaction.data);
                    $display("[AVL Driver] SET_CLK_PER_BIT Completed");
                end

                WRITE_TX: begin
                    $display("%t [AVL Driver] Handling WRITE_TX Transaction:\n%s", $time, transaction.toString());
                    write(WRITE_ADDR, transaction.data);
                    avalon_to_scoreboard_tx_fifo.put(transaction);
                    $display("[AVL Driver] WRITE_TX Completed");
                end

                READ_RX: begin
                    automatic int i;
                    $display("%t [AVL Driver] Handling READ_RX Transaction:\n%s", $time, transaction.toString());
                    
                    for (i = 0; i < nb_clks; ++i) begin
                        @(posedge vif.clk_i);
                    end

                    read(READ_ADDR);
                    transaction.data = vif.readdata_o;
                    avalon_to_scoreboard_rx_fifo.put(transaction);
                    $display("[AVL Driver] READ_RX Completed");
                end

                TX_FIFO_IS_EMPTY: begin
                    $display("%t [AVL Driver] Handling TX_FIFO_IS_EMPTY Transaction:\n%s", $time, transaction.toString());
                    read(STATUS_REGISTER_ADDR);
                    assert (vif.readdata_o & TX_FIFO_EMPTY);
                    assert (!(vif.readdata_o & TX_FIFO_FULL));
                    $display("[AVL Driver] TX_FIFO_IS_EMPTY Completed");
                end

                TX_FIFO_IS_NOT_EMPTY: begin
                    $display("%t [AVL Driver] Handling TX_FIFO_IS_NOT_EMPTY Transaction:\n%s", $time, transaction.toString());
                    read(STATUS_REGISTER_ADDR);
                    assert (!(vif.readdata_o & TX_FIFO_EMPTY));
                    $display("[AVL Driver] TX_FIFO_IS_NOT_EMPTY Completed");
                end
                
                TX_FIFO_IS_FULL: begin
                    $display("%t [AVL Driver] Handling TX_FIFO_IS_FULL Transaction:\n%s", $time, transaction.toString());
                    read(STATUS_REGISTER_ADDR);
                    assert (!(vif.readdata_o & TX_FIFO_EMPTY));
                    assert (vif.readdata_o & TX_FIFO_FULL);
                    $display("[AVL Driver] TX_FIFO_IS_FULL Completed");
                end
                
                RX_FIFO_IS_EMPTY: begin
                    $display("%t [AVL Driver] Handling RX_FIFO_IS_EMPTY Transaction:\n%s", $time, transaction.toString());
                    read(STATUS_REGISTER_ADDR);
                    assert (!(vif.readdata_o & RX_FIFO_NOT_EMPTY));
                    assert (!(vif.readdata_o & RX_FIFO_FULL));
                    $display("[AVL Driver] RX_FIFO_IS_EMPTY Completed");
                end

                RX_FIFO_IS_NOT_EMPTY: begin
                    $display("%t [AVL Driver] Handling RX_FIFO_IS_NOT_EMPTY Transaction:\n%s", $time, transaction.toString());
                    read(STATUS_REGISTER_ADDR);
                    assert (vif.readdata_o & RX_FIFO_NOT_EMPTY);
                    $display("[AVL Driver] RX_FIFO_IS_NOT_EMPTY Completed");
                end

                RX_FIFO_IS_FULL: begin
                    $display("%t [AVL Driver] Handling RX_FIFO_IS_FULL Transaction:\n%s", $time, transaction.toString());
                    read(STATUS_REGISTER_ADDR);
                    assert (vif.readdata_o & RX_FIFO_NOT_EMPTY);
                    assert (vif.readdata_o & RX_FIFO_FULL);
                    $display("[AVL Driver] RX_FIFO_IS_FULL Completed");
                end

                default: begin
                    $display("%t [AVL Driver] Unknown Transaction Type:\n%s", $time, transaction.toString());
                end
            endcase

            objections_pkg::objection::get_inst().drop();
        end

    endtask : run

endclass : avalon_driver

`endif // AVALON_DRIVER_SV
