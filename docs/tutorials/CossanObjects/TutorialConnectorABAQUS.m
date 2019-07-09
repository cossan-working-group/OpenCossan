%% Example script for the connector
%
% input file name <cossan root>/COSSANXengine/examples/Tutorials/Connector/ABAQUS/2D_Truss.inp
% output file name <cossan root>/COSSANXengine/examples/Tutorials/Connector/ABAQUS/2D_Truss.dat'
%
% FE CODE: Abaqus
%
%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria
%
% See Also: 
% http://cossan.cfd.liv.ac.uk/wiki/index.php/@Connector

clear;
close all
clc;
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(51125)

%% Tutorial Connector: ABAQUS
% This tutorial shows how to use a Connector the the FE solver ABAQUS. The
% predefined Connector options for the University of Innsbruck shared
% installation of Abaqus are used. Additionally, the FE solver is executed
% remotely on the cluster of the Institute of Engineering Mechanics.

%% Create the Injector
% An injector to the file with the identifiers 2D_Truss.cossan is here
% created. 
Sfolder=fileparts(mfilename('fullpath'));% returns the current folder
SfilePath=fullfile(Sfolder,'Connector','ABAQUS');

Xinj = opencossan.workers.ascii.Injector('Sscanfilepath',SfilePath,...
    'Sscanfilename','2D_Truss.cossan',...
    'Sfile','2D_Truss.inp');

%%  Build Extractor
% An extractor to the ASCII outptu file 2D_Truss.dat is here created. Two
% responses are defined.
Xresp1 = opencossan.workers.ascii.Response('Sname', 'OUT1', ...
    'Sfieldformat', '%10e', ...
    'Clookoutfor',{'E L E M E N T   O U T P U T'}, ...
    'Ncolnum',24, ...
    'Nrownum',19);

Xresp2 = opencossan.workers.ascii.Response('Sname', 'OUT2', ...
    'Sfieldformat', '%10e', ...
    'Clookoutfor',{'N O D E   O U T P U T'}, ...
    'Ncolnum',30, ...
    'Nrownum',10);

Xe=opencossan.workers.ascii.Extractor('Sdescription','Extractor for 2D_Truss', ...
    'Sfile','2D_Truss.dat', ...
    'Xresponse',[Xresp1 Xresp2]);
    

%% Construct the connector
Xc = opencossan.workers.Connector('Stype','abaqus',... FE solver identification
    'Ssolverbinary','/usr/software/Abaqus/Commands/abq6111',... Solver binary
    'Sexeflags','interactive ask_delete=off',... execution flags
    'Smaininputfile','2D_Truss.inp',... main input file
    'Smaininputpath',SfilePath,... absolute path to the original main input file
    'Sexecmd','%Ssolverbinary %Sexeflags job=%Smaininputfile ',... construction of the execution command
    'SerrorFileExtension','dat',... extension of the file with the indication of a successfull solver execution
    'SerrorString','***ERROR',... string identifying a failed solver execution
    'Sworkingdirectory','/tmp',... execution directory of the solver
    'LkeepSimulationFiles',false,... 
    'CXmembers',{Xe Xinj}); % objects included in the Connector

%%  Define the Inputs object required for the analysis
% The input quantities used in this tutorial are here introduced

% Create random variables.
XEmod = RandomVariable('Sdistribution','normal','mean',2.1E+11,'std',2.1E+10);
Xnu = RandomVariable('Sdistribution','normal','mean',0.3,'std',0.03);
XP = RandomVariable('Sdistribution','normal','mean',10000,'std',1000);

% Add the RandomVariable objects to a RandomVariableSet object
Xrvset = RandomVariableSet('Cmembers',{'XEmod','XP','Xnu'},'CXrv',{XEmod,XP,Xnu});

% Add the RandomVariableSet object to an Input object
Xi = Input;
Xi = add(Xi,Xrvset);

%% Monte Carlo Simulation
% A Monte Carlo simulation with 6 sample is then executed.

%% Definition of a JobManagerInterface
% JobManagerInterface is used to specify how to connect to a cluster (i.e.,
% running Oracle GridEngine). 

Xjmi = JobManagerInterface('Sdescription','Oracle Grid Engine ',...
    'SsubmitJob','qsub',... Job submission command
    'SdeleteJob','qdel',... Job deletion command
    'SqueryJob','qstat -s a  -xml',... Job status query (must return xml format)
    'SqueryGrid','qhost -q -xml');% Hosts status query (must return xml format)

%% Definition of an Evaluator
% An evaluator is used to collect various solvers together. The solver then
% computes the output quantities for all the samples. When a
% JobManagerInterface object is included in the Evaluator constructor, the
% solvers are executed on remote machines of a cluster. 

Xeval = Evaluator('CXmembers',{Xc},... Members of the evaluator (one or more solvers)
    'XjobManagerInterface',Xjmi,... JobManagerInterface object
    'Csqueues',{'all.q'},... Queue name
    'Nconcurrent',3,... Number of concurrent solver execution
    'LremoteInjectExtract',true);% Flag whether the Inject and Extract should be execute on the remote machines

%% Additional object definition
% To run a simulation, it is necessary to create a Model (union of an
% Evaluator and an Input object) and set the simulation properties.

% Create the Model
Xm = Model('Xinput',Xi,'Xevaluator', Xeval);

% Set Simulation properties
Xmc = MonteCarlo('Nsamples',6);

%% Perform Monte Carlo
Xout1 = Xmc.apply(Xm);
Vout1=Xout1.getValues('Sname','OUT1');
%% Plot Results
f1=figure;
fah=gca(f1);
plot(fah,Vout1,'*');
%% Close Figures
close(f1)

% Validate Solution
Vreference=[347660000 266450000 359420000 312070000 291680000 354420000]';
assert(max(abs(Vout1-Vreference))<1e-6,...
    'CossanX:Tutorials:TutorialConnectorABAQUS','Reference Solution does not match.')

