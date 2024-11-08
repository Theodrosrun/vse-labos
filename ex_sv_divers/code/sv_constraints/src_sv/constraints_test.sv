class constraints_class;
    rand logic wr;
    rand logic rd;
    rand logic cs;
    rand logic[1:0] typee;
    rand logic[7:0] address;
    rand logic[31:0] data;
    rand logic parity;

endclass : constraints_class


module constraints_test;

    task test_case1();
        automatic constraints_class obj = new();


        $display("Let's start test 1");

        for(int i=0;i<100;i++)
        begin
            void'(obj.randomize());
            $display("cs = %d, wr = %d, rd = %d, typee = %d, address = %d, data = %d, parity = %d",
                obj.cs, obj.wr, obj.rd, obj.typee, obj.address, obj.data, obj.parity);
        end
        $display("End of test 1");


    endtask


    // Programme lancé au démarrage de la simulation
    program TestSuite;
        initial begin
            test_case1();
            $display("done!");
            $stop;
        end
    endprogram

endmodule : constraints_test
