set NumericStdNoWarnings 1

vcom -explicit ../src_vhdl/rom.vhd ../src_vhdl/alu.vhd ../src_vhdl/adder.vhd ../src_vhdl/adderreg.vhd ../src_vhdl/regfile.vhd ../src_vhdl/datapath.vhd ../src_vhdl/control.vhd ../src_vhdl/onectr.vhd ../src_tb/onectr_tb.vhd
vsim onectr_tb


add wave -r *

run -all
