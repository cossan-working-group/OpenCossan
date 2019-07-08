%% Example script for the connector using a CATHENA files
%
% CATHENA is called using the following command:
% <path to cathena executable> input.inp 
%
% input file name <cossan root>/COSSANXengine/examples/Tutorials/Connector/CATHENA/PipeBlowdown.txt
% output file name <cossan root>/COSSANXengine/examples/Tutorials/Connector/CATHENA/example1_output.dat'
%
% SOLVER CODE: CATHENA
%
%  Copyright 1993-2016, COSSAN Working Group
%  Edoardo Patelli, 
%
% See Also: 
% http://cossan.co.uk/wiki/index.php/@Connector

%% BE SURE OpenCOSSAN has been initialised

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

%% Tutorial Connector: CATHENA
% This tutorial shows how to use a Connector to link the solver CATHENA to
% OpenCOSSAN. The predefined Connector uses the input/output files in
% <cossan root>/COSSANXengine/examples/Tutorials/Connector/CATHENA. 
% A "fake" solver is created "cat3_5drev2.exe.sh". The shell script does
% NOT run the analysis and it should be replaced with the real solver.  
%

% In this examples 3 quantities are connected with OpenCOSSAN
% (ReservoirPressure, InitialPressure and InitialTemperature)
%
ReservoirPressure=Parameter('value',1.013E5);
InitialPressure=RandomVariable('Sdistribution','normal','mean',7,'cov',0.1);
InitialTemperature=RandomVariable('Sdistribution','uniform','lowerBound',200,'upperBound',300)

RVSET=RandomVariableSet('CSmembers',{'InitialPressure' 'InitialTemperature'});
Xinput=Input('CSmembers',{'RVSET' 'ReservoirPressure'},'CXmembers',{RVSET ReservoirPressure});
%
% The outputs are collected from a file (edwards_press.dat) 

%% Create the Injector
% An injector is screated by scanning the file PipeBlowdown.inp.cossan containing 3 indentifiers
Sfolder=fileparts(mfilename('fullpath'));% returns the current folder
SfilePath=fullfile(Sfolder,'Connector','CATHENA');

Xinj = Injector('Sscanfilepath',SfilePath,...
                'Sscanfilename','PipeBlowdown.inp.cossan',...
                'Sfile','PipeBlowdown.inp');
            
% Show the content of the identifier
display(Xinj)             

%% Output files
% The output is collected from the file edwards_press.dat 
% Since the data are written in a table format is convinient to use the
% method TableExtractor 
%
% Let assume we are interested on the first and 5 colum of the table. 
%
% same folder that contains the input file. 
Xte1=TableExtractor('Sdescription','Extractor for the tutorial CATHENA', ...
                'Sdelimiter','\t', ... % A tab format
                'Luseload',true,... 
              'LextractColumns',true, ...
             'Srelativepath','./', ... % relative path to the Sworkingdirectory where result file is located
             'Sfile','edwards_press.dat'); % response to be extracted as defined above


%% Construct the connector
Xc = Connector('Stype','cathena',... solver identification
    'Ssolverbinary','SfilePath/cat3_5drev2.exe.sh',... Solver binary
    'Sexeflags','',... execution flags
    'Smaininputfile','PipeBlowdown.inp',... main input file
    'Smaininputpath',SfilePath,... absolute path to the original main input file
    'Sexecmd','%Ssolverbinary %Smaininputfile %Sexeflags',... construction of the execution command
    'LkeepSimulationFiles',false,... 
    'CXmembers',{Xinj Xte1}); % objects included in the Connector

%% Define the model

Xeval = Evaluator('CXmembers',{Xc}); % Members of the evaluator (one or more solvers)

% Create the Model
Xm = Model('Xinput',Xinput,'Xevaluator', Xeval);

% Test the model performing a deterministic analysis
Xout=Xm.deterministicAnalysis;

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

