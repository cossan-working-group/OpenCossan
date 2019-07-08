%**************************************************************************
%
% Test of connector with ANSYS and Xgrid object (i.e. Ansys is executed on a
% remote machine identified by the GridEngine
%
% Fatigue analysis of Suspension Arm
%
% FE CODE: ANSYS
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================
%   EP     - 06.10.2008: updated to the latest version
%   MAV - 22.08.2008: example updated considering latest changes in
%   COSSAN-X
%   MB - 27.08.2008: example updated considering latest changes in
%   COSSAN-X
% =========================================================================

clear all
OpenCossan.cossanDisp('your current directory should be [COSSAN-X]/testing/connector/ANSYS/');
%% 1.   Input object
t1  = parameters('Sdescription','t1','value',25);
t2  = parameters('Sdescription','t2','value',20);
t3  = parameters('Sdescription','t3','value',22);
t4  = parameters('Sdescription','t4','value',20);
t5  = parameters('Sdescription','t5','value',22);
t6  = parameters('Sdescription','t6','value',20);
t7  = parameters('Sdescription','t7','value',25);
Xin         = Xinput;
Xin         = add(Xin,t1);
Xin         = add(Xin,t2);
Xin         = add(Xin,t3);
Xin         = add(Xin,t4);
Xin         = add(Xin,t5);
Xin         = add(Xin,t6);
Xin         = add(Xin,t7);
% No RV defined. No need to create samples
% Xin         = sample(Xin,'Nsamples',1);

%% 2.   Injector
Xi  = injector('Stype','scan',...
    'Sscanfilename','suspension_arm_FL.cossan',...
    'Sfile','suspension_arm_FL.inp'...
    );

%% 3.   Create Extractor
Xe  = extractor('Stype','',...
    'Sdescription','Extraction of Fatigue Life', ...
    'Spath','./', ...
    'Sfile','suspension_arm_FL6.out', ...
    'Nresponse',1, ...
    'Sname', 'FL', ...
    'Sfieldformat', '%f', ...
    'Clookoutfor',{'FL'}, ...
    'Svarname','', ...
    'Ncolnum',5, ...
    'Nrownum',0,...
    'Sregexpression', '', ...
    'Nrepeat', 3980);

%% 4.   Create Connector
%4.1.   Basic set up
Xc  = connector('Stype','ansys','Lverbose',1);
Xc  = set(Xc,'Sworkingdirectory','./');
Xc  = set(Xc,'Smaininputfile','suspension_arm_FL.inp');
Xc  = set(Xc,'Soutputfile','suspension_arm_FL.out');
%4.2    Add injector
Xc  = add(Xc,Xi);             
%4.3    Add extractor to the connector
Xc  = add(Xc,Xe);
Xc  = set(Xc,'Spostprocname','POSTPROC.m');

%% 5. Grid object
Xg          = Xgrid('Stype','GridEngine');
Scwd        = pwd;
%   add pre- and post-execution commands to Grid object
Xg          = set(Xg,'Squeue','single_debian.q');

%   Add Xgrid to the connector
Xc      = add(Xc,Xg);
Xc      = set(Xc,'Sworkingdirectory','/tmp/');
%Xc      = set(Xc,'Sworkingdirectory','./');
%%
Toutput = run (Xc,'Xinput',Xin)