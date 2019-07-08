%% Example script for the connector
%
% input file name plate.dat and plate.cossan for the injector
% output file name plate.f06
%
% FE CODE: nastran
%
%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/@Connector

% TODO: Add description

% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)


%% WARNING
Sfolder=fileparts(mfilename('fullpath'));% returns the current folder


%%  Create the Injector
SfilePath= fullfile(Sfolder,'Connector','NASTRAN');

Xin=Injector('Sscanfilepath',SfilePath,...
    'Sscanfilename','plate.cossan','Sfile','plate.dat');

% The position of the variable are stored into the Xin injector
% The format of the variable is the following:
% <cossan name="I" index="1" format="%1d" original="1"/>
% name: is the name of the variable in the COSSAN-X workspace
% format: format use to store the variable in the input file
%         (see fscanf for more details about the format string
%          ordinary characters and/or conversion specifications.
%


%% Extractor

%  Build extractor
Xresp1 = Response('Sname', 'OUT1', ...
    'Sfieldformat', '%13e', ...
    'Clookoutfor',{'MAXIMUM  DISPLACEMENTS'}, ...
    'Ncolnum',44, ...
    'Nrownum',3 ...
    );


Xe=Extractor('Sdescription','Extractor for plate.f06', ...
    'Srelativepath','./', ...
    'Sfile','plate.f06',...
    'Xresponse',[Xresp1]);

%%  Construct the connector

%  create the connector
Xc=Connector('SpredefinedType','nastran_x86_64','Sworkingdirectory','/tmp/',...
    'Smaininputpath',SfilePath,...
    'Smaininputfile','plate.dat',...
    'LkeepSimulationFiles',false);


% Add injector and extractor
Xc=add(Xc,Xin);
Xc=add(Xc,Xe);


%% USE  THE CONNECTOR
% Please note that this example perform a "strange" simulation, since the
% material identifier is injected (integer random numbers, 1 or 2),
% creatind a plate where the material of the elements is randomly chosen
% between the two avaialable material.

% Create Parameters
mat1=Parameter('value',7E+7); 
mat2=Parameter('value',2E+7);
% Create uniform discrete random variable with value 1 and 2
rv=RandomVariable('Sdistribution','uniformdiscrete','parameter1',0,'Parameter2',2);
% Create a set of 256 identically distributed random varaibles. The name of
% the random variable is automaticall set adding "_i" to the name of the
% original random variable (in this case rv -> rv_1 ... rv_256)
rvset1=RandomVariableSet('Cmembers',{'rv'},'Nrviid',256);

Xinp = Input('CXmembers',{mat1,mat2,rvset1},...
    'CSmembers',{'mat1','mat2','rvset1'});
Xinp = Xinnp.sample('Nsamples',1);


%% Run the Analysis
Xjm = JobManagerInterface('Stype','GridEngine');

Xeval = Evaluator('Xconnector',Xc,'XJobManagerInterface',Xjm,...
    'CSqueues',{'pizzas64.q'},'Vconcurrent',[4]);
% create Model
Xm = Model('Xinput',Xinp,'Xevaluator', Xeval);
% Monte Carlo simulation
Nsim=8;
Xmc = Montecarlo('Nsamples',Nsim);
Xoutput = Xmc.apply(Xm);
%% Plot Results
Vout_sim= Xoutput.getValues('Sname','OUT1');

f1=figure;
fah=gca(f1);
plot(fah,Vout_sim,'*');
set(fah,'Fontsize',12);
xlabel(fah,'x-displacement [m] at node 3');
ylabel(fah,'frequency');
title(fah,['histogram using ' num2str(Nsim) ' samples']);
%% Close Figures
close(f1)

% Validate Solution
% TODO: Add reference solution
Vreference=[149.7516  165.8618  168.5966  168.4262  158.0551  171.0607  164.2002  167.8832]';
assert(max(abs(Vout_sim-Vreference))<1e-2,...
    'CossanX:Tutorials:TutorialConnectorNASTRAN','Reference Solution does not match.')
