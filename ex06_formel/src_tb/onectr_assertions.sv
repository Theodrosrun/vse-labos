/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : shiftregister_assertions.sv
Author   : Yann Thoma
Date     : 03.11.2017

Context  : Example of assertions usage for formal verification

********************************************************************************
Description : This module contains assertions for verifying a simple shift
              register. The modes are:
                            00 => hold
                            01 => shift left
                            10 => shift right
                            11 => load

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   03.11.2017  YTA        Initial version

*******************************************************************************/

module onectr_assertions#(int INPUTSIZE = 64)(
    input logic clk,
    input logic rst,
    input logic start_i,
    input logic[INPUTSIZE-1:0] inport,
    input logic[$clog2(INPUTSIZE+1)-1:0] outport
);

endmodule
