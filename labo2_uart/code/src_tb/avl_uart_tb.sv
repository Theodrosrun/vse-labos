/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : avl_uart_tb.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the testbench instiantiating the DUV and
              creating the simulation environment.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`include "objections_pkg.sv"

`include "avalon_agent/avalon_transaction.sv"
`include "avalon_agent/avalon_itf.sv"
`include "avalon_agent/avalon_sequencer.sv"
`include "avalon_agent/avalon_driver.sv"
`include "avalon_agent/avalon_agent.sv"

`include "uart_agent/uart_transaction.sv"
`include "uart_agent/uart_itf.sv"
`include "uart_agent/uart_sequencer.sv"
`include "uart_agent/uart_driver.sv"
`include "uart_agent/uart_monitor.sv"
`include "uart_agent/uart_agent.sv"


`include "avl_uart_scoreboard_rx.sv"
`include "avl_uart_scoreboard_tx.sv"

`include "avl_uart_env.sv"

`include "avl_uart_interface_assertions.sv"

module avl_uart_tb#(int TESTCASE = 0, int DATASIZE = 20, int FIFOSIZE = 10, int ERRNO = 0);

    import objections_pkg::*;

    avalon_itf local_itf();
    uart_itf remote_itf();

    avl_uart_env#(DATASIZE, FIFOSIZE) env;

    logic clk_i;

    default clocking cb @(posedge clk_i);
    endclocking

    assign clk_i = local_itf.clk_i;

    avl_uart_interface#(DATASIZE, FIFOSIZE, ERRNO) duv(
        // Avalon Bus
        .avl_clk_i(local_itf.clk_i),
        .avl_reset_i(local_itf.rst_i),
        .avl_address_i(local_itf.address_i),
        .avl_byteenable_i(local_itf.byteenable_i),
        .avl_write_i(local_itf.write_i),
        .avl_writedata_i(local_itf.writedata_i),
        .avl_read_i(local_itf.read_i),
        .avl_readdatavalid_o(local_itf.readdatavalid_o),
        .avl_readdata_o(local_itf.readdata_o),
        .avl_waitrequest_o(local_itf.waitrequest_o),

        // UART Bus
        .rx_i(remote_itf.rx_i),
        .tx_o(remote_itf.tx_o)
    );

    // Binding of the DUV and the assertions module
    bind duv avl_uart_interface_assertions #(DATASIZE, FIFOSIZE) binded(.*);

    // clock generation
    always #10 local_itf.clk_i = ~local_itf.clk_i;

    initial begin
        // Format to print time (%t) in nanosecond, with " ns" suffix.
        // This allows to click on log in QuestaSim to go to the see it in the wave
        $timeformat(-9, 0, " ns", 15);

        // Set the drain time for objections, 50000 for aprox two times the baudrate
        objections_pkg::objection::get_inst().set_drain_time(10000 * 5);

        // Wait for the TB to start
        ##10;
        while (!objections_pkg::objection::get_inst().should_finish()) begin
            ##1;
        end

        env.end_display();

        $stop;
    end

    initial begin
        // Building the entire environment
        env = new;
        env.local_itf = local_itf;
        env.remote_itf = remote_itf;
        env.testcase = TESTCASE;
        env.build();
        env.connect();
        env.run();

        $finish;
    end

endmodule : avl_uart_tb
