import opensespy.opensees as op
import os

# ######################### 
# RunModal.tcl#############
# AMERICAN WOOD COUNCIL ####
# ##########################
# Main file to run Modal Analysis
op.wipe;#('This','command','is','used','to','destroy','all','constructed','objects,','i.e.','all','components','of','the','model,','all','components','of','the','analysis','and','all','recorders.')

#wipeAnalysis; # This command is used to destroy all components of the Analysis object, i.e. any objects created with system, numberer, constraints, integrator, algorithm, and analysis commands. 

# 1.Defining Model Dimensions and Number of DOF
op.model('basicBuilder','-ndm',2,'-ndf',3)

# 2.Geometry

exec(open('FolderModel\\Materials.py').read())
exec(open('FolderModel\\ModelGeometry.py').read())

# Including P-Delta Effects

if IncPD=="Y":
exec(open('FolderModel\\GravityLoads.py').read())
print("Gravity Loads Applied, PDelta Effects included" )
	# Steps to perform analysis 
	# 1.ConstraintHandler
op.constraints('Plain')
	# 2.DOF_Numberer
op.numberer('Plain')
	# 3.SystemOfEqn/Solver
op.system('BandGeneral')
	# 4.Convergence Test
op.test('EnergyIncr',1.e-006,1000,'')
	# 5.SolutionAlgorithm
op.algorithm('Newton')
	# 6 Integrator
	# Applies gravity load in N steps
op.integrator('LoadControl','0.1')
	# 7.Analysis
op.analysis('Static','')
	# Analize number of steps
op.analyze('10')
op.loadConst('-time',0.0)

# --Recorders----
if IncPD=="Y":
resDir="1_ModalResultsPD"
os.mkdir(f'$FolderModel/$resDir')
os.mkdir(f'$FolderModel/$resDir/Modes')
else:
resDir="1_ModalResults"
os.mkdir(f'$FolderModel/$resDir')
os.mkdir(f'$FolderModel/$resDir/Modes')



op.for('set','x','1','x<=Nmodes','incr','x','1')
op.recorder('Node','-file','FolderModel/resDir/Modes/Modex.out','-nodeRange',1,1000000,'-dof',1,2,'"eigen','x"')
#puts "recorder Node -file $FolderModel/$resDir/Modes/Mode$x.out -nodeRange 1 1000000 -dof 1 2 {eigen $x}"

# Performing Modal Analysis

# Computing frequencies 
lambda=op.eigen('-fullGenLapack',numeigs)

pi=3.1415926535897931

for lam in lambda:
freq.append(sqrt(lam))
period.append(2*pi/sqrt(lam))

nd=[getNodeTags]

# Modal Mass Participation Factor in x direction 
op.for('set','x','1','x<=Nmodes','incr','x','1')
Mn=0.0
Ln=0.0
for node in nd:
op.set('ndMass','[nodeMass','node','1]')
op.set('ndEigen','[nodeEigenvector','node','x','1]')
Ln=L
Mn=M
Gamma.append(Ln/Mn)
meff.append(pow([exp)



# Saving frequencies in file 
op.set('fid','[open','FolderModel/resDir/Natural_Frequencies.out','w]','#','Opens','file','to','write','results')
print($fid "Natural Frequencies (rad/seg)" )
print($fid $freq )
print($fid "\nPeriods (seg)" )
print($fid $period )
print($fid "\nMass Participation Factors" )
print($fid $meff )
op.close('fid')






# Printing Node Coordinates and Connectivity matrix to post process results 
fnodes=[getNodeTags]
fname="NodeCoordinates.txt"
op.set('fidwrite','[open','FolderModel/resDir/fname','w]','','#','Open','file')
for tag in fnodes:
print($fidwrite "$tag [nodeCoord $tag]" ; # Print Nodal Coordinates to File )
op.}('','#','end','foreach','tag')
op.close('fidwrite','','#','Close','file')

op.set('ElementTags','[getEleTags]','','#','Retrieve','Element','Tags')
fname2="ConnectivityMatrix.txt"
op.set('fidwrite','[open','FolderModel/resDir/fname2','w]','','#','Open','file')
for tag in ElementTags:
print($fidwrite "$tag [eleNodes $tag]" ; # Print Nodal Coordinates to File )
op.}('','#','end','foreach','tag')
op.close('fidwrite','','#','Close','file')


op..wipeAnalysis()

# 4 Perform Analysis 

#1.ConstraintHandler:
op.constraints('Plain')
#2.DOF_Numberer: 
op.numberer('Plain')
#3.SystemOfEqn/Solver: 
op.system('BandGeneral')
#4.Convergence Test
op.test('EnergyIncr',1.e-006,1000)
#5.Algorithm
op.algorithm('Newton')
#6.Integrator
op.integrator('LoadControl','1')
#7. Analysis
op.analysis('Static')
# Realizar el analisis
op.analyze(1)

#remove recorders ;# No se tiene que cerrar el OpenSees para generar resultados




