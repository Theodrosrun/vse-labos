set mergefile /home/reds/Desktop/Labos/VSE/ex01_plan_verification/code/VRMDATA/merge.ucdb
set cmd [list vcover merge  -out $mergefile]
if {[file readable $mergefile]} {lappend cmd $mergefile}
eval $cmd -inputs /home/reds/Desktop/Labos/VSE/ex01_plan_verification/code/VRMDATA/directed/test0/mergeScript.files
