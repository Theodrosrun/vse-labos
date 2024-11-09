
proc compile_duv { } {
  vcom -mixedsvvh ../src_vhdl/alu.vhd -work work    -2008
  vcom -mixedsvvh ../src_vhdl/programcounter.vhd -work work    -2008
  vcom -mixedsvvh ../src_vhdl/regfile.vhd -work work    -2008
  vcom -mixedsvvh ../src_vhdl/rom.vhd -work work    -2008
  vcom -mixedsvvh ../src_vhdl/datapath.vhd -work work    -2008
  vcom -mixedsvvh ../src_vhdl/control.vhd -work work    -2008
  vcom -mixedsvvh ../src_vhdl/onectr_nomem.vhd -work work    -2008
  vcom -mixedsvvh ../src_vhdl/onectr_proc.vhd -work work    -2008
}

proc check_sva {Module} {

  switch $Module {
    0 {
      vlog -mixedsvvh ../src_tb/onectr_assertions.sv  ../src_tb/onectr_wrapper.sv
      formal compile -G INPUTSIZE=64 -d onectr_wrapper -work work
    }
    1 {
      vlog -mixedsvvh ../src_tb/regfile_assertions.sv  ../src_tb/regfile_wrapper.sv
      formal compile -G INPUTSIZE=64 -d regfile_wrapper -work work
    }
    2 {
      vlog -mixedsvvh ../src_tb/alu_assertions.sv  ../src_tb/alu_wrapper.sv
      formal compile -d alu_wrapper -work work
    }
    3 {
      vlog -mixedsvvh ../src_tb/onectr_nomem_assertions.sv  ../src_tb/onectr_nomem_wrapper.sv
      formal compile -G INPUTSIZE=64 -G PCSIZE=8 -d onectr_nomem_wrapper -work work
    }
    4 {
      vlog -mixedsvvh ../src_tb/programcounter_assertions.sv  ../src_tb/programcounter_wrapper.sv
      formal compile -G N=8 -d programcounter_wrapper -work work
    }
    5 {
      vlog -mixedsvvh ../src_tb/datapath_assertions.sv  ../src_tb/datapath_wrapper.sv
      formal compile -d datapath_wrapper -work work
    }
  }
  formal init
  formal verify -auto_constraint_off
}

compile_duv

check_sva $argv
