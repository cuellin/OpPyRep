# ##############################################################################
#
# CheckDrift.tcl 
#
# written by Francisco Flores 
#
#
#
#  Procedure to check drift during a nonlinear dynamic anlaysis and stop the analysis 
#
# ##############################################################################

proc CheckDrift {FolderModel resDir1 FloorNodes IDA_SF GMfile} {
	# FolderModel: Folder where the model is located
	# ResDir: Folder where results are going to be located
	
	# Checking drifts to evaluate if analysis should be stopped 
	# InterStory Drifts 
	set maxDrift 0.1
	foreach FN $FloorNodes {
		lappend Ndisp  [nodeDisp $FN  1]
		lappend Ncoord [nodeCoord $FN 2] 
	}
	for {set x 0} {$x< [expr [llength $FloorNodes]-1]} {incr x 1} {
		lappend drift [expr ([lindex $Ndisp [expr $x+1]]-[lindex $Ndisp $x])/([lindex $Ncoord [expr $x+1]]-[lindex $Ncoord [expr $x]])]
		 if {abs([lindex $drift $x])>=$maxDrift} {
			 set stopFlag 1; 
					file mkdir $FolderModel/$resDir1/Collapses
					set LengthString [string length $GMfile]
					set GM_Name [string range $GMfile 0 [expr $LengthString-5]]

					set fname "Collapse_$GM_Name.out"
					set fidwrite [open $FolderModel/$resDir1/Collapses/$fname a]  ;  # Open file and writes at the end 
					puts $fidwrite "set GMcollapse ${GM_Name}"
					puts $fidwrite "set IDAcollapse ${IDA_SF}"
					puts $fidwrite "set ${GM_Name}_Flag 1" ; #1 means collapse 					
					close $fidwrite  ;  # Close file
					return $stopFlag
		 } else {
			 set stopFlag 0;
			 unset Ndisp Ncoord drift
			 return $stopFlag
		 }
	}
}
