/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : counter_sv_wrapper.sv
Author   : Yann Thoma
Date     : 25.10.2017

Context  : Example of assertions usage for formal verification

********************************************************************************
Description : This module is a wrapper that binds the DUV with the
              module containing the assertions

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   25.10.2017  YTA        Initial version

*******************************************************************************/

module onectr_wrapper#(int INPUTSIZE = 64)(
    input logic clk,
    input logic rst,
    input logic start_i,
    input logic[INPUTSIZE-1:0] inport,
    output logic[$clog2(INPUTSIZE+1)-1:0] outport
);

    // Instantiation of the DUV
    onectr#(INPUTSIZE) duv(.*);

    // Binding of the DUV and the assertions module
    bind duv onectr_assertions#(INPUTSIZE) binded(.*);

endmodule
