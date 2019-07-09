function XSimOutput = apply(Xpc,Xinput)
%
%   MANDATORY ARGUMENTS: 
%
%   OPTIONAL ARGUMENTS: -
%
%   EXAMPLES:
%                            
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

%% Obtain the samples from Xinput

MinputSamples = Xinput.getSampleMatrix;

%% Obtain the P-C coefficients from Xpc

Mpc = Xpc.Mpccoefficients;

%% Calculate the responses using PC

Mresponse = sample(Xpc.Sbasis,Mpc',Xpc.Norder,MinputSamples);

%% Create the Simulation output

XSimOutput = SimulationData('Sdescription','Simulation Output from PC','Mvalues',Mresponse);

return
