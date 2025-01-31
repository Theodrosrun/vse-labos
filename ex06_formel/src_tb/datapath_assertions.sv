module datapath_assertions(
        input  logic       clk,
        input  logic[63:0] InPort,
        input  logic[6:0]  OutPort,
        input  logic[7:0]  Ctrl,
        input  logic[3:0]  Sel,
        input  logic       Wen,
        input  logic[3:0]  WA,
        input  logic[3:0]  RAA,
        input  logic[3:0]  RAB,
        input  logic[2:0]  Op,
        input  logic       Flag
);

   // Lorsqu’une opération modifiant Y est lancée, un résultat doit être présenté sur OutPort après un certain temps
   property p_result_eventually;
        @(posedge clk)
        disable iff (Wen ==1)

        ((Op == 3'b000) || (Op == 3'b001) || (Op == 3'b011) || (Op == 3'b100))
        |=>
        ##[0:100] (OutPort);
   endproperty
 
   // Vérifie que pour MOV, le Flag doit être 0 (pas de changement d'état)
   property p_flag_mov;
      @(posedge clk)
      disable iff (!Wen)

      (Op == 3'b100) |=> (Flag == 0);
   endproperty

   assert property(p_result_eventually);
   assert property(p_stable_when_flag_written);
   assert property(p_flag_mov);
   
endmodule
