%% Tutorial of the connector with ANSYS
%
% FE CODE: ANSYS
% TODO: Include a short description of this tutorial
%
%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria
%
% See Also: 
% http://cossan.cfd.liv.ac.uk/wiki/index.php/@Connector
error('The FE code is not creting an ASCII output file, thus the tutorial fails. Please PB fix the ASCII input file!')

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

%% Definition of Inputs 
% Definition of the  Random Variables
x1_diam1  = RandomVariable('Sdistribution','normal','mean',25,'std',5);      %outer diameter - 1
x2_diam2  = RandomVariable('Sdistribution','normal','mean',12.5,'std',2.5);       %outer diameter - 2

% Definition of Set of RandomVariable's
Cmems       = {'x1_diam1'; 'x2_diam2'};
Xrvs        = RandomVariableSet('Cmembers',Cmems,'CXmembers',{x1_diam1 x2_diam2});

% Definition of the Input
Xin=Input;
Xin=add(Xin,Xrvs);

%% Create the Injector
SfilePath=fullfile(OpenCossan.getCossanRoot, ...
    'examples','Tutorials','Connector','ANSYS');

Xi=Injector('Stype','scan','Sscanfilepath',SfilePath,...
    'Sscanfilename','bike1.cossan','Sfile','bike1.txt');

%% Define extractor object
Xresp = Response(    'Sname', 'Load', ...
    'Sfieldformat', '%8f%*', ...
    'Clookoutfor',{'THE FOLLOWING DEGREE OF FREEDOM RESULTS ARE IN THE GLOBAL COORDINATE SYSTEM','THE FOLLOWING DEGREE OF FREEDOM RESULTS ARE IN THE GLOBAL COORDINATE SYSTEM';}, ...
    'Svarname','', ...
    'Ncolnum',10, ...
    'Nrownum',4);

Xe=Extractor('Sdescription','Extractor for BLABLABLA', ...
    'Srelativepath','.', ... % this is the directory where the input and output are contained
    'Sfile','bike1.out', ...
    'Xresponse',Xresp);

%% Define the connector
% Create connector for ansys
Xc=Connector('SpredefinedType','ansys','Sworkingdirectory','/tmp',...
    'Smaininputfile','bike1.txt',...
    'Smaininputpath',SfilePath,...
    'Soutputfile','bike1.out');

% Add injector
Xc=add(Xc,Xi);

% Add extractor to the connector
Xc=add(Xc,Xe);


%% Construct the Model
% Define the evaluator 
Xev=Evaluator('Xconnector',Xc);
% Define the model
Xm  = Model('Xinput',Xin,'Xevaluator',Xev,'Sdesc','Testing ANSYS');

%% Monte Carlo simulation
% Estimation with MCS
Xmc=MonteCarlo('Nsamples',5,'Nbatches',1);

%% Perform Analysis
Xout1 = Xmc.apply(Xm);
Vout1=Xout1.getValues('Sname','Load');
% Plot Results
f1=figure;
fah=gca(f1);
plot(fah,Vout1,'*');
%% Close Figures
close(f1)

% Validate Solution
% TODO: Add reference solution
Vreference=[]';
assert(max(abs(Vout1-Vreference))<1e-6,...
    'CossanX:Tutorials:CantileverBeam','Reference Solution does not match.')
