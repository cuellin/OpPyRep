

from typing import Optional
import openseespy.opensees as op
import time
import math
import os
import numpy as np
import glob
import pathlib


import multiprocessing as mp


def readAT2(path):
    if path.is_file():
        current_file = open(path, "r")
        
    accGM= current_file.readlines()
    GMName = current_file.name
    current_file.close()
    acc_i = 0
    j=0
    auxTail= os.path.split(GMName)
    GMtail=auxTail[1]
    tempFile1=open(f"{GMtail}_Accel.txt","w")

    for i in range (len(accGM)):
        auxGM = accGM[i]
        if i == 3:
            dataLine = auxGM.split()
            nPts = int(dataLine[0])
            dT=float(dataLine[1])
            GMlist = np.zeros(nPts)
        if i >=4:
            auxAccel1 = auxGM.split()
            auxAccel = np.array(auxAccel1).T
            for j in auxAccel:
        
                aux = float(j)
                GMlist[acc_i] = aux
                tempFile1.write(f"{aux}\n")
                acc_i = acc_i + 1
            j=0

    dt=dT
    npts=nPts

    #print(f" {GMtail} ###### nPts = {nPts}  -----------  dT = {dT}")

    tempFile1.close()
    
    return GMtail,dt,npts


def RunAnalysis(path):
    op.wipe()
    op.wipeAnalysis()
    
    GMtail,dt,npts = readAT2(path)
        

    op.model('basic','-ndm',2)

    SubStep = 10

    


    print(f"--------------------Analyzing {GMtail} -----------------------  at Scale Factor: {IDASF}")

    pDelta="Si"
    H = 300
    L = 600
    g = 980.665
    m1 = 1000.0/g

    RBS_base = 10.0
    RBS_nodo = 20.0
    Es = 2100.0
    Fy = 3.5
    dir_Sismo = 1
    pi = math.pi
    SubStep = 10.0
    Nfrec = 1




    #Columns
    #W24x162
    A_W24x162 = 307.74
    I_W24x162 = 215191.65
    z_W24x162 = 7669.146

    #Beams
    #W30x132
    A_W30x132 = 250.97
    I_W30x132 = 240165.53
    d_W30x132 = 76.9874
    z_W30x132 = 7161.147

    #Distributed Load 
    w1 =  -1.1/100.0

    rot = 0.005

    #Elastic Column material W24x162
    KCol_El = 1
    KCol = z_W24x162*Fy/rot
    op.uniaxialMaterial('Elastic',KCol_El,KCol)

    #Elastic Beam material W30x132
    KViga_El = 2
    KVig = z_W30x132*Fy/rot
    op.uniaxialMaterial('Elastic',KViga_El,KVig )

    #RBS material
    KCol_Ine = 3
    op.uniaxialMaterial('Steel01',KCol_Ine,z_W24x162*Fy,KCol,-0.05)

    KViga_Ine = 4
    op.uniaxialMaterial('Steel01',KViga_Ine,z_W30x132*Fy,KVig,-0.05)

    matElast = 6
    op.uniaxialMaterial('Elastic',matElast,Es)


    #Nodes
    #node $nodeTag (ndm $coords) <-mass (ndf $massValues)>
    op.node (1	,0.0 ,	0.0)
    op.node (2	,0.0 ,	H)
    op.node (3	,L ,	H)
    op.node (4	,L ,	0.0)

    #Rotulas base columna
    op.node (200 , 0.0 ,	RBS_base )
    op.node (201 , 0.0 ,	RBS_base )
    op.node (204  , L ,	RBS_base )
    op.node (205 , L , RBS_base )

    #Rotulas extremo superior columna primer piso
    op.node (202,	0.0 ,	H-d_W30x132/2)
    op.node (203,	0.0 ,	H-d_W30x132/2)
    op.node (206,	 L ,	H-d_W30x132/2)
    op.node (207, L ,	H-d_W30x132/2)

    #Rotulas viga primer piso
    op.node (100 , RBS_nodo ,	H)
    op.node (101 , RBS_nodo ,   H)
    op.node (102 , L-RBS_nodo ,	H)
    op.node (103 ,  L-RBS_nodo ,	H)

    op.equalDOF(1,2,2)
    op.equalDOF(4,3,2)
    op.equalDOF(201,202,2)
    op.equalDOF(205,206,2)
    #op.equalDOF(203,2,2)
    #op.equalDOF(207,3,2)

    op.fix (1, 1, 1, 1)
    op.fix (4, 1, 1, 1)

    op.mass (2 ,m1 ,0.0, 0.0)

    #geomTransf
    #op.geomTransf ('PDelta', 2)
    if pDelta == "Si":
	        op.geomTransf ('PDelta', 2)
    else:
	        op.geomTransf ('Linear', 2)


    #Elements
    #Columns
    #W24x162
    op.element ('elasticBeamColumn', 1, 1, 200, A_W24x162 ,Es ,I_W24x162, 2)
    op.element ('elasticBeamColumn', 2, 201, 202, A_W24x162, Es, I_W24x162, 2)
    op.element ('elasticBeamColumn', 3 ,203, 2, A_W24x162, Es ,I_W24x162, 2)
    op.element ('elasticBeamColumn', 4 ,4, 204, A_W24x162, Es, I_W24x162, 2)
    op.element ('elasticBeamColumn', 5, 205 ,206, A_W24x162, Es, I_W24x162, 2)
    op.element ('elasticBeamColumn', 6, 207 ,3, A_W24x162 ,Es, I_W24x162 ,2)


    #Beams
    #W30x132
    op.element ('elasticBeamColumn', 7, 2, 100, A_W30x132, Es, I_W30x132, 2)
    op.element ('elasticBeamColumn', 8, 101, 102 ,A_W30x132, Es ,I_W30x132, 2)
    op.element ('elasticBeamColumn', 9, 103, 3, A_W30x132, Es ,I_W30x132, 2)


    def rotSpring2D (eleID,nodeR,nodeC,matID):
        op.element('zeroLength', eleID,nodeR,nodeC,'-mat',matID,'-dir',6)
        op.equalDOF(nodeR,nodeC,1,2)

    rotSpring2D (2000,200,201,KCol_Ine)
    rotSpring2D (2001,202,203,KCol_Ine)
    rotSpring2D (2002,204,205,KCol_Ine)
    rotSpring2D (2003,206,207,KCol_Ine)
    rotSpring2D (1000,100,101,KViga_Ine)
    rotSpring2D (1001,102,103,KViga_Ine)

    #Damping
    Ti = 1
    Tj = 1
    xi = 0.05
    lamda = op.eigen('-fullGenLapack',Nfrec)
    period = np.array([len(lamda)])
    freq = np.array([len(lamda)])
    for lam in lamda:
        freq=np.append(freq,math.sqrt(lam))
        wn = math.sqrt(lam)
        period=np.append(period,2.0*pi/wn)

    wn = freq
    wi = wn[Ti-1]
    wj = wn[Tj-1]
    alphaM = 2.0*xi*wi*wj/(wi+wj)
    beta = 2.0*xi/(wi+wj)
    betaK = 0.0
    betaKini = beta 
    betaKcomm = 0.0

    op.rayleigh(alphaM,betaK,betaKini,betaKcomm)




    ResDir = "Results_PD"

    if not os.path.exists(ResDir):
        os.makedirs(ResDir)

    #Analysis 

    #print(f"Analyzing with dt = {dt} and {npts} in total\n")
    #Gravity define
    op.wipeAnalysis()
    op.constraints('Plain')
    op.numberer('RCM')
    op.system('BandSPD')
    op.test('EnergyIncr',0.000001,10)
    op.algorithm('Newton')
    op.integrator('LoadControl',1.0)
    op.analysis('Static')
  

    op.analyze(1)
    op.loadConst('-time',0.0)
    op.wipeAnalysis()
    #op.setTime(0.0)

    factor = g*IDASF

    op.timeSeries('Path',1,'-dt',dt,'-filePath',GMtail+'_Accel.txt','-factor',factor)
    op.pattern('UniformExcitation',2,1,'-accel',1)

    op.wipeAnalysis()
    op.constraints('Plain')
    op.numberer('RCM')
    op.system('BandSPD')
    op.test('EnergyIncr',0.000001,100)
    op.algorithm('Newton')
    op.integrator('Newmark',0.5,0.25)
    op.analysis('Transient')

    GMResDir = GMtail+'_Res'
    os.chdir(ResDir)
    if not os.path.exists(GMResDir):
        os.makedirs(GMResDir)
    os.chdir('..')

    IDAStr = str(IDASF)
    op.recorder('Node','-file',ResDir+'/'+GMResDir+'/'+GMtail+'_'+IDAStr+'_Disp.out','-time','-node',2,'-dof',1,'disp')
    op.recorder('Node','-file',ResDir+'/'+GMResDir+'/'+GMtail+'_'+IDAStr+'_DampingForces.out','-dT',dt,'-nodeRange',1,100000,'-dof',1,2,3,'rayleighForces')
    op.recorder('Node','-file',ResDir+'/'+GMResDir+'/'+GMtail+'_'+IDAStr+'_NodeDisp.out','-dT',dt,'-nodeRange',1,100000,'-dof',1,2,3,'disp')


    maxtime = dt*npts
    DtAnalysis = dt/SubStep
    Nsteps = maxtime/DtAnalysis
    inctol = 0.00001
    ok = 0
    controlTime = op.getTime()

    while ok == 0 and controlTime < maxtime:
        ok = op.analyze(1,DtAnalysis)
        controlTime = op.getTime()
    if ok != 0:
        print(f"Dynamic Analysis of {GMtail} doesn't converge at t = {controlTime}  ###  ok = {ok}")
    else:
        print(f"Dynamic Analysis of {GMtail} finished, duration: {controlTime} seconds")


    os.remove(f"{GMtail}_Accel.txt")

    #print(GMtail+' has been completed')
    print("Process: "+mp.current_process().name+" completed")
    #print(os.getpid())

    

if __name__ == "__main__":
    print('Permorfing Parallel Analysis')
    start = time.time()
    IDASF = 0.75
    os.chdir('SISMOS')
    gm_files=os.listdir()

    #IDA_Factors = [0.5,0.75,1.0,1.25,1.5]
    
    #i1 = 1
    #for i1 in range(np.size(IDA_Factors)):
        #IDASF = IDA_Factors[i1]
    for i in range(np.size(gm_files)):
        gm_files[i]=pathlib.Path(os.getcwd()+'/'+os.listdir()[i])
    os.chdir('..')
    
    nproc=8
    
    p = mp.Pool(nproc)
    
    p.map(RunAnalysis,gm_files)
    #p.map(RunAnalysis,IDA_Factors)
    p.close()
    p.join()
        
    
    end = time.time()
    dur = end-start
    print("Duration: %.3f seconds" % dur )
         
