%
% Building under wind loading - perform Monte Carlo simulation 
%
% In this example, the variation of the stresses of a structural model with
% random model parameters are computed by means of MonteCarlo simulation.
%
% The structural model comprises a 6-story building under a lateral wind 
% excitation. The load is modeled with deterministic constant forces acting 
% on a side of the building, with the pressure of the wind, and thus the
% acting force, increasing as the height of the building according to a 
% power increase.
% The material and geometric parameters of the columns, stairs ceiling and 
% floors of the building are modeled with independent random variables.
% 500 MonteCarlo simulations are carried out. 
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =========================================================================

%% Initialization
% remove variables from the workspace and clear the console
clear variables
clc

% Initialize the timing variable. This part will be replace by the
% COSSAN environment initialization (when available)
OpenCossan.setVerbosityLevel(3)

%% Load Physical Model
load Xmodel_Building

%% Load important direction
% load Xgradient_Building

%% Define performance function
Xpf=PerformanceFunction('Scapacity','C2060','Sdemand','Xpar','Soutputname','Vg1');

%% Define probabilistic model
Xpm=ProbabilisticModel('Xmodel',Xm,'XPerformanceFunction',Xpf);

%% Define a simulation method

% A LineSampling object is created, by specifying the total number of lines
% and the number of batches.
% Each batch will contain Nsamples/Nbatches samples.
% The batches are used to obtain intermediated results and to keep the
% dimension of the files of reasonable size. 

Xls = LineSampling('Nlines',100,'Vset',2:6,'Nbatches',1,'Ladaptive',true);

%% Perform MonteCarlo simulation
%Xo=apply(Xls,'ProbabilisticModel',Xpm);
Xo=apply(Xls,Xpm);
Xpf=FailureProbability('smethod','LineSampling');

% The output of the apply method of the MonteCarlo object is a
% SimulationData object containing the values of the last batch of the
% MonteCarlo simulation. The output of the other batches are saved in
% automatically created .mat files.

% show the summary of the Simulation Output object
display(Xo)
