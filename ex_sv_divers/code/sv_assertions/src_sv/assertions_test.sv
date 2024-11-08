module assertions_test;

    logic clk = 0;
    logic req;
    logic ack;
    logic a;
    logic b;
    logic c;

    // génération de l'horloge
    always #5 clk = ~clk;


    // clocking block
    default clocking cb @(posedge clk);
    endclocking

    task test_case1();
        $display("Let's start test 1");
        req <= 0;
        ack <= 0;
        ##1;
        req <= 1;
        ##1;
        req <= 0;
        ##5;
        ack <= 1;

        $display("End of test 1");


    endtask

    task test_case2();
        $display("Let's start test 2");


        $display("End of test 2");
    endtask

    // Programme lancé au démarrage de la simulation
    program TestSuite;
        initial begin
            test_case1();
            test_case2();
            $display("done!");
            $stop;
        end
    endprogram

endmodule : assertions_test
