
class coverage_class;
    rand logic wr;
    rand logic rd;
    rand logic[1:0] typee;
    rand logic[7:0] address;

endclass : coverage_class


module coverage_test;

    task test_case1();
        automatic coverage_class obj = new();
        automatic int counter = 0;


        $display("Let's start test 1");

        while ($get_coverage() < 100)
        begin
            counter ++;
            void'(obj.randomize());
            // obj.cov_group_type.sample();
        end
        $display("End of test 1 after %d iterations",counter);


    endtask


    // Programme lancé au démarrage de la simulation
    program TestSuite;
        initial begin
            test_case1();
            $display("done!");
            $stop;
        end
    endprogram

endmodule : coverage_test
