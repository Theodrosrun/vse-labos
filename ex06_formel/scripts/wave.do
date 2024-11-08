onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /onectr_tb/clk
add wave -noupdate -format Logic /onectr_tb/rst
add wave -noupdate -format Logic /onectr_tb/start
add wave -noupdate -format Literal /onectr_tb/count
add wave -noupdate -format Literal /onectr_tb/inport
add wave -noupdate -format Literal /onectr_tb/outport
add wave -noupdate -format Literal /onectr_tb/outport1
add wave -noupdate -format Literal /onectr_tb/outport2
add wave -noupdate -format Literal /onectr_tb/outport3
add wave -noupdate -format Literal /onectr_tb/outport4
add wave -noupdate -format Literal /onectr_tb/outport5
add wave -noupdate -format Literal /onectr_tb/ctr/data/reg/reg
add wave -noupdate -format Literal -radix decimal /onectr_tb/ctr/ctr/pc
add wave -noupdate -format Logic /onectr_tb/ctr/clk
add wave -noupdate -format Logic /onectr_tb/ctr/start
add wave -noupdate -format Literal /onectr_tb/ctr/inport
add wave -noupdate -format Literal /onectr_tb/ctr/outport
add wave -noupdate -format Literal /onectr_tb/ctr/ctrl
add wave -noupdate -format Literal /onectr_tb/ctr/sel
add wave -noupdate -format Logic /onectr_tb/ctr/wen
add wave -noupdate -format Literal /onectr_tb/ctr/wa
add wave -noupdate -format Literal /onectr_tb/ctr/raa
add wave -noupdate -format Literal /onectr_tb/ctr/rab
add wave -noupdate -format Literal /onectr_tb/ctr/op
add wave -noupdate -format Logic /onectr_tb/ctr/flag
add wave -noupdate -format Logic /onectr_tb/ctr/ctr/clk
add wave -noupdate -format Logic /onectr_tb/ctr/ctr/start
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/ctrl
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/sel
add wave -noupdate -format Logic /onectr_tb/ctr/ctr/wen
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/wa
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/raa
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/rab
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/op
add wave -noupdate -format Logic /onectr_tb/ctr/ctr/flag
add wave -noupdate -format Logic /onectr_tb/ctr/ctr/jp
add wave -noupdate -format Logic /onectr_tb/ctr/ctr/jf
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/addr
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/rom_out
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/mem/addr
add wave -noupdate -format Literal /onectr_tb/ctr/ctr/mem/data
add wave -noupdate -format Logic /onectr_tb/ctr/data/clk
add wave -noupdate -format Literal /onectr_tb/ctr/data/inport
add wave -noupdate -format Literal /onectr_tb/ctr/data/outport
add wave -noupdate -format Literal /onectr_tb/ctr/data/ctrl
add wave -noupdate -format Literal /onectr_tb/ctr/data/sel
add wave -noupdate -format Logic /onectr_tb/ctr/data/wen
add wave -noupdate -format Literal /onectr_tb/ctr/data/wa
add wave -noupdate -format Literal /onectr_tb/ctr/data/raa
add wave -noupdate -format Literal /onectr_tb/ctr/data/rab
add wave -noupdate -format Literal /onectr_tb/ctr/data/op
add wave -noupdate -format Logic /onectr_tb/ctr/data/flag
add wave -noupdate -format Literal /onectr_tb/ctr/data/inreg
add wave -noupdate -format Literal /onectr_tb/ctr/data/a
add wave -noupdate -format Literal /onectr_tb/ctr/data/b
add wave -noupdate -format Literal /onectr_tb/ctr/data/aluout
add wave -noupdate -format Logic /onectr_tb/ctr/data/aluflag
add wave -noupdate -format Literal /onectr_tb/ctr/data/thealu/op
add wave -noupdate -format Literal /onectr_tb/ctr/data/thealu/a
add wave -noupdate -format Literal /onectr_tb/ctr/data/thealu/b
add wave -noupdate -format Literal /onectr_tb/ctr/data/thealu/y
add wave -noupdate -format Logic /onectr_tb/ctr/data/thealu/f
add wave -noupdate -format Literal -expand /onectr_tb/ctr/data/reg/reg
add wave -noupdate -format Logic /onectr_tb/ctr/data/reg/clk
add wave -noupdate -format Literal /onectr_tb/ctr/data/reg/w
add wave -noupdate -format Literal /onectr_tb/ctr/data/reg/a
add wave -noupdate -format Literal /onectr_tb/ctr/data/reg/b
add wave -noupdate -format Logic /onectr_tb/ctr/data/reg/wen
add wave -noupdate -format Literal /onectr_tb/ctr/data/reg/wa
add wave -noupdate -format Literal /onectr_tb/ctr/data/reg/raa
add wave -noupdate -format Literal /onectr_tb/ctr/data/reg/rab
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19033 ns} 0}
configure wave -namecolwidth 254
configure wave -valuecolwidth 78
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {15417 ns} {20745 ns}
