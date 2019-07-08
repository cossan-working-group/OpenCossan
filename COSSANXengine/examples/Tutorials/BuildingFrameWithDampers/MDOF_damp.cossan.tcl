# MDOF_damp.tcl 

######################## 
# Analysis-Sequence  1 #
######################## 

# Start of model generation 
# ========================= 
set c_damper1 <cossan name="c_damper1" index="1" format="%16.8e" original="100" />
set c_damper2 <cossan name="c_damper2" index="1" format="%16.8e" original="100" />
set c_damper3 <cossan name="c_damper3" index="1" format="%16.8e" original="100" />
set alpha_damper <cossan name="alpha_damper" index="1" format="%16.8e" original="0.7" />
set dt <cossan name="dt" index="1" format="%16.8e" original="0.01" />
set t_tot <cossan name="t_tot" index="1" format="%16.8e" original="30" />
set Numsteps [expr round($t_tot/$dt) +1]

# Create ModelBuilder 
# ------------------- 
model  BasicBuilder  -ndm  2  -ndf  3 

# Define geometry 
# --------------- 
# NodeCoord.tcl 

# Node    tag    xCrd    yCrd 
node       1  +0.000000E+000  +0.000000E+000 
node       2  +0.000000E+000  +3.963000E+000 
node       3  +0.000000E+000  +7.926000E+000 
node       4  +0.000000E+000  +1.188900E+001 
node       5  +9.150000E+000  +0.000000E+000 
node       6  +9.150000E+000  +3.963000E+000 
node       7  +9.150000E+000  +7.926000E+000 
node       8  +9.150000E+000  +1.188900E+001 
node       9  +1.830000E+001  +0.000000E+000 
node      10  +1.830000E+001  +3.963000E+000 
node      11  +1.830000E+001  +7.926000E+000 
node      12  +1.830000E+001  +1.188900E+001 
node      13  +2.745000E+001  +0.000000E+000 
node      14  +2.745000E+001  +3.963000E+000 
node      15  +2.745000E+001  +7.926000E+000 
node      16  +2.745000E+001  +1.188900E+001 
node      17  +3.660000E+001  +0.000000E+000 
node      18  +3.660000E+001  +3.963000E+000 
node      19  +3.660000E+001  +7.926000E+000 
node      20  +3.660000E+001  +1.188900E+001 
node      21  +3.659500E+001  +3.963000E+000 
node      22  +3.659500E+001  +7.926000E+000 
node      23  +3.659500E+001  +1.188900E+001 
node      24  +2.745250E+001  +3.963000E+000 
node      25  +2.745250E+001  +7.926000E+000 
node      26  +2.745250E+001  +1.188900E+001 

# Define Single Point Constraints 
# ------------------------------- 
# SPConstraint.tcl 

# SPC    tag    Dx    Dy    Rz 
fix       1     1     1     1 
fix       5     1     1     1 
fix       9     1     1     1 
fix      13     1     1     1 
fix      17     1     1     1 

# Define nodal masses 
# ------------------- 
# Mass    tag    mx    my    mIz 
mass       2  +5.981000E+001  +0.000000E+000  +0.000000E+000 
mass       3  +5.981000E+001  +0.000000E+000  +0.000000E+000 
mass       4  +6.500000E+001  +0.000000E+000  +0.000000E+000 
mass       6  +1.196250E+002  +0.000000E+000  +0.000000E+000 
mass       7  +1.196250E+002  +0.000000E+000  +0.000000E+000 
mass       8  +1.300000E+002  +0.000000E+000  +0.000000E+000 
mass      10  +1.196250E+002  +0.000000E+000  +0.000000E+000 
mass      11  +1.196250E+002  +0.000000E+000  +0.000000E+000 
mass      12  +1.300000E+002  +0.000000E+000  +0.000000E+000 
mass      14  +1.196250E+002  +0.000000E+000  +0.000000E+000 
mass      15  +1.196250E+002  +0.000000E+000  +0.000000E+000 
mass      16  +1.300000E+002  +0.000000E+000  +0.000000E+000 
mass      18  +5.981000E+001  +0.000000E+000  +0.000000E+000 
mass      19  +5.981000E+001  +0.000000E+000  +0.000000E+000 
mass      20  +6.500000E+001  +0.000000E+000  +0.000000E+000 

# Define Multi Point Constraints 
# ------------------------------ 
# MPConstraint.tcl 

# Equal DOF: hinge1:    mNodeTag    sNodeTag    dof 
equalDOF      16      26  1  2 

# Equal DOF: hinge2:    mNodeTag    sNodeTag    dof 
equalDOF      15      25  1  2 

# Equal DOF: hinge3:    mNodeTag    sNodeTag    dof 
equalDOF      14      24  1  2 

# Equal DOF: hinge4:    mNodeTag    sNodeTag    dof 
equalDOF      23      20  1  2 

# Equal DOF: hinge5:    mNodeTag    sNodeTag    dof 
equalDOF      22      19  1  2 

# Equal DOF: hinge6:    mNodeTag    sNodeTag    dof 
equalDOF      21      18  1  2 

# Define material(s) 
# ------------------ 
# Materials.tcl 

# Material "ElasticDefault":    matTag    E    eta  
uniaxialMaterial  Elastic       1  +2.900000E+004  +0.000000E+000 

# Material "damp1":    matTag    C    alpha  
uniaxialMaterial  Viscous       2  $c_damper1  +$alpha_damper

# Material "damp2":    matTag    C    alpha  
uniaxialMaterial  Viscous       3  $c_damper2  +$alpha_damper

# Material "damp3":    matTag    C    alpha  
uniaxialMaterial  Viscous       4  $c_damper3  +$alpha_damper


# Define section(s) 
# ----------------- 
# Sections.tcl 

# Section "ElasticDefault":    secTag    E    A    Iz 
section  Elastic       1  +2.900000E+004  +1.800000E+002  +4.860000E+003 

# Section "damp1":    secTag    matTag    string 
section  Uniaxial       2       2  P 

# Section "damp2":    secTag    matTag    string 
section  Uniaxial       3       3  P 

# Section "damp3":    secTag    matTag    string 
section  Uniaxial       4       4  P 


# Define geometric transformation(s) 
# ---------------------------------- 
# GeoTran    type    tag 
geomTransf  Linear       1 

# Define element(s) 
# ----------------- 
# Elements.tcl 

# Element "W14x257":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn       1       1       2  +4.877410E-002  +2.100000E+008  +1.415187E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x311":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn       2       5       6  +5.896762E-002  +2.100000E+008  +1.802282E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x311":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn       3       9      10  +5.896762E-002  +2.100000E+008  +1.802282E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x257":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn       4      13      14  +4.877410E-002  +2.100000E+008  +1.415187E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x68":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn       5      17      18  +1.290320E-002  +2.100000E+008  +5.036400E-005     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x257":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn       6       2       3  +4.877410E-002  +2.100000E+008  +1.415187E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x311":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn       7       6       7  +5.896762E-002  +2.100000E+008  +1.802282E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x311":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn       8      10      11  +5.896762E-002  +2.100000E+008  +1.802282E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x257":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn       9      14      15  +4.877410E-002  +2.100000E+008  +1.415187E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x68":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      10      18      19  +1.290320E-002  +2.100000E+008  +5.036400E-005     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x257":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      11       3       4  +4.877410E-002  +2.100000E+008  +1.415187E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x311":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      12       7       8  +5.896762E-002  +2.100000E+008  +1.802282E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x311":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      13      11      12  +5.896762E-002  +2.100000E+008  +1.802282E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x257":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      14      15      16  +4.877410E-002  +2.100000E+008  +1.415187E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W14x68":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      15      19      20  +1.290320E-002  +2.100000E+008  +5.036400E-005     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W33x118":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      16       2       6  +2.238700E-002  +2.100000E+008  +2.455765E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W33x118":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      17       6      10  +2.238700E-002  +2.100000E+008  +2.455765E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W33x118":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      18      10      14  +2.238700E-002  +2.100000E+008  +2.455765E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "damp1":    eleTag    NodeI    NodeJ    A    matTag 
element  truss      19       5      10  +1.000000E+000     2 

# Element "W30x116":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      20       3       7  +2.206447E-002  +2.100000E+008  +2.052021E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W30x116":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      21       7      11  +2.206447E-002  +2.100000E+008  +2.052021E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W30x116":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      22      11      15  +2.206447E-002  +2.100000E+008  +2.052021E-003     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "damp2":    eleTag    NodeI    NodeJ    A    matTag 
element  truss      23       6      11  +1.000000E+000     3 

# Element "W24x68":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      24       4       8  +1.296800E-002  +2.100000E+008  +7.617040E-004     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W24x68":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      25       8      12  +1.296800E-002  +2.100000E+008  +7.617040E-004     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W24x68":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      26      12      16  +1.296800E-002  +2.100000E+008  +7.617040E-004     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "damp3":    eleTag    NodeI    NodeJ    A    matTag 
element  truss      27       7      12  +1.000000E+000     4 

# Element "W21x44":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      31      24      21  +8.387080E-003  +2.100000E+008  +3.508830E-004     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W21x44":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      32      25      22  +8.387080E-003  +2.100000E+008  +3.508830E-004     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Element "W21x44":    eleTag    NodeI    NodeJ    A    E    Iz    geoTranTag    <alpha  d>    <-mass massDens> 
element  elasticBeamColumn      33      26      23  +8.387080E-003  +2.100000E+008  +3.508830E-004     1  +0.000000E+000  +0.000000E+000  -mass +0.000000E+000 

# Define time series 
# ------------------ 
# TimeSeries.tcl 

# TimeSeries "LinearDefault":    tsTag    cFactor 
timeSeries  Linear       1  -factor  +1.000000E+000 

# TimeSeries "acc":    tsTag    dt    filePath    cFactor 
timeSeries  Path       2  -dt  +1.000000E-002  -filePath  acc.thf  -factor  +1.000000E+000 


# Start of analysis generation 
# =========================== 

# Get Initial Stiffness 
# --------------------- 
initialize 

# Analysis: th 
# ++++++++++++ 

# Define load pattern 
# ------------------- 
# LoadPattern_3.tcl 

# LoadPattern "acc":    patternTag    dir    tsTag 
pattern  UniformExcitation       1     1  -accel       2 

# Define recorder(s) 
# -------------------- 
# Recorder_3.tcl 

# Node Recorder "DefoShape":    fileName    <nodeTag>    dof    respType 
recorder  Node  -file th_Node_DefoShape_Dsp.out  -time  -node 2  3  4  -dof 1  disp 

# Node Recorder "Reactions":    fileName    <nodeTag>    dof    respType 
recorder  Node  -file th_Node_Reactions_RFrc.out  -time  -nodeRange 1  26  -dof 1  2  3  reaction 

# Truss Recorder "Recorder01":    fileName    <eleTag>    arguments 
recorder  Element  -file Truss_Forc.out  -time  -ele 19  23  27  basicForce 
# recorder  Element  -file Truss_Recorder01_BasForc.out  -time  -ele 19  23  27  basicForce 
# recorder  Element  -file th_Truss_Recorder01_BasForc.out  -time  -ele 19  23  27  basicForce 
# recorder  Element  -file th_Truss_Recorder01_BasDefo.out  -time  -ele 19  23  27  deformation 



# Define analysis options 
# ----------------------- 
# AnalysisOptn_3.tcl 

# AnalysisOptn "TransientDefault": Type: Transient 
# ------------------------------------------------ 
# Constraint Handler 
constraints  Plain 
# Convergence Test 
test  NormDispIncr  +1.000000E-012    25     5     2 
# Integrator 
integrator  Newmark  +5.000000E-001  +2.500000E-001 
# Solution Algorithm 
# algorithm  Newton
# algorithm  NewtonLineSearch  -type Bisection    -minEta +1.000000E-001  -maxEta +1.000000E+001  -pFlag    1
algorithm  Broyden  
# DOF Numberer 
numberer  RCM 
# System of Equations 
system  BandGeneral 
# Analysis Type 
analysis  Transient 

# Define damping parameters
# -------------------------
# parameter set "DampingParam01":    alphaM    betaK    betaKinit    betaKcomm 
rayleigh +1.904000E-001 +1.575600E-003 +0.000000E+000 +0.000000E+000

analyze  $Numsteps  $dt

# Clean up 
# -------- 
wipe 
exit 

