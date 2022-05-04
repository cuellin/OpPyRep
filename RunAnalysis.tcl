# ############################################## 
# ####RunAnalysis.out       #################### 
# ####AMERICAN WOOD COUNCIL #################### 
# ############################################## 
# File to perform directly the chosen analysis
# Choose one of the following analysis
# "1" --> Modal Analysis
# "2" --> Static Analysis
# "3" --> Free Vibration (Inherent Damping) 
# "4" --> Pushover Analysis
# "5" --> Cyclic Pushover
# "6" --> Nonlinear Time History Analysis 
# "7" --> Incremental Dynamic Analysis (Series) 
# "8" --> Incremental Dynamic Analysis (Parallel) 
# "9" --> CMR (Parallel) --> Does not work adequately yet 


 
set ChooseAnalysis "8"

 # Folder where analysis tools are located 
set FolderAnalysis {C:\Users\Usuario\Dropbox\2022\OpenSeesAnalysisTools}
#set FolderAnalysis {C:\Users\Francisco Flores\Dropbox\2022\OpenSeesAnalysisTools}

 
 # Folder where Model to analyze is located
#set FolderModel	{C:\Users\Usuario\Dropbox\2022\Models\IM15_C1_B}      
#set FolderModel	{C:\Users\Usuario\Dropbox\2022\Models\2StoryExamploe}
#set FolderModel	{C:\Users\Usuario\Dropbox\2022\Models\6Story\6Story_5%Initial}   
#set FolderModel	{C:\Users\Usuario\Dropbox\2022\Models\6Story\6Story_5%Initial}
set FolderModel	{C:\Users\Usuario\Dropbox\2022\Models\5Story} 

#set FolderModel	{C:\Users\Francisco Flores\Dropbox\2022\Models\IM15_C1_B}      
#set FolderModel	{C:\Users\Francisco Flores\Dropbox\2022\Models\IM15_C1_B_Original}
#set FolderModel	{C:\Users\Francisco Flores\Dropbox\2022\Models\2StoryExample} 
#set FolderModel	{C:\Users\Francisco Flores\Dropbox\2022\Models\6Story} 

if {$ChooseAnalysis == 1} { 

	# ################################################ 
	# ####MODAL ANALYSIS         #####################
	# #### AMERICAN WOOD COUNCIL #####################
	# ################################################ 
	# This analysis computes modes and periods of vibration with or without P-Delta 

	# Number of modes and frequencies to comnpute                                                                                    
	set Nmodes	5                                                                                                                            
	set numeigs	5                               
	# Compute Frequencies and Modes including P-Delta effects                                                    
	set IncPD	Y   ; # Options Y or N 
	
	#Perform Analysis 
	source  $FolderAnalysis\\1_ModalAnalysis\\RunModal.tcl
	puts "\nModal Analysis Done"
	puts "\nResults located in $FolderModel"
	
} elseif {$ChooseAnalysis == 2} { 

	# ############################################## 
	# ####STATIC ANALYSIS       #################### 
	# #### AMERICAN WOOD COUNCIL ###################
	# ##############################################  
	# This analysis is used to check equilibrium and that the loads 
	# are applied correctly 
	# Results are shown in screen and printed in a file 
	# Stiffness Matrix and model info are computed 
	
	set NodeSupports [list 111 211]
	
	#Perform Analysis 
	source  $FolderAnalysis\\2_StaticAnalysis\\RunGravity.tcl
	puts "\nStiffness matrix printed in folder"
	puts "\nModel Info printed in folder"		
	puts "\nStatic Analysis Done"
	puts "\nResults located in $FolderModel"

} elseif {$ChooseAnalysis == 3} { 

	# ############################################## 
	# ####INHERENT DAMPING, FREE VIBRATION########## 
	# #### AMERICAN WOOD COUNCIL ###################
	# ############################################## 
	puts "Performing Free Vibration Analysis"
	
	# Frequencies to compute in order  to assign Rayleigh damping 
	set modeInhDamp [list 1 2 3 4]; # Mode to check inherent damping
	
	# Choose between Rayleigh o Modal 
	set Damping "Rayleigh"
	set RayleighStiffness "Current" ; #Options are: Initial or Current


	# Analysis Duration 
	set tini 0; # Beginning 
	set tend [list 5.0 2.5 1.0  1.0]; # End for each mode number of tend must be the same as modeInhDamp
	
	# Time step for each free vibration analysis
	set dt [list 0.01 0.01 0.01 0.01 ]     

	#Perform Analysis 
	source  $FolderAnalysis\\3_FreeVibration\\RunFV.tcl
	puts "\nResults located in $FolderModel"




} elseif {$ChooseAnalysis == 4} {
	# ############################################## 
	# #### PUSHOVER ANALYSIS     ################### 
	# #### AMERICAN WOOD COUNCIL ###################
	# ############################################## 
	
	puts "\nPerforming Pushover Analysis"
		
	# Including P-Delta                                                    
	set IncPD	Y  ; # Options Y or N 
		
	# Mode Shape to apply (Normally 1st mode)  
	set mode 1 
	
	# Ultimate Roof Drift: Structure will be laterally pushed up to this point 
	set Drift_u 5.0 ; # Introduce number in percentage 
	
	# Displacement Increment (File size and convergence depend on this parameter)  
	set Dincr 0.001 
	
		
	#Perform Analysis 
	source  $FolderAnalysis\\4_PushoverAnalysis\\RunPushover.tcl
	puts "\nResults located in $FolderModel"

	

} elseif {$ChooseAnalysis == 5} {

	# ############################################## 
	# #### CYCLIC PUSHOVER ANALYSIS      ########### 
	# #### AMERICAN WOOD COUNCIL ###################
	# ##############################################

	puts "\nPerforming Cyclic Pushover Analysis using CUREE Protocol"
	
	# Including P-Delta                                                    
	set IncPD	Y  ; # Options Y or N 
	
	# Mode Shape to apply (Normally 1st mode)  
	set mode 1
	
	# Displacement Increment (File size and convergence depend on this parameter)  
	set Dincr 0.0001 
	
	# Reference Deformation (Check File: Reference Deformation from Pushover Analysis Results) 
	source  $Folder\\Res_Pushover\\RefDef.out
		
	#Perform Analysis 
	source  $FolderAnalysis\\5_CyclicPushover\\RunCyclicPushover.tcl
	puts "\nResults located in $Folder"
	

} elseif {$ChooseAnalysis == 6} {
	# ##################################################### 
	# #### NONLINEAR TIME HISTORY ANALYSIS      ########### 
	# #### AMERICAN WOOD COUNCIL ##########################
	# #####################################################
	puts "\nPerforming Nonlinear Time History Analysis"
	# Compute Frequencies and Modes including P-Delta effects                                                    
	set IncPD	Y   ; # Options Y or N 	
	
	# Choose Ground Motion from the Far Field Set: Format AT2 	
	set Choose "FarField"; # Choose between "FarField" or "NearField" 
	
	# Ground Motion File and Scale factor, it can be typed or you can choose from the GM_SF.tcl list 
	#set GMfile "ABBAR--T.AT2"
	#set Scalefact 1.58;  # Ground Motion Scaling Factor  
	
	# Taking Ground Motions and Scale Factors 
	# Check the number of the ground motion in the file GM_SF.tcl
	source  $FolderModel\\GM_SF.tcl	
	set GMfile 		[lindex $gmfiles 12]
	set Scalefact 	[lindex $SF 12]
	
	# Analysis  
	set g 386.4
	set IDA_SF    1.0 ;  # IDA scale factor  
	
	# Frequencies to compute in order  to assign Rayleigh damping 
	set numeigs 6 
	set Nmodes	6 
	
	# Choose between Rayleigh o Modal 
	set Damping "Rayleigh"
	set RayleighStiffness "Current" ; #Options are: Initial or Current

	
	##################################################
	#Perform Analysis 
	puts "Analyzing GM=$GMfile IDA_SF=$IDA_SF"
	source  $FolderAnalysis\\6_NTHAnalysis\\RunDynamic.tcl


} elseif {$ChooseAnalysis == 7} {
	# #############################################################  
	# #### INCREMENTAL NONLINEAR DYNAMIC ANALYSIS (SERIES)  ####### 
	# #### AMERICAN WOOD COUNCIL ##################################
	# #############################################################
	puts "\nPerforming Incremental Dynamic Analysis"
	
	# Compute Frequencies and Modes including P-Delta effects                                                    
	set IncPD	Y   ; # Options Y or N 	
	
	# Choose Ground Motion from the Far Field Set: Format AT2 
	set Choose "FarField"; # Choose between "FarField" or "NearField"
	# Analysis  
	set g 386.4
	
	# Frequencies to compute in order  to assign Rayleigh damping 
	set numeigs 3 ;# Frequencies to compute and assign Rayleigh damping 
	set Nmodes	3 
	
	# Choose between Rayleigh o Modal 
	set Damping "Rayleigh"
	set RayleighStiffness "Current" ; #Options are: Initial or Current

	
	##################################################
	#Perform Analysis 
	
	# All Ground Motions
	source  $FolderModel\\GM_SF.tcl ;# This file could be reeplaced for specific ground motions that need to be analyzed 

	# Espe
	
	# IDA SCALE FACTORS 
	set IDAsf [list 3.3 3.4 3.5 3.6 3.7]
	
	# Analysis Begin 
	set Tini2 [clock clicks -milliseconds]	;# timing the analysis 
	set C_Load 1000
	# Performing analysis for each ground motion scale factor 
	foreach IDA_SF $IDAsf {
		foreach GMfile $gmfiles Scalefact $SF {	
			puts "Analyzing GM=$GMfile IDA_SF=$IDA_SF"
			incr C_Load
			source  $FolderAnalysis\\6_NTHAnalysis\\RunDynamic.tcl
		}
	}
	set Tend2 [clock clicks -milliseconds]
	set durationAn2  [expr ($Tend2-$Tini2)/1000]
	puts " "
	puts " "
	puts "The analysis was done in: $durationAn2 seconds"
	#remove recorders 
	
} elseif {$ChooseAnalysis == 8} {
	# ###############################################################  
	# #### INCREMENTAL NONLINEAR DYNAMIC ANALYSIS (PARALLEL)  ####### 
	# #### AMERICAN WOOD COUNCIL ####################################
	# ###############################################################
	# Code created by: Silvia Mazzoni 
	# Modified by: Francisco Flores 
	# Taken from the video: Optimizing Parametric Analyses via Parallelization in OpenSees
	# https://youtu.be/19U8lwpk2wM
	puts "\nPerforming Incremental Dynamic Analysis"
	##################################################
	#Perform Analysis 
  
	set OpenSeesPath {C:\Program Files\Tcl\bin\OpenSees} 


	proc checkPID {thisPID} {
		set taskList [exec cmd.exe /c tasklist /FI "PID eq $thisPID" /NH] ;# Looking for PID 
		if {$thisPID in $taskList} {return 1}	
	}

	set resDir  "IDAParallelOutput"
	file mkdir $FolderModel/$resDir

	# IDA SCALE FACTORS
	#set IDAsf [list 0.5 0.75 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
	set IDAsf [list 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3]
	#set IDAsf [list 4.00 4.10 4.20 4.30 4.40 4.50]
	#set IDAsf [list 3.50 3.60 3.70 3.80 3.90]	

	# MAXIMUM NUMBER OF SYMULTANEOUS PROCESSES 
	set NsymMax 4 ; # total number of symultaneous runs
	
	# PIDlist is used to check if analyses are done and finished 
	set PIDlist ""
	set N_IDAsf 0 ; # Starting to count IDA scale factors 

	# Taking Ground Motions and Scale Factors 	
	source  $FolderModel\\GM_SF_2.tcl	
	
	# Analysis Begin 
	set Tini [clock clicks -milliseconds]

	while {$N_IDAsf < [llength $IDAsf]} {	
		set IDA_SF [lindex $IDAsf $N_IDAsf]
		set GMnumber 0 		
		set CountJF  0
		while {$GMnumber < [llength $gmfiles]} {
			if {[llength $PIDlist] < $NsymMax } {
				set GMfile     [lindex $gmfiles $GMnumber]
				set Scalefact  [lindex $SF      $GMnumber]
				set LengthString [string length $GMfile]
				set GM_Name [string range $GMfile 0 [expr $LengthString-5]]		
				
				set thisPID [exec $OpenSeesPath $FolderAnalysis\\6_NTHAnalysis\\RunDynamic.tcl \ "$GMfile" \ "$Scalefact" \ "$IDA_SF" \ "$FolderAnalysis" \ "$FolderModel" \ "$ChooseAnalysis" >& $FolderModel\\$resDir\\tt_${GMfile}_${IDA_SF}.out &]
				puts "Analyzing GM=$GMfile IDA_SF=$IDA_SF in $thisPID"
				incr GMnumber
				lappend PIDlist $thisPID
			}
			foreach runningJobPID $PIDlist {
				set thisCheck [checkPID $runningJobPID] 
					if {$thisCheck<1} {
						incr CountJF
						puts "Job $runningJobPID finished, jobs done ${CountJF}/[llength $gmfiles]"
						set idx [lsearch $PIDlist $runningJobPID]; #find index
						set PIDlist [lreplace $PIDlist $idx $idx]; # remove vale from list
					}
			}
		}
		incr N_IDAsf	
	}		
	set Tend [clock clicks -milliseconds]
	set durationAn  [expr ($Tend-$Tini)/1000]

	puts " "
	puts " "
	puts "The analysis was done in: $durationAn seconds"

} elseif {$ChooseAnalysis == 9} {
	# ###############################################################  
	# #### CMR --> EVALUATES COLLAPSES UP TO 22 OUT 44 ############## 
	# #### INCREMENTAL NONLINEAR DYNAMIC ANALYSIS (PARALLEL)  ####### 
	# #### AMERICAN WOOD COUNCIL ####################################
	# ###############################################################
	# Code created by: Silvia Mazzoni 
	# Modified by: Francisco Flores 
	# Taken from the video: Optimizing Parametric Analyses via Parallelization in OpenSees
	# https://youtu.be/19U8lwpk2wM
	proc checkPID {thisPID} {
		set taskList [exec cmd.exe /c tasklist /FI "PID eq $thisPID" /NH] ;# Looking for PID 
		if {$thisPID in $taskList} {return 1}	
	}
	
	set curpath [pwd]
	puts "\nPerforming Incremental Dynamic Analysis"
	##################################################
	#Perform Analysis 
  
	set OpenSeesPath {C:\Program Files\Tcl\bin\OpenSees} 

	set resDir  "9_IDA_CMR_Output"
	file mkdir $FolderModel/$resDir

	# IDA SCALE FACTORS
	set IDAsf [list  0.50 0.60 0.75 0.80 0.90 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00 2.10 2.20 2.30 2.40 2.50 2.60 2.70 2.80 2.90 3.00]
	#set IDAsf [list 1.5]
	# MAXIMUM NUMBER OF SYMULTANEOUS PROCESSES 
	set NsymMax 6 ; # total number of symultaneous runs
	
	
	set PIDlist ""
	set N_IDAsf 0 ; # Starting to count IDA scale factors 

	# Taking Ground Motions and Scale Factors 
		source  $FolderModel\\GM_SF.tcl	

#12
#[llength $gmfiles]
	# Analysis Begin 
	set Tini [clock clicks -milliseconds]

	while {$N_IDAsf < [llength $IDAsf]} {	
		set IDA_SF [lindex $IDAsf $N_IDAsf]
		set GMnumber 0 	
		set CountJF  0
		while {$GMnumber < [llength $gmfiles]} {												;# While the number of ground motions less than 44
			if {[llength $PIDlist] < $NsymMax } {								;# Number of simultaneous analyses has to be less than NsyMax
				set GMfile     [lindex $gmfiles $GMnumber]	
				set Scalefact  [lindex $SF      $GMnumber]
				set LengthString [string length $GMfile]
				set GM_Name [string range $GMfile 0 [expr $LengthString-5]]				
				#puts "${GM_Name}Flag= [subst $\{${GM_Name}Flag\}]"
				
				if {[subst $\{${GM_Name}Flag\}] == 0} {								;# Flag that turns 1 when a collapse occurs and the GM is not analized anymore 
					
					set thisPID [exec $OpenSeesPath $FolderAnalysis\\6_NTHAnalysis\\RunDynamic.tcl \ "$GMfile" \ "$Scalefact" \ "$IDA_SF" \ "$FolderAnalysis" \ "$FolderModel" \ "$ChooseAnalysis" >& $FolderModel\\$resDir\\tt_${GMfile}_${IDA_SF}.out &]
					puts "Analyzing GM=$GMfile IDA_SF=$IDA_SF in $thisPID"
					lappend PIDlist $thisPID
				} else {
					puts "${GM_Name} already caused the collapse of the structure"
				}
				incr GMnumber
			}
			foreach runningJobPID $PIDlist {									;#Eliminating from the PIDlist ended jobs so new ones can start. 
				set thisCheck [checkPID $runningJobPID] 
					if {$thisCheck !=1} {
						incr CountJF
						puts "Job $runningJobPID finished, jobs done ${CountJF}/[llength $gmfiles]"
						set idx [lsearch $PIDlist $runningJobPID]				; #find index
						set PIDlist [lreplace $PIDlist $idx $idx]			 	; # remove vale from list+
					}
			}			
		}
		puts "FInishing all the analyses"												;# This procedure is to make sure all 44 ground motions are finished before the next IDA scale factor starts 
		while {[llength $PIDlist] != 0} {
					foreach runningJobPID $PIDlist {
						set thisCheck [checkPID $runningJobPID] 
					if {$thisCheck != 1} {
						incr CountJF
						puts "Job $runningJobPID finished, jobs done ${CountJF}/[llength $gmfiles]"					
						set idx [lsearch $PIDlist $runningJobPID]					; #find index
						set PIDlist [lreplace $PIDlist $idx $idx]					; # remove vale from list
						puts $PIDlist
					}
			}
		}
		
		
		cd ${FolderModel}\\9_CMR_Parallel
				puts "Checking Collapses"
				if {[file isdirectory Collapses] ==1 } { 
				cd Collapses 
				set Collapsefiles [glob "*.out"]
				set Ncollapses [llength ${Collapsefiles}]
				
				set fname "CollapsesFlags.tcl"
				set fidwrite [open $FolderModel/9_CMR_Parallel/$fname w]  ;  # Open file and writes at the end 

				set fname2 "IDA_Factors.out"
				set fidwrite2 [open $FolderModel/9_CMR_Parallel/$fname2 w]  ;  # Open file and writes at the end 

				foreach CF $Collapsefiles {
					puts $CF
					source $CF
					puts $fidwrite "set ${GMcollapse}Flag 1" ; #1 means collapse 
					puts $fidwrite2 "${GMcollapse} ${IDAcollapse} " ;  
				}
				close $fidwrite
				close $fidwrite2
				cd ..
				}
						
		puts "check flags"
		if {[file exists CollapsesFlags.tcl] == 1 } { 
			source $FolderModel\\9_CMR_Parallel\\CollapsesFlags.tcl 
		} 
		cd $curpath
		incr N_IDAsf	
	}		
	set Tend [clock clicks -milliseconds]
	set durationAn  [expr ($Tend-$Tini)/1000]

	puts " "
	puts " "
	puts "The analysis was done in: $durationAn seconds"
} 

#0	MUL009.AT2
#1	MUL279.AT2
#2	LOS000.AT2
#3	LOS270.AT2
#4	BOL000.AT2
#5	BOL090.AT2
#6	HEC000.AT2
#7	HEC090.AT2
#8	H-DLT262.AT2
#9	H-DLT352.AT2
#10	H-E11140.AT2
#11	H-E11230.AT2
#12	NIS000.AT2
#13	NIS090.AT2
#14	SHI000.AT2
#15	SHI090.AT2
#16	DZC180.AT2
#17	DZC270.AT2
#18	ARC000.AT2
#19	ARC090.AT2
#20	YER270.AT2
#21	YER360.AT2
#22	CLW-LN.AT2
#23	CLW-TR.AT2
#24	CAP000.AT2
#25	CAP090.AT2
#26	G03000.AT2
#27	G03090.AT2
#28	ABBAR--L.AT2
#29	ABBAR--T.AT2
#30	B-ICC000.AT2
#31	B-ICC090.AT2
#32	B-POE270.AT2
#33	B-POE360.AT2
#34	RIO270.AT2
#35	RIO360.AT2
#36	CHY101-E.AT2
#37	CHY101-N.AT2
#38	TCU045-E.AT2
#39	TCU045-N.AT2
#40	PEL180.AT2
#41	PEL090.AT2
#42	A-TMZ000.AT2
#43	A-TMZ270.AT2

