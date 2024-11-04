/*******************************************************************************
 HEIG-VD
 Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 School of Business and Engineering in Canton de Vaud
 ********************************************************************************
 REDS Institute
 Reconfigurable Embedded Digital Systems
 ********************************************************************************

 File     : avalon_wait_request_wrapper.sv
 Author   : Yann Thoma
 Date     : 03.05.2018

 Context  : Example of assertions usage for formal verification

 ********************************************************************************
 Description : This module is a wrapper that binds the DUV with the
 module containing the assertions

 ********************************************************************************
 Dependencies : -

 ********************************************************************************
 Modifications :
 Ver   Date        Person     Comments
 1.0   03.05.2018  YTA        Initial version

 *******************************************************************************/


module avalon_assertions_wrapper #(
                                   int AVALONMODE = 0,
                                   int TESTCASE = 0,
                                   int NBDATABYTES = 2,
                                   int NBADDRBITS = 8,
                                   int WRITEDELAY = 2,  // Delay for fixed delay write operation
                                   int READDELAY = 1,   // Delay for fixed delay read operation
                                   int FIXEDDELAY = 2)  // Delay for pipeline operation
   ;

   logic                               clk = 0;
   logic                               rst = 0;

   logic [NBADDRBITS-1:0]              address;
   logic [NBDATABYTES:0]               byteenable;
   logic [2^NBDATABYTES-1:0]           readdata;
   logic [2^NBDATABYTES-1:0]           writedata;
   logic                               read;
   logic                               write;
   logic                               waitrequest;
   logic                               readdatavalid;
   logic [7:0]                         burstcount;
   logic                               beginbursttransfer;


   // Génération de l'horloge
   always #5 clk = ~clk;

   // Instantiation of the DUV
   avalon_generator #(AVALONMODE, TESTCASE, NBDATABYTES, NBADDRBITS, WRITEDELAY,
                     READDELAY, FIXEDDELAY) duv(.*);

   // Binding of the DUV and the assertions module
   bind duv avalon_assertions #(AVALONMODE, TESTCASE, NBDATABYTES, NBADDRBITS,
                               WRITEDELAY, READDELAY, FIXEDDELAY) binded(.*);

endmodule
