%% Example script for the connector
%
% input file name Ipatch and Ipatch.cossan
% output file name Opatch
%
% FE CODE: feap
% TODO: Add description
%
%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/@Connector


% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

%% WARNING
Sfolder=fileparts(mfilename('fullpath'));% returns the current folder

%% Create the Injector
SfilePath=fullfile(Sfolder,'Connector','FEAP');

% Create Injector
Xi=Injector('Stype','scan','SscanFilePath',SfilePath,...
    'Sscanfilename','Ipatch.cossan','Sfile','Ipatch');

% The position of the variable are stored into the Xi injector
% The format of the variable is the following:
% <cossan name="I" index="1" format="%1d" />
% name: is the name of the variable in the COSSAN-X workspace
% format: format use to store the variable in the input file
%         (see fscanf for more details about the format string
%          ordinary characters and/or conversion specifications.
%


%% Extractor
%  Build extractor
Xresp = Response('Sname', 'OUT1', ...
    'Sfieldformat', '%13e', ...
    'Clookoutfor',{'N o d a l   D i s p l a c e m e n t s'}, ...
    'Ncolnum',45, ...
    'Nrownum',6 );
Xe=Extractor('Sdescription','Extractor for Opatch', ...
    'Srelativepath','./subdir/', ...
    'Sfile','Opatch', ...
    'Xresponse', Xresp);

%% Construct the connector
% create the connector

Xc=Connector('SpredefinedType','Feap',...
    'Sdescription','FEAP cantilever plate with tip load',...
    'Sworkingdirectory','/tmp/FEAP',...
    'Smaininputpath',SfilePath,...
    'Smaininputfile','Ipatch',...
    'Lkeepsimulationfiles',true,...
    'Caddfiles',{'subdir/extrafile.txt'},...
    'SpostExecutionCommand','mv ./Opatch ./subdir/');

% Add injector and extractor
Xc=add(Xc,Xi);
Xc=add(Xc,Xe);

display(Xc)

%% Define Input

Xforce1 = RandomVariable('Sdistribution','uniform','lowerbound',2.5,'upperbound',3.5);
Xforce2 = RandomVariable('Sdistribution','uniform','lowerbound',5,'upperbound',7);
Xforce3 = RandomVariable('Sdistribution','uniform','lowerbound',2.5,'upperbound',3.5);

XforceSet = RandomVariableSet('Cmembers',{'Xforce1','Xforce2','Xforce3'},...
    'CXrv',{Xforce1,Xforce2,Xforce3});

Xfun1=Function('Sexpression','<&Xforce1&>+1');

Xinp = Input();
Xinp = add(Xinp,XforceSet);
Xinp = add(Xinp,Xfun1);

%% Test connector
Xeval=Evaluator('Xconnector',Xc);
Xmdl=Model('Xinput',Xinp,'Xevaluator',Xeval);
Xout=Xmdl.deterministicAnalysis;

%% Run a Montecarlo Simulation
Nsim = 10;
Xmc = MonteCarlo('Nsamples',Nsim);
Xout= Xmc.apply(Xmdl);

%% Plot Results
Vout= Xout.getValues('Sname','OUT1');

f1=figure;
fah=gca(f1);
plot(fah,Vout,'*');
set(fah,'Fontsize',12);
ylabel(fah,'x-displacement [m] at node 3');
xlabel(fah,'Simulation #');

%% Close Figures Validate Solution

Vreference=[ 1.1454e-03  -5.8159e-04   1.1050e-03  -2.0521e-03  -2.5715e-04...
    1.3891e-03   1.1012e-03  -9.7279e-05 1.0874e-03  -1.5063e-04]';
assert(max(abs(Vout-Vreference))<1e-6,...
    'CossanX:Tutorials:TutorialConnectorFEAP','Reference Solution does not match.')


