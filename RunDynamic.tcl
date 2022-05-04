# ######################### 
# RunDynamic.tcl ##########
# AMERICAN WOOD COUNCIL ####
# ##########################
#reset
# Main file to run a NTH Analysiswipe

if {[info exists argv]} {
	puts $argv
	if {[llength $argv]>0} {
	set GMfile1 [lindex $argv 0]
	set GMfile  [string range $GMfile1 2 [expr [string length $GMfile1]-2]]
	
	set Scalefact1 [lindex $argv 1]
	set Scalefact  [string range $Scalefact1 2 [expr [string length $Scalefact1]-2]]	
	
	set IDA_SF1 [lindex $argv 2]
	set IDA_SF  [string range $IDA_SF1 2 [expr [string length $IDA_SF1]-2]]	
	
	set FolderAnalysis1 [lindex $argv 3]
	set FolderAnalysis  [string range $FolderAnalysis1 2 [expr [string length $FolderAnalysis1]-2]]		
	
	set FolderModel1 [lindex $argv 4]
	set FolderModel  [string range $FolderModel1 2 [expr [string length $FolderModel1]-2]]
	
	set ChooseAnalysis1 [lindex $argv 5]
	set ChooseAnalysis  [string range $ChooseAnalysis1 2 [expr [string length $ChooseAnalysis1]-2]]
	
	#source  $FolderAnalysis\\8_IDAParallel\\InfoParallel.tcl
	puts "\nAnalyzing ${GMfile} using ScaleFactor=${Scalefact} fora IDA_SF=${IDA_SF}"
	}
}

#puts "\nPerforming Nonlinear Time History Analysis"
wipe
wipeAnalysis
#Defining Model 
model basic -ndm 2  -ndf 3 
set  ConvTest [list "NormUnbalance" "NormDispIncr" "EnergyIncr" "RelativeNormUnbalance" "RelativeNormDispIncr" "RelativeTotalNormDispIncr" "RelativeEnergyIncr" "FixedNumIte"]


# IN CASE OF HAVING CONVERGENCE PROBLEMS, TRY DIFFERENT CONVERGENCE TEST
set tol 1.e-0006
set iter 100

#Choose Test 
#"0"-->NormUnbalance
#"1"-->NormDispIncr
#"2"-->EnergyIncr
#"3"-->RelativeNormUnbalance
#"4"-->RelativeNormDispIncr
#"5"-->RelativeTotalNormDispIncr
#"6"-->RelativeEnergyIncr
#"7"-->FixedNumIte

set ChooseTest 4

# 1) Required model files to perform the analysis
source  $FolderModel\\Materials.tcl
source  $FolderModel\\ModelGeometry.tcl
source  $FolderModel\\InfoModel.tcl
source $FolderAnalysis\\6_NTHAnalysis\\InherentDamping.tcl
source  $FolderAnalysis\\6_NTHAnalysis\\readAT2.tcl
source  $FolderAnalysis\\6_NTHAnalysis\\checkDrift.tcl
source  $FolderAnalysis\\6_NTHAnalysis\\ReRunDynamicAnalysis.tcl


set GMpath ${FolderAnalysis}\\6_NTHAnalysis

if { $Choose=="FarField" } {
	
	set inFilename ${GMpath}\\P695_Far_Field\\$GMfile
	readAT2file $inFilename ${GMfile}_temp_$IDA_SF dt npts
	
} elseif { $Choose== "NearField"} {
	set inFilename $GMpath\\P695_Near_Field\\$GMfile
	readAT2file $inFilename ${GMfile}_temp_$IDA_SF dt npts
	
}

if {$IncPD=="Y"} {
source  $FolderModel\\GravityLoads.tcl
wipeAnalysis
# Defining Analysis Parameters
#1. ConstraintsHandler 
constraints Plain

#2. DOF_Numberer 
numberer RCM

#3 System of Equations 
system BandSPD ;# Se requiere FullGeneral si queremos obtener la matriz de rigidez  

#4.Convergence Test
set tol 1.e-006
set iter 1000	
test [lindex $ConvTest $ChooseTest] $tol $iter

#5.Algorithm
algorithm Newton 

#6 Integrator 
integrator LoadControl 1.0
# 7 Type of Analysis

analysis Static  
#8 Analyze 
analyze 1
loadConst -time 0.0 ; # Keeps vertical load constant (P-Delta constant )
puts "Gravity Loads Applied"
}


# Load Pattern ID 
set patternID 100

# Acceleration Series ID 
set accelSeries 100 

# Ground Motion Direction 
set GMdirection 1 

# Ground Motion Duration 
set maxtime [expr $dt*$npts]


# Total Scaling Factor 
set accfactor [expr $g*$Scalefact*$IDA_SF]
puts "the accfactor is $accfactor, the dt=$dt and IDA_SF=$IDA_SF"
# Defining Ground Motion --- TIme series
puts "Analyzing GM=$GMfile IDA_SF=$IDA_SF"
#timeSeries Path $tag 		  -dt $dt -filePath $filePath <-factor $cFactor>
timeSeries Path  $accelSeries -dt $dt -filePath ${GMfile}_temp_$IDA_SF -factor $accfactor


# Defining Load 
#pattern UniformExcitation $patternTag $dir -accel $tsTag
pattern UniformExcitation $patternID $GMdirection -accel $accelSeries

# #######################################################
# Recorders 
if {$ChooseAnalysis == 6} {
source $FolderAnalysis\\6_NTHAnalysis\\Recorders.tcl
} elseif {$ChooseAnalysis == 7} {
source $FolderAnalysis\\7_IDAAnalysis\\Recorders.tcl
} elseif {$ChooseAnalysis == 8} {
source $FolderAnalysis\\8_IDAParallel\\Recorders.tcl
} elseif {$ChooseAnalysis == 9} {
source $FolderAnalysis\\9_CMR_Parallel\\Recorders.tcl
} elseif {$ChooseAnalysis == 10} {
source $FolderAnalysis\\10_IDA_Par_MPI\\Recorders.tcl
} elseif {$ChooseAnalysis == 11} {
source $FolderAnalysis\\11_CMR_Par_MPI\\Recorders.tcl
}     
 
# ################################################
# Performing Nonlinear Time History Analysis 




# Performing Analysis 
# Defining Analysis Parameters
wipeAnalysis
# Defining Analysis Parameters
#1. ConstraintsHandler 
constraints Plain

#2. DOF_Numberer 
numberer RCM

#3 System of Equations 
system BandSPD ;# Se requiere FullGeneral si queremos obtener la matriz de rigidez 

#4.Convergence Test
set tol 1.e-006
set iter 1000	
test [lindex $ConvTest $ChooseTest] $tol $iter
#5.Algorithm
algorithm ModifiedNewton -initial 

#6. Integrator
integrator Newmark 0.5 0.25 

#7. Analysis
analysis Transient

set DtAnalysis [expr $dt/10];
set Nsteps     [expr int($maxtime/$DtAnalysis)]


# Analysis Begin 
set Tini [clock clicks -milliseconds]
# ################################ 
# ANALYSIS STARTS
file delete -force ${GMfile}_temp_$IDA_SF

set Dtori $DtAnalysis 
set incrtol 0.00001
		set ok 0		
		set DtAnalysis [expr $DtAnalysis]
		set controlTime [getTime]
		
		while {$ok == 0 && $controlTime<$maxtime} {
					set ok [analyze 1 $DtAnalysis]
						if {$ok !=0} { 
							set Substep 2
							set DtAnalysis $Dtori
							while {$ok != 0 && $DtAnalysis >= $incrtol} { 
								puts "Trying Modified Newton"
								set DtAnalysis [expr $DtAnalysis/$Substep]
								algorithm ModifiedNewton -initial 
								set ok [analyze 1 $DtAnalysis]
								 	if {$ok==0} { 
										puts "DtAnalysis used was $DtAnalysis"	
										puts "algorithm works ... keeping this algorithm and going back to original dt"			
										puts "controlTime=[getTime] ... $GMfile ... maxtime is $maxtime"
										set DtAnalysis $Dtori
										puts "ok=$ok"}
								}
						}
						if {$ok !=0} { 
							set Substep 2
							set DtAnalysis $Dtori
							while {$ok != 0 && $DtAnalysis >=$incrtol} { 
								puts "Trying Broyden"
								set DtAnalysis [expr $DtAnalysis/$Substep]
								algorithm Broyden 10
								set ok [analyze 1 $DtAnalysis]
								 
									if {$ok==0} { 
										puts "DtAnalysis used was $DtAnalysis"	
										puts "algorithm works ... keeping this algorithm and going back to original dt"	
										puts "controlTime=[getTime] ... $GMfile ... maxtime is $maxtime"
										set DtAnalysis $Dtori }
								}
						}
						if {$ok !=0} { 
							set Substep 2
							set DtAnalysis $Dtori
							while {$ok != 0 && $DtAnalysis >=$incrtol} { 
								puts "Trying NewtonWithLineSearch"
								set DtAnalysis [expr $DtAnalysis/$Substep]
								algorithm NewtonLineSearch -type InitialInterpolation 
								set ok [analyze 1 $DtAnalysis]
								 
									if {$ok==0} { 
										puts "DtAnalysis used was $DtAnalysis"	
										puts "algorithm works ... keeping this algorithm and going back to original dt"	
										puts "controlTime=[getTime] ... $GMfile ... maxtime is $maxtime"
										set DtAnalysis $Dtori }
								}
						}
						if {$ok !=0} { 
							set Substep 2
							set DtAnalysis $Dtori
							while {$ok != 0 && $DtAnalysis >=$incrtol} { 
								puts "Trying BFGS"
								set DtAnalysis [expr $DtAnalysis/$Substep]
								algorithm BFGS 
								set ok [analyze 1 $DtAnalysis]
								 
									if {$ok==0} { 
										puts "DtAnalysis used was $DtAnalysis"	
										puts "algorithm works ... keeping this algorithm and going back to original dt"	
										puts "controlTime=[getTime] ... $GMfile ... maxtime is $maxtime"
										set DtAnalysis $Dtori }
								}
						}
						if {$ok !=0} { 
							set Substep 2
							set DtAnalysis $Dtori
							while {$ok != 0 && $DtAnalysis >=$incrtol} { 
								puts "Trying Newton -initial"
								set DtAnalysis [expr $DtAnalysis/$Substep]
								algorithm Newton -initial   
								set ok [analyze 1 $DtAnalysis]
								 
									if {$ok==0} { 
										puts "DtAnalysis used was $DtAnalysis"	
										puts "algorithm works ... keeping this algorithm and going back to original dt"	
										puts "controlTime=[getTime] ... $GMfile ... maxtime is $maxtime"
										set DtAnalysis $Dtori }
								}
						}
					
						if {$ok !=0} { 
							set Substep 2
							set DtAnalysis $Dtori
							while {$ok != 0 && $DtAnalysis >=$incrtol} { 
								puts "Trying KrylovNewton -initial"
								set DtAnalysis [expr $DtAnalysis/$Substep]
								algorithm KrylovNewton -initial 
								set ok [analyze 1 $DtAnalysis]
								 
									if {$ok==0} { 
									 puts "DtAnalysis used was $DtAnalysis"	
										puts "algorithm works ... keeping this algorithm and going back to original dt"	
										puts "controlTime=[getTime] ... $GMfile ... maxtime is $maxtime"
										set DtAnalysis $Dtori }
								}
						}
						#puts "ok=$ok"
						
						set controlTime [getTime]
						# Check Drifts to stop analysis 
						if {$ok == 0 } { 
							set stopFlag [CheckDrift $FolderModel $resDir1 $fnodes_dyn $IDA_SF $GMfile]
							
							if {$stopFlag == 1 } {
								puts "stopFlag is 1 and the analysis is going to be performed again to check convergence"
								
								#file delete -force ${GMfile}_temp_$IDA_SF
								set stopFlag [ReRunDynamicAnalysis $GMfile $Scalefact $IDA_SF $FolderAnalysis $FolderModel $ChooseAnalysis]
								puts "stopflag after performing nonlinear dynamic analysis for the second time is stopFlag=$stopFlag"
								
							} 
							if {$stopFlag == 2} {
								puts "stopFlag is 2 but the analysis is going to be performed again to check convergence"
								
								#file delete -force ${GMfile}_temp_$IDA_SF
								set stopFlag [ReRunDynamicAnalysis $GMfile $Scalefact $IDA_SF $FolderAnalysis $FolderModel $ChooseAnalysis]
								puts "stopflag after performing nonlinear dynamic analysis for the third time time is stopFlag=$stopFlag"
							} 
							
							if {$stopFlag == 2} {
								puts "Interstory drift larger than 10% and analysis was performed twice, analysis is forced to stop"
								#file delete -force ${GMfile}_temp_$IDA_SF
								break
							}
							if {$stopFlag == 3} {
							puts "Ground Motion was analyzed twice and the convergence issues were solved"
								#file delete -force ${GMfile}_temp_$IDA_SF
								break
							}
						
						}
						
					
			}			


 if {$ok!=0} {
	puts "Dynamic Analysis does not converge at t=[getTime] ok=$ok"
 } else {
	puts "Dynamic Analysis Finished, duration: [getTime]"
 }
set Tend [clock clicks -milliseconds]
set durationAn  [expr ($Tend-$Tini)/1000]
puts "Ground Motion $GMfile was analyzed in: $durationAn seconds"
puts "....."


#file delete -force ${GMfile}_temp_$IDA_SF


wipe
wipeAnalysis
remove recorders


