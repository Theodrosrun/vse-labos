set Perspective_Version   2
#
pref::section perspective
set perspective_Name       {qverify}
set perspective_DateTime   {2024-11-11T17:57:44}
set perspective_Directory  {/home/reds/Desktop/Labos/vse-labos/ex06_formel/sim}
set perspective_USER       {reds}
set perspective_VisId      {2020.2_1}
#
pref::section preference
pref::set -type bool -category General -name PromptForWavefile -value false -hide -description {Operations that require a wave file will trigger a prompt for wave file if this value is true,
otherwise the operation will be disabled} -label {Prompt for wavefile as needed}
pref::set -type bool -category General -name IncludeActiveScopeInTitle -value true -hide -description {Windows that follow the current context will display that context in their title bar} -label {Display the current context in window title bars}
pref::set -type bool -category General -name AutoReloadOnFault -value false -hide -description {If the tool should recieve a fatal signal, this preference indicates whether it should attmept to automatically restart.} -label {Automatically restart if a signal fault occurs.}
pref::set -type bool -category General -name ShowExpandWindowButton -value true -hide -description {Each window's title bar will have a +/- button to enter/exit expanded window mode respectively} -label {Show Expand Window Button in Titlebar}
pref::set -type bool -category {Source Browser} -name EnableExecutionTrace -value false -hide -description {Enable Execution Trace} -label {Enable Execution Trace}
pref::set -type bool -category Variable -name VarSingleClickNav -value false -hide -description {Navigate to Source on a single click rather than a double click} -label {Variables Single Click Navigation}
pref::set -type bool -category Waveform -name PanToCursor -value false -description {Pan wave window to primary cursor time if true} -label {Pan to Primary Cursor Time}
pref::set -type font -category Waveform.Font -name WaveformFont -value {Liberation Sans,12,-1,5,50,0,0,0,0,0} -description {Font used within wave window for signal, names, values, etc.} -label {Waveform Font}
pref::set -type int -category {Driver Receiver} -name MaxDriverReceiverCount -value 0 -hide -description {Set maximum value of driver receiver count that can be shown in window} -label {Maximum Driver Receiver Count}
pref::set -type int -category {Driver Receiver} -name DriverReceiverMax -value 10000 -description {<p style='white-space: pre'>Maximum number of driver/receiver<br>objects to be shown in the window.<br>Note: Change is seen in next session.<br>Note: Use a value of "0" to restore the default.} -label {Maximum displayed drivers / receivers}
pref::set -type bool -category PropCheck -name directivesEditorGroup -value false -hide -description none -label none
pref::set -type bool -category PropCheck -name confirmExitStopsRun -value true -description {<p style='white-space: pre'>Show confirmation when exiting and a run is in-progress.<br>Unselecting this option will automatically terminate<br>a run that is in-progress.} -label {Confirm exiting will stop an in-progress run}
pref::set -type string -category PropCheck -name formalControlPointsRadixType -value b -hide -description none -label none
pref::set -type string -category PropCheck -name waveGroupStates -value grpClks=1grpRsts=2grpPropSigs=1grpCtrlPts=1grpContribs=0 -hide -description none -label none
pref::set -type color -category PropCheck.Color -name contribWaveAnnoColor -value #3c5e36 -description {<p style='white-space: pre'>Color used in wave window to identify ranges of times for which<br>a contributing signal's values are relevant for the firing.<br>Note: Change not applied to currently visible waveforms.} -label {Contributor time regions}
pref::set -type string -category PropCheck.Properties -name waveConfigFile -value {} -description {<p style='white-space: pre'>A file to be loaded every time a wave window is opened.<br><i>It may contain any valid Tcl command.} -label {Auto-load file}
pref::set -type bool -category PropCheck.Properties -name dontCaresX -value false -description {<p style='white-space: pre'>By default, waveforms use 0's for the don't care<br>values. This option applies X's instead. The X's<br>propagate using the semantic rules for X propagation.} -label {Use X for don't care values on control points}
pref::set -type bool -category PropCheck.Properties -name runShowsMonitor -value true -description {<p style='white-space: pre'>The Run Monitor window will open<br>when a new verify run begins.} -label {Open Run Monitor when a run begins}
pref::set -type int -category PropCheck.Properties -name extraCycles -value 1 -description {<p style='white-space: pre'>Include in the waveform the specified number<br>of cycles after the cycle with the firing} -label {Number of cycles after firing}
pref::set -type bool -category PropCheck.Properties -name showCountsSummary -value false -hide -description none -label none
pref::set -type string -category PropCheck.table_columns -name propcheck_Table -value %00%00%00%FF%00%00%00%00%00%00%00%01%00%00%00%00%00%00%00%04%01%00%00%00%00%00%00%00%00%00%00%00%13%E6%F0%06%00%00%00%0B%00%00%00%0F%00%00%00%B2%00%00%00%0E%00%00%00%B2%00%00%00%05%00%00%002%00%00%00%07%00%00%00%28%00%00%00%06%00%00%002%00%00%00%01%00%00%00d%00%00%00%11%00%00%02%15%00%00%00%02%00%00%00%19%00%00%00%12%00%00%00d%00%00%00%0D%00%00%00%3C%00%00%00%0C%00%00%00%B2%00%00%07Y%00%00%00%13%01%01%00%01%00%00%00%00%00%00%00%00%00%00%00%00d%FF%FF%FF%FF%00%00%00%01%00%00%00%00%00%00%00%13%00%00%00%19%00%00%00%01%00%00%00%02%00%00%00%00%00%00%00%01%00%00%00%00%00%00%00%00%00%00%00%01%00%00%00%02%00%00%00%28%00%00%00%01%00%00%00%02%00%00%00%28%00%00%00%01%00%00%00%02%00%00%00%00%00%00%00%01%00%00%00%00%00%00%00%00%00%00%00%01%00%00%00%00%00%00%00%00%00%00%00%01%00%00%00%02%00%00%01%BD%00%00%00%01%00%00%00%00%00%00%00%85%00%00%00%01%00%00%00%00%00%00%00P%00%00%00%01%00%00%00%02%00%00%00%B2%00%00%00%01%00%00%00%00%00%00%00%00%00%00%00%01%00%00%00%00%00%00%00%00%00%00%00%01%00%00%00%02%00%00%00%00%00%00%00%01%00%00%00%00%00%00%00%00%00%00%00%01%00%00%00%00%00%00%03%AC%00%00%00%01%00%00%00%00%00%00%00%00%00%00%00%01%00%00%00%00%00%00%00%00%00%00%00%01%00%00%00%00%00%00%03%E8%00%00%00%00Y -description unused -label unused
pref::set -type string -category PropCheck.table_columns -name propcheck_Table_signature -value {,SEQ#,,,,Sc,Vc,Dc,Name,Groups,Health,Radius,Absolute Radius,Cov,Module,Instance,Time,File,} -description unused -label unused
pref::set -type int -category PropCheck_propertySummary -name displayMode -value 0 -hide -description unused -label unused
pref::set -type int -category PropCheck_propertySummary -name childWidth -value 0 -hide -description unused -label unused
Perspective_Complete
