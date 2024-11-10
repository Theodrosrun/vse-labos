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
   property p_result;
        @(posedge clk)
        disable iff (Wen ==1)
        ((Op == 3'b000) || (Op == 3'b001) || (Op == 3'b011) || (Op == 3'b100))
        |=>
        ##[0:100] (OutPort)
   endproperty

   // Vérification de l'addition (ADD)
   property p_alu_add;
      @(posedge clk)
      disable iff (Wen == 1)
      (Op == 3'b000) |-> (OutPort == (RAA + RAB)); // ADD : Y = A + B
   endproperty

   // Vérification de l'AND
   property p_alu_and;
      @(posedge clk)
      disable iff (Wen == 1)
      (Op == 3'b011) |-> (OutPort == (RAA & RAB)); // AND : Y = A and B
   endproperty

   // Vérification du MOV
   property p_alu_mov;
      @(posedge clk)
      disable iff (Wen == 1)
      (Op == 3'b100) |-> (OutPort == RAA); // MOV : Y = A
   endproperty

   // Propriété pour la stabilité de OutPort
   property p_stable_when_not_writing;
      @(posedge clk)
      disable iff (Wen == 1)
      $stable(OutPort); // Vérifie que OutPort reste stable quand Wen est désactivé
   endproperty

   // Assertions pour vérifier les propriétés
   assert property(p_result);
   assert property(p_alu_add);
   assert property(p_alu_and);
   assert property(p_alu_mov);
   assert property(p_stable_when_not_writing);
endmodule