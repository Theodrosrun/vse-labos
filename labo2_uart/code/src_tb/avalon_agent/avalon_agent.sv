/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : avalon_agent.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the Avalon agent, that is the one generating
              accessing using the UART through an Avalon bus to send/read
              data from the remote.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef AVALON_AGENT_SV
`define AVALON_AGENT_SV

class avalon_agent#(int DATASIZE=20, int FIFOSIZE=10);

    int testcase;

    avalon_sequencer#(DATASIZE, FIFOSIZE) sequencer;
    avalon_driver#(DATASIZE, FIFOSIZE) driver;

    virtual avalon_itf vif;

    avalon_fifo_t sequencer_to_driver_fifo;
    avalon_fifo_t avalon_to_scoreboard_rx_fifo;
    avalon_fifo_t avalon_to_scoreboard_tx_fifo;

    task build;
        sequencer_to_driver_fifo = new(10);

        sequencer = new;
        driver = new;

        sequencer.testcase = testcase;
        driver.testcase = testcase;
    endtask : build

    task connect;
        sequencer.sequencer_to_driver_fifo = sequencer_to_driver_fifo;
        driver.sequencer_to_driver_fifo = sequencer_to_driver_fifo;

        driver.avalon_to_scoreboard_rx_fifo = avalon_to_scoreboard_rx_fifo;
        driver.avalon_to_scoreboard_tx_fifo = avalon_to_scoreboard_tx_fifo;

        driver.vif = vif;
    endtask : connect

    task run;
        fork
            sequencer.run();
            driver.run();
        join;
    endtask : run

endclass : avalon_agent

`endif // AVALON_AGENT_SV
