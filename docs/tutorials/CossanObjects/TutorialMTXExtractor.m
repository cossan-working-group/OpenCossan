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
clear 
close all
clc;

%% Preparation of FE-analysis

% copy FE-input file with COSSAN-identifiers to working directory
StutorialPath = fileparts(which('TutorialMTXExtractor.m'));
copyfile([StutorialPath '/Connector/ABAQUS/antenna.cossan'],...
    fullfile(opencossan.OpenCossan.getWorkingPath),'f');

% Define random variables and random variable set
mat1 = opencossan.common.inputs.random.NormalRandomVariable('mean',3e+7,'std',3e+6);
mat2 = opencossan.common.inputs.random.NormalRandomVariable('mean',1e+7,'std',1e+6);
mat3 = opencossan.common.inputs.random.NormalRandomVariable('mean',1.59e+7,'std',1.59e+6);
mat4 = opencossan.common.inputs.random.NormalRandomVariable('mean',3e+7,'std',3e+6);
mat5 = opencossan.common.inputs.random.NormalRandomVariable('mean',1e+7,'std',1e+6);

rvs = opencossan.common.inputs.random.RandomVariableSet('names',{'mat1', 'mat2','mat3','mat4','mat5'}, 'members',[mat1;mat2;mat3;mat4;mat5]);

% Define Input object and generate samples
Xin = opencossan.common.inputs.Input;
Xin = add(Xin,'member',rvs,'name','rvs');
Xin = sample(Xin,'Nsamples',3);

% Define Injector
Xi=opencossan.workers.ascii.Injector('SscanfilePath',opencossan.OpenCossan.getWorkingPath,...
    'Sscanfilename','antenna.cossan','Sfile','antenna.inp');

% define the name of the file & path of the file & the variable name to be stored
XmtxEx = opencossan.workers.ascii.MTXExtractor('Sfile','antenna_STIF2.mtx','Soutputname','stiffness');

% Define Connector
Xc = opencossan.workers.Connector('SpredefinedType','abaqus', ...
               'Smaininputpath',opencossan.OpenCossan.getWorkingPath,...
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
