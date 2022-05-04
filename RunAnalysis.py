import openseespy.opensees as op
import os

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



ChooseAnalysis="8"

 # Folder where analysis tools are located 
FolderAnalysis={C:\Users\Usuario\Dropbox\2022\OpenSeesAnalysisTools}
#set FolderAnalysis {C:\Users\Francisco Flores\Dropbox\2022\OpenSeesAnalysisTools}


 # Folder where Model to analyze is located
#set FolderModel	{C:\Users\Usuario\Dropbox\2022\Models\IM15_C1_B}      
#set FolderModel	{C:\Users\Usuario\Dropbox\2022\Models\2StoryExamploe}
#set FolderModel	{C:\Users\Usuario\Dropbox\2022\Models\6Story\6Story_5%Initial}   
#set FolderModel	{C:\Users\Usuario\Dropbox\2022\Models\6Story\6Story_5%Initial}
FolderModel={C:\Users\Usuario\Dropbox\2022\Models\5Story}

#set FolderModel	{C:\Users\Francisco Flores\Dropbox\2022\Models\IM15_C1_B}      
#set FolderModel	{C:\Users\Francisco Flores\Dropbox\2022\Models\IM15_C1_B_Original}
#set FolderModel	{C:\Users\Francisco Flores\Dropbox\2022\Models\2StoryExample} 
#set FolderModel	{C:\Users\Francisco Flores\Dropbox\2022\Models\6Story} 

if hooseAnalysis==1:

	# ################################################ 
	# ####MODAL ANALYSIS         #####################
	# #### AMERICAN WOOD COUNCIL #####################
	# ################################################ 
	# This analysis computes modes and periods of vibration with or without P-Delta 

	# Number of modes and frequencies to comnpute                                                                                    
Nmodes=5
numeigs=5
	# Compute Frequencies and Modes including P-Delta effects                                                    
op.set('IncPD','Y','','#','Options','Y','or','N')

	#Perform Analysis 
exec(open('FolderAnalysis\\1_ModalAnalysis\\RunModal.py').read())
print("\nModal Analysis Done" )
print("\nResults located in $FolderModel" )

op.}('elseif','ChooseAnalysis','==','2')

	# ############################################## 
	# ####STATIC ANALYSIS       #################### 
	# #### AMERICAN WOOD COUNCIL ###################
	# ##############################################  
	# This analysis is used to check equilibrium and that the loads 
	# are applied correctly 
	# Results are shown in screen and printed in a file 
	# Stiffness Matrix and model info are computed 

op.set('NodeSupports','[list',111,'211]')

	#Perform Analysis 
exec(open('FolderAnalysis\\2_StaticAnalysis\\RunGravity.py').read())
print("\nStiffness matrix printed in folder" )
print("\nModel Info printed in folder" )
print("\nStatic Analysis Done" )
print("\nResults located in $FolderModel" )

op.}('elseif','ChooseAnalysis','==','3')

	# ############################################## 
	# ####INHERENT DAMPING, FREE VIBRATION########## 
	# #### AMERICAN WOOD COUNCIL ###################
	# ############################################## 
print("Performing Free Vibration Analysis" )

	# Frequencies to compute in order  to assign Rayleigh damping 
op.set('modeInhDamp','[list',1,2,3,'4]','#','Mode','to','check','inherent','damping')

	# Choose between Rayleigh o Modal 
Damping="Rayleigh"
op.set('RayleighStiffness','"Current"','','#Options','are:','Initial','or','Current')


	# Analysis Duration 
op.set('tini','0','#','Beginning')
op.set('tend','[list',5.0,2.5,1.0,'1.0]','#','End','for','each','mode','number','of','tend','must','be','the','same','as','modeInhDamp')

	# Time step for each free vibration analysis
op.set('dt','[list',0.01,0.01,0.01,0.01,']')

	#Perform Analysis 
exec(open('FolderAnalysis\\3_FreeVibration\\RunFV.py').read())
print("\nResults located in $FolderModel" )




op.}('elseif','ChooseAnalysis','==','4')
	# ############################################## 
	# #### PUSHOVER ANALYSIS     ################### 
	# #### AMERICAN WOOD COUNCIL ###################
	# ############################################## 

print("\nPerforming Pushover Analysis" )

	# Including P-Delta                                                    
op.set('IncPD','Y','','#','Options','Y','or','N')

	# Mode Shape to apply (Normally 1st mode)  
mode=1

	# Ultimate Roof Drift: Structure will be laterally pushed up to this point 
op.set('Drift_u',5.0,'','#','Introduce','number','in','percentage')

	# Displacement Increment (File size and convergence depend on this parameter)  
Dincr=0.001


	#Perform Analysis 
exec(open('FolderAnalysis\\4_PushoverAnalysis\\RunPushover.py').read())
print("\nResults located in $FolderModel" )



op.}('elseif','ChooseAnalysis','==','5')

	# ############################################## 
	# #### CYCLIC PUSHOVER ANALYSIS      ########### 
	# #### AMERICAN WOOD COUNCIL ###################
	# ##############################################

print("\nPerforming Cyclic Pushover Analysis using CUREE Protocol" )

	# Including P-Delta                                                    
op.set('IncPD','Y','','#','Options','Y','or','N')

	# Mode Shape to apply (Normally 1st mode)  
mode=1

	# Displacement Increment (File size and convergence depend on this parameter)  
Dincr=0.0001

	# Reference Deformation (Check File: Reference Deformation from Pushover Analysis Results) 
exec(open('Folder\\Res_Pushover\\RefDef.py').read())

	#Perform Analysis 
exec(open('FolderAnalysis\\5_CyclicPushover\\RunCyclicPushover.py').read())
print("\nResults located in $Folder" )


op.}('elseif','ChooseAnalysis','==','6')
	# ##################################################### 
	# #### NONLINEAR TIME HISTORY ANALYSIS      ########### 
	# #### AMERICAN WOOD COUNCIL ##########################
	# #####################################################
print("\nPerforming Nonlinear Time History Analysis" )
	# Compute Frequencies and Modes including P-Delta effects                                                    
op.set('IncPD','Y','','#','Options','Y','or','N')

	# Choose Ground Motion from the Far Field Set: Format AT2 	
op.set('Choose','"FarField"','#','Choose','between','"FarField"','or','"NearField"')

	# Ground Motion File and Scale factor, it can be typed or you can choose from the GM_SF.tcl list 
	#set GMfile "ABBAR--T.AT2"
	#set Scalefact 1.58;  # Ground Motion Scaling Factor  

	# Taking Ground Motions and Scale Factors 
	# Check the number of the ground motion in the file GM_SF.tcl
exec(open('FolderModel\\GM_SF.py').read())
GMfile=gmfiles[12]
Scalefact=SF[12]

	# Analysis  
g=386.4
op.set('IDA_SF',1.0,'','#','IDA','scale','factor')

	# Frequencies to compute in order  to assign Rayleigh damping 
numeigs=6
Nmodes=6

	# Choose between Rayleigh o Modal 
Damping="Rayleigh"
op.set('RayleighStiffness','"Current"','','#Options','are:','Initial','or','Current')


	##################################################
	#Perform Analysis 
print("Analyzing GM=$GMfile IDA_SF=$IDA_SF" )
exec(open('FolderAnalysis\\6_NTHAnalysis\\RunDynamic.py').read())


op.}('elseif','ChooseAnalysis','==','7')
	# #############################################################  
	# #### INCREMENTAL NONLINEAR DYNAMIC ANALYSIS (SERIES)  ####### 
	# #### AMERICAN WOOD COUNCIL ##################################
	# #############################################################
print("\nPerforming Incremental Dynamic Analysis" )

	# Compute Frequencies and Modes including P-Delta effects                                                    
op.set('IncPD','Y','','#','Options','Y','or','N')

	# Choose Ground Motion from the Far Field Set: Format AT2 
op.set('Choose','"FarField"','#','Choose','between','"FarField"','or','"NearField"')
	# Analysis  
g=386.4

	# Frequencies to compute in order  to assign Rayleigh damping 
op.set('numeigs',3,'#','Frequencies','to','compute','and','assign','Rayleigh','damping')
Nmodes=3

	# Choose between Rayleigh o Modal 
Damping="Rayleigh"
op.set('RayleighStiffness','"Current"','','#Options','are:','Initial','or','Current')


	##################################################
	#Perform Analysis 

	# All Ground Motions
exec(open('FolderModel\\GM_SF.py').read())

	# Espe

	# IDA SCALE FACTORS 
op.set('IDAsf','[list',3.3,3.4,3.5,3.6,'3.7]')

	# Analysis Begin 
op.set('Tini2','[clock','clicks','-milliseconds]','#','timing','the','analysis')
C_Load=1000
	# Performing analysis for each ground motion scale factor 
for IDA_SF in IDAsf:
for GMfile in gmfiles:
print("Analyzing GM=$GMfile IDA_SF=$IDA_SF" )
op.incr('C_Load')
exec(open('FolderAnalysis\\6_NTHAnalysis\\RunDynamic.py').read())
op.set('Tend2','[clock','clicks','-milliseconds]')
durationAn2=(Tend2-Tini2)/1000
print(" " )
print(" " )
print("The analysis was done in: $durationAn2 seconds" )
	#remove recorders 

op.}('elseif','ChooseAnalysis','==','8')
	# ###############################################################  
	# #### INCREMENTAL NONLINEAR DYNAMIC ANALYSIS (PARALLEL)  ####### 
	# #### AMERICAN WOOD COUNCIL ####################################
	# ###############################################################
	# Code created by: Silvia Mazzoni 
	# Modified by: Francisco Flores 
	# Taken from the video: Optimizing Parametric Analyses via Parallelization in OpenSees
	# https://youtu.be/19U8lwpk2wM
print("\nPerforming Incremental Dynamic Analysis" )
	##################################################
	#Perform Analysis 

op.set('OpenSeesPath','C:\Program','Files\Tcl\bin\OpenSees')


op.proc('checkPID','thisPID')
op.set('taskList','[exec','cmd.exe','/c','tasklist','/FI','"PID','eq','thisPID"','/NH]','#','Looking','for','PID')
if hisPIDintaskList:

resDir="IDAParallelOutput"
os.mkdir(f'$FolderModel/$resDir')

	# IDA SCALE FACTORS
	#set IDAsf [list 0.5 0.75 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
op.set('IDAsf','[list',2.1,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,3.0,3.1,3.2,'3.3]')
	#set IDAsf [list 4.00 4.10 4.20 4.30 4.40 4.50]
	#set IDAsf [list 3.50 3.60 3.70 3.80 3.90]	

	# MAXIMUM NUMBER OF SYMULTANEOUS PROCESSES 
op.set('NsymMax',4,'','#','total','number','of','symultaneous','runs')

	# PIDlist is used to check if analyses are done and finished 
PIDlist=""
op.set('N_IDAsf',0,'','#','Starting','to','count','IDA','scale','factors')

	# Taking Ground Motions and Scale Factors 	
exec(open('FolderModel\\GM_SF_2.py').read())

	# Analysis Begin 
op.set('Tini','[clock','clicks','-milliseconds]')

op.while('N_IDAsf','<','[llength','IDAsf]')
IDA_SF=IDAsf[N_IDAsf]
GMnumber=0
CountJF=0
op.while('GMnumber','<','[llength','gmfiles]')
if llength$PIDlist]<:
GMfile=gmfiles[GMnumber]
Scalefact=SF[GMnumber]
op.set('LengthString','[string','length','GMfile]')
op.set('GM_Name','[string','range','GMfile',0,'[expr','LengthString-5]]')

op.set('thisPID','[exec','OpenSeesPath','FolderAnalysis\\6_NTHAnalysis\\RunDynamic.tcl','\','"GMfile"','\','"Scalefact"','\','"IDA_SF"','\','"FolderAnalysis"','\','"FolderModel"','\','"ChooseAnalysis"','>&','FolderModel\\resDir\\tt_GMfile_IDA_SF.out','&]')
print("Analyzing GM=$GMfile IDA_SF=$IDA_SF in $thisPID" )
op.incr('GMnumber')
PIDlist.append(thisPID)
for runningJobPID in PIDlist:
op.set('thisCheck','[checkPID','runningJobPID]')
if thisCheck<1:
op.incr('CountJF')
print("Job $runningJobPID finished, jobs done ${CountJF}/[llength $gmfiles]" )
op.set('idx','[lsearch','PIDlist','runningJobPID]','#find','index')
op.set('PIDlist','[lreplace','PIDlist','idx','idx]','#','remove','vale','from','list')
op.incr('N_IDAsf')
op.set('Tend','[clock','clicks','-milliseconds]')
durationAn=(Tend-Tini)/1000

print(" " )
print(" " )
print("The analysis was done in: $durationAn seconds" )

op.}('elseif','ChooseAnalysis','==','9')
	# ###############################################################  
	# #### CMR --> EVALUATES COLLAPSES UP TO 22 OUT 44 ############## 
	# #### INCREMENTAL NONLINEAR DYNAMIC ANALYSIS (PARALLEL)  ####### 
	# #### AMERICAN WOOD COUNCIL ####################################
	# ###############################################################
	# Code created by: Silvia Mazzoni 
	# Modified by: Francisco Flores 
	# Taken from the video: Optimizing Parametric Analyses via Parallelization in OpenSees
	# https://youtu.be/19U8lwpk2wM
op.proc('checkPID','thisPID')
op.set('taskList','[exec','cmd.exe','/c','tasklist','/FI','"PID','eq','thisPID"','/NH]','#','Looking','for','PID')
if hisPIDintaskList:

curpath=[pwd]
print("\nPerforming Incremental Dynamic Analysis" )
	##################################################
	#Perform Analysis 

op.set('OpenSeesPath','C:\Program','Files\Tcl\bin\OpenSees')

resDir="9_IDA_CMR_Output"
os.mkdir(f'$FolderModel/$resDir')

	# IDA SCALE FACTORS
op.set('IDAsf','[list',0.50,0.60,0.75,0.80,0.90,1.00,1.10,1.20,1.30,1.40,1.50,1.60,1.70,1.80,1.90,2.00,2.10,2.20,2.30,2.40,2.50,2.60,2.70,2.80,2.90,'3.00]')
	#set IDAsf [list 1.5]
	# MAXIMUM NUMBER OF SYMULTANEOUS PROCESSES 
op.set('NsymMax',6,'','#','total','number','of','symultaneous','runs')


PIDlist=""
op.set('N_IDAsf',0,'','#','Starting','to','count','IDA','scale','factors')

	# Taking Ground Motions and Scale Factors 
exec(open('FolderModel\\GM_SF.py').read())

#12
#[llength $gmfiles]
	# Analysis Begin 
op.set('Tini','[clock','clicks','-milliseconds]')

op.while('N_IDAsf','<','[llength','IDAsf]')
IDA_SF=IDAsf[N_IDAsf]
GMnumber=0
CountJF=0
op.while('GMnumber','<','[llength','gmfiles]')
if llength$PIDlist]<:
GMfile=gmfiles[GMnumber]
Scalefact=SF[GMnumber]
op.set('LengthString','[string','length','GMfile]')
op.set('GM_Name','[string','range','GMfile',0,'[expr','LengthString-5]]')
				#puts "${GM_Name}Flag= [subst $\{${GM_Name}Flag\}]"

if subst$\{${GM_Name}Flag\}]==:

op.set('thisPID','[exec','OpenSeesPath','FolderAnalysis\\6_NTHAnalysis\\RunDynamic.tcl','\','"GMfile"','\','"Scalefact"','\','"IDA_SF"','\','"FolderAnalysis"','\','"FolderModel"','\','"ChooseAnalysis"','>&','FolderModel\\resDir\\tt_GMfile_IDA_SF.out','&]')
print("Analyzing GM=$GMfile IDA_SF=$IDA_SF in $thisPID" )
PIDlist.append(thisPID)
else:
print("${GM_Name} already caused the collapse of the structure" )
op.incr('GMnumber')
for runningJobPID in PIDlist:
op.set('thisCheck','[checkPID','runningJobPID]')
if hisCheck!=1}:
op.incr('CountJF')
print("Job $runningJobPID finished, jobs done ${CountJF}/[llength $gmfiles]" )
op.set('idx','[lsearch','PIDlist','runningJobPID]','','#find','index')
op.set('PIDlist','[lreplace','PIDlist','idx','idx]','','#','remove','vale','from','list+')
print("FInishing all the analyses" ;# This procedure is to make sure all 44 ground motions are finished before the next IDA scale factor starts )
op.while('[llength','PIDlist]','!=','0')
for runningJobPID in PIDlist:
op.set('thisCheck','[checkPID','runningJobPID]')
if hisCheck!=1:
op.incr('CountJF')
print("Job $runningJobPID finished, jobs done ${CountJF}/[llength $gmfiles]" )
op.set('idx','[lsearch','PIDlist','runningJobPID]','','#find','index')
op.set('PIDlist','[lreplace','PIDlist','idx','idx]','','#','remove','vale','from','list')
print($PIDlist )


op.cd('FolderModel\\9_CMR_Parallel')
print("Checking Collapses" )
if fileisdirectoryCollapses]:
op.cd('Collapses')
op.set('Collapsefiles','[glob','"*.out"]')
op.set('Ncollapses','[llength','Collapsefiles]')

fname="CollapsesFlags.tcl"
op.set('fidwrite','[open','FolderModel/9_CMR_Parallel/fname','w]','','#','Open','file','and','writes','at','the','end')

fname2="IDA_Factors.out"
op.set('fidwrite2','[open','FolderModel/9_CMR_Parallel/fname2','w]','','#','Open','file','and','writes','at','the','end')

for CF in Collapsefiles:
print($CF )
exec(open('py').read())
print($fidwrite "set ${GMcollapse}Flag 1" ; #1 means collapse )
print($fidwrite2 "${GMcollapse} ${IDAcollapse} " ; )
op.close('fidwrite')
op.close('fidwrite2')
op.cd('..')

print("check flags" )
if fileexistsCollapsesFlags.tcl]:
exec(open('FolderModel\\9_CMR_Parallel\\CollapsesFlags.py').read())
op.cd('curpath')
op.incr('N_IDAsf')
op.set('Tend','[clock','clicks','-milliseconds]')
durationAn=(Tend-Tini)/1000

print(" " )
print(" " )
print("The analysis was done in: $durationAn seconds" )

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



