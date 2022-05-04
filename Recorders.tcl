# ##################################
# Recorders.tcl        #############
# AMERICAN WOOD COUNCIL ############
# ##################################
set LengthString [string length $GMfile]
set GM_Name [string range $GMfile 0 [expr $LengthString-5]]

if {$IncPD==Y} {
# Recorder ---
set resDir1  "6_NTH"
file mkdir $FolderModel/$resDir1
file mkdir $FolderModel/$resDir1/Res_${GM_Name}
file mkdir $FolderModel/$resDir1/Res_${GM_Name}/SF_${IDA_SF}

set resDir "$resDir1/Res_${GM_Name}/SF_${IDA_SF}" 
puts "$resDir"
} else {
# Recorder ---
set resDir1  "6_NTH_NoPD"
file mkdir $FolderModel/$resDir1
file mkdir $FolderModel/$resDir1/Res_${GM_Name}
file mkdir $FolderModel/$resDir1/Res_${GM_Name}/SF_${IDA_SF}
set resDir "$resDir1/Res_${GM_Name}/SF_${IDA_SF}" 

}


# Material Stiffness: This is used to check the sequence of yielding 
eval recorder Element -file  \$FolderModel/$resDir/K_Mat_${GM_Name}_${IDA_SF}.out\  -dT $dt -ele $SWelem material 1 tangent 

# Force Deformation  
eval recorder Element -file  \$FolderModel/$resDir/Force_SW_${GM_Name}_${IDA_SF}.out\ -dT $dt  -ele $SWelem force
eval recorder Element -file  \$FolderModel/$resDir/Deform_SW_${GM_Name}_${IDA_SF}.out\ -dT $dt -ele $SWelem deformation

# Roof Displacement 
set RoofNode [lindex $fnodes_dyn end]
eval recorder Node -file \$FolderModel/$resDir/RoofDisp_${GM_Name}_${IDA_SF}.out\ -time -dT $dt -node $RoofNode -dof 1  disp ; 

eval recorder Node -file \$FolderModel/$resDir/NDisp_${GM_Name}_${IDA_SF}.out\ -time  -dT $dt -node $fnodes_dyn -dof 1  disp ; 


# InterStory Drifts 
for {set x 0} {$x< [expr [llength $fnodes_dyn]-1]} {incr x 1} {
eval recorder Drift -file \$FolderModel/$resDir/Story_[expr $x+1]_Drift_${GM_Name}_${IDA_SF}.out\ -time -dT $dt  -iNode [lindex $fnodes_dyn $x] -jNode [lindex $fnodes_dyn [expr $x+1]]  -dof 1 -perpDirn 2 
}

# Roof Drift 
eval recorder Drift -file \$FolderModel/$resDir/Roof_Drift_${GM_Name}_${IDA_SF}.out\ -time -dT $dt -iNode [lindex $fnodes_dyn 0] -jNode [lindex $fnodes_dyn end]  -dof 1 -perpDirn 2 

# Base Shear 
eval recorder Node -file \$FolderModel/$resDir/ReactionsX_${GM_Name}_${IDA_SF}.out\ -time -dT $dt  -node $BaseColumnNodes -dof 1 reaction

# Nodes Disp 
eval recorder Node -file \$FolderModel/$resDir/NodeDisp_${GM_Name}_${IDA_SF}.out\ -dT $dt -nodeRange 1 1000000  -dof 1 2 3 disp ; 


print -file $FolderModel/$resDir1/Info.out
print -JSON -file $FolderModel/$resDir1/Info_JSON.out

set fname "NodeCoordinates.txt"
set fidwrite [open $FolderModel/$resDir1/$fname w]  ;  # Open file
set ModelNodes [getNodeTags]
foreach tag $ModelNodes {
	puts $fidwrite "$tag [nodeCoord $tag]"  ;  # Print Nodal Coordinates to File
}  ;  # end foreach tag
close $fidwrite  ;  # Close file


set ElementTags [getEleTags]  ;  # Retrieve Element Tags
set fname2 "ConnectivityMatrix.txt"
set fidwrite [open $FolderModel/$resDir1/$fname2 w]  ;  # Open file
foreach tag $ElementTags {
	puts $fidwrite "$tag [eleNodes $tag]"  ;  # Print Nodal Coordinates to File
}  ;  # end foreach tag
close $fidwrite  ;  # Close file

# Material Stiffness
#recorder Element -file $resDir/Rigidez.out -ele 10  

# #######################################################
# ############# INFORMATION REQUIRED FOR ENERGIES #######

# Damping Forces
eval recorder Node -file \$FolderModel/$resDir/DampingForces_${GM_Name}_${IDA_SF}.out\ -dT $dt -nodeRange 1 10000  -dof 1 2 3 rayleighForces


# Velocities
eval recorder Node -file \$FolderModel/$resDir/NodesVel_${GM_Name}_${IDA_SF}.out\ -dT $dt -nodeRange 1 10000  -dof 1 2 3 vel


# Ground Acceleration  
eval recorder Node -file \$FolderModel/$resDir/GroundAccel_${GM_Name}_${IDA_SF}.out\ -dT $dt -timeSeries $accelSeries -time  -node 111 -dof 1 accel;

#LogFile Command

eval logFile output.out -append
