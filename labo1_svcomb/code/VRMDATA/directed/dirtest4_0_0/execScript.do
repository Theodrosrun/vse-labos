file delete -force work
set Path_DUV     "/home/reds/Desktop/Labos/vse-labos/labo1_svcomb/code/src_vhdl"
set Path_TB       "/home/reds/Desktop/Labos/vse-labos/labo1_svcomb/code/src_tb"
global Path_DUV
global Path_TB
vlib aff_min_max
vcom -2008 -work aff_min_max $Path_DUV/bin_lin.vhd
vcom -2008 -work aff_min_max $Path_DUV/comparator_nbits.vhd
vcom -2008 -work aff_min_max $Path_DUV/affichage.vhd
vmap aff_min_max aff_min_max
vlib work
vcom -2008 $Path_DUV/min_max_top.vhd
vlog -sv $Path_TB/min_max_top_tb.sv
vsim -t 10ps -GVALSIZE=4 -GERRNO=0 -GTESTCASE=0 work.min_max_top_tb
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run 2 ns
set StdArithNoWarnings 0
set NumericStdNoWarnings 0
run -all
coverage attribute -name ERRNO -value dirtest4_0_0
coverage save ../dirtest4_0_0.ucdb
