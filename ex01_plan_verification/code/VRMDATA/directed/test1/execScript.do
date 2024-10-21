file delete -force work
set Path_DUV "/home/reds/Desktop/Labos/VSE/ex01_plan_verification/code/src_vhdl"
set Path_TB  "/home/reds/Desktop/Labos/VSE/ex01_plan_verification/code/src_tb"
global Path_DUV
global Path_TB
vlib work
vcom +cover -2008 $Path_DUV/uart.vhd
vcom +cover -2008 $Path_TB/uart_tb.vhd
vsim -coverage -t 10ps -GFIFOSIZE=8 -GTESTCASE=1 -GLOGFILENAME="log.txt" work.uart_tb
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run 2 ns
set StdArithNoWarnings 0
set NumericStdNoWarnings 0
run -all
coverage attribute -name TESTNAME -value test1
coverage save ../test1.ucdb
