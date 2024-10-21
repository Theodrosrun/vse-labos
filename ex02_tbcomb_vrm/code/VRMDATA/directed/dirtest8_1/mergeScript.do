set mergefile /home/reds/Desktop/Labos/VSE/ex02_tbcomb_vrm/code/VRMDATA/merge.ucdb
set cmd [list vcover merge  -out $mergefile]
if {[file readable $mergefile]} {lappend cmd $mergefile}
eval $cmd -inputs /home/reds/Desktop/Labos/VSE/ex02_tbcomb_vrm/code/VRMDATA/directed/dirtest8_1/mergeScript.files
