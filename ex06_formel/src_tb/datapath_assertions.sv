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

   // Propriété pour la stabilité de OutPort
   property p_stable_when_not_writing;
      @(posedge clk)
      disable iff (Wen == 1)
      $stable(OutPort);
   endproperty

// Vérification des opérations de l'ALU (sans le EQ)
property p_alu_operations;
   logic [7:0] expected_result;
   @(posedge clk)
   disable iff (Wen == 1)
   
   case (Op)
      3'b000: expected_result = RAA + RAB;
      3'b000: expected_result = RAA >> 1;
      3'b011: expected_result = RAA & RAB
      3'b100: expected_result = RAA;
      default: expected_result = 0;
   endcase
   |=>
   ##[0:100](OutPort == expected_result);
endproperty

   assert property(p_result_eventually);
   assert property(p_stable_when_not_writing);
   assert property(p_alu_operations);
endmodule
