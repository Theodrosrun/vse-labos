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
 
   // Vérifie un écriture puis une opération
   property p_complete_flow;
        logic[7:0] a;
        logic[7:0] b;
        logic[3:0] reg_a;
        logic[3:0] reg_b;

        @(posedge clk)
        disable iff(!Wen)
        (Wen == 1, a = InPort[Sel], reg_a = WA)

        @(posedge clk)
        disable iff(!Wen)
        (Wen == 1, b = InPort[Sel], reg_b = WA)

   endproperty

   // Propriété pour la stabilité de OutPort
   property p_stable_when_not_writing;
      @(posedge clk)
      disable iff (Wen == 1)

      $stable(OutPort);
   endproperty


   assert property(p_stable_when_not_writing);
   assert property(p_alu_operations);
   assert property(p_result_eventually);
endmodule

