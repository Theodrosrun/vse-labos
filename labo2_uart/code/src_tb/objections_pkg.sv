/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : objection_pkg.sv
Author   : Yann Thoma
Date     : 08.12.2023

Context  : Lab for the verification of a datastream analyzer

********************************************************************************
Description : This package offers a class objection to manage the end of
              simulation.
              Various objection objects can be created, but for the most common
              cases, the use of the singleton pattern is encouraged, allowing
              to access a single object from everywhere in the testbench.
              For doing so a static method get_inst() enables to get the 
              singleton.
              A drain time can be setup, and the should_finish() function
              returns true if there has been no objection for drain_time time.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   08.12.2023  YTA        Initial version

*******************************************************************************/

package objections_pkg;

    class objection;

        local int nb;
        local time drain_time;
        local time zero_time;

        local static objection main_objection;

        function new;
            nb = 0;
            drain_time = 100;
            zero_time = $time();
        endfunction : new

        task raise(int n = 1);
            nb = nb + n;
        endtask : raise

        task drop(int n = 1);
            nb = nb - n;
            if (nb < 0)
                nb = 0;
            if (nb == 0)
                zero_time = $time();
        endtask : drop

        function no_objection;
            return nb == 0;
        endfunction : no_objection;

        task set_drain_time(time t);
            drain_time = t;
        endtask : set_drain_time

        function should_finish;
            return no_objection && ($time > drain_time + zero_time);
        endfunction : should_finish

        static function objection get_inst();
            if (main_objection == null) begin
                main_objection = new;
            end
            return main_objection;
        endfunction : get_inst

    endclass : objection

endpackage : objections_pkg