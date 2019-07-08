%% TUTORIAL for the MTXExtractor object 
% In this tutorial it is shown how to import matrices from an Abaqus output 
% file (*.mtx-file) into Matlab
%
% Prepared by BG
%**************************************************************************
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@MTXExtractor
%

%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria

%% Preparation of FE-analysis

% copy FE-input file with COSSAN-identifiers to working directory
StutorialPath = fileparts(which('TutorialMTXExtractor.m'));
copyfile([StutorialPath '/Connector/ABAQUS/antenna.cossan'],...
    fullfile(OpenCossan.getCossanWorkingPath),'f');

% Define random variables and random variable set
mat1 = RandomVariable('Sdistribution','normal','mean',3e+7,'std',3e+6);
mat2 = RandomVariable('Sdistribution','normal','mean',1e+7,'std',1e+6);
mat3 = RandomVariable('Sdistribution','normal','mean',1.59e+7,'std',1.59e+6);
mat4 = RandomVariable('Sdistribution','normal','mean',3e+7,'std',3e+6);
mat5 = RandomVariable('Sdistribution','normal','mean',1e+7,'std',1e+6);

rvs = RandomVariableSet('Cmembers',{'mat1', 'mat2','mat3','mat4','mat5'});

% Define Input object and generate samples
Xin = Input;
Xin = add(Xin,rvs);
Xin = sample(Xin,'Nsamples',3);

% Define Injector
Xi=Injector('SscanfilePath',OpenCossan.getCossanWorkingPath,...
    'Sscanfilename','antenna.cossan','Sfile','antenna.inp');

% define the name of the file & path of the file & the variable name to be stored
XmtxEx = MTXExtractor('Sfile','antenna_STIF2.mtx','Soutputname','stiffness');

% Define Connector
Xc = Connector('SpredefinedType','Abaqus', ...
               'Sworkingdirectory','/tmp',...
               'Smaininputpath',OpenCossan.getCossanWorkingPath,...
               'Smaininputfile','antenna.inp');

% Add injector and extractor to connector
Xc = add(Xc,Xi);
Xc = add(Xc,XmtxEx);

%% Run FE-analysis and read stiffness matrix from file
Xout = run(Xc,Xin);

% show sparsity pattern of stiffness matrix
f1 = figure;
spy(Xout.Tvalues(1).stiffness)

%% Remove simulation files and close figures

close(f1)
assert(all(all(abs(size(Xout.Tvalues(1).stiffness)-[14512 14512])<1e-4)),'CossanX:Tutorials:TutorialMTXExtractor', ...
       'Reference Solution regarding size of matrix does not match.')
