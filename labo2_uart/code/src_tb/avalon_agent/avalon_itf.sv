/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS
Institute Reconfigurable Embedded Digital Systems
********************************************************************************

File     : avalon_itf.sv
Author   : Clément Dieperink
Date     : 15.10.2024

Context  : Lab for the verification of an UART

********************************************************************************
Description : This file contains the interface for the avalon bus

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   15.10.2024  CDK        Initial version

*******************************************************************************/

`ifndef AVALON_ITF_SV
`define AVALON_ITF_SV

interface avalon_itf#();

    logic clk_i = 0;
    logic rst_i;
    logic[13:0] address_i;
    logic[3:0] byteenable_i;
    logic write_i;
    logic[31:0] writedata_i;
    logic read_i;
    logic readdatavalid_o;
    logic[31:0] readdata_o;
    logic waitrequest_o;

endinterface : avalon_itf

`endif // AVALON_ITF_SV
