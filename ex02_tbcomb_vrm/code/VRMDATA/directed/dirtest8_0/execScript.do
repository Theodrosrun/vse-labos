file delete -force work
set Path_DUV     "/home/reds/Desktop/Labos/VSE/ex02_tbcomb_vrm/code/src_vhdl"
set Path_TB       "/home/reds/Desktop/Labos/VSE/ex02_tbcomb_vrm/code/src_tb"
global Path_DUV
global Path_TB
vlib work
vcom +cover -2008 $Path_DUV/adder.vhd
vlog +cover -sv $Path_TB/adder_tb.sv
vsim -coverage -t 10ps -GDATASIZE=8 -GTESTCASE=0 work.adder_tb
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run 2 ns
set StdArithNoWarnings 0
set NumericStdNoWarnings 0
run -all
coverage attribute -name TESTNAME -value dirtest8_0
coverage save ../dirtest8_0.ucdb
