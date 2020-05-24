%% TutorialCantileverBeam: Model Definition and Uncertainty Quantification
% This script run the Cantilever Beam Tutorial in the COSSAN-X Engine
% The documentation and the problem description of this example is available on
% the User Manual -> Tutorials -> Cantilever_Beam
%
%
% See Also: http://cossan.co.uk/wiki/index.php/Cantilever_Beam

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2019 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License or,
(at your option) any later version.

OpenCossan is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

%% Initial setting
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED

%% Import packages
import opencossan.*
import opencossan.common.*
import opencossan.common.inputs.*
import opencossan.common.inputs.random.*
import opencossan.workers.*
import opencossan.simulations.*


%% Define an Analysis
% This allows to store the results of the simulation in a database (if
% initialised) or/and to define the random number generator
OpenCossan.setAnalysis('ProjectName', 'TutorialCantileverBeam', ...
    'AnalysisName', 'Tutorial', ...
    'Seed', 213985)

%% Preparation of the Input
% Definition of the Parameters
L = Parameter('value', 1.8, 'description', 'Beam Length');
b = Parameter('value', 0.12, 'description', 'Beam width');
maxDisplacement = Parameter('value', 0.010, 'description', 'Maximum allowed displacement');

% Definition of the Random Varibles
P = LognormalRandomVariable.fromMeanAndStd('mean', 5000, 'std', 400, 'Description', 'Load');
h = NormalRandomVariable('mean', 0.24, 'std', 0.01, 'description', 'Beam Heigth');
rho = LognormalRandomVariable.fromMeanAndStd('mean', 600, 'std', 140, 'description', 'density');
E = LognormalRandomVariable.fromMeanAndStd('mean', 10e9, 'std', 1.6e9, 'description', 'Young''s modulus');

% Definition of the Function
I = Function('Description', 'Moment of Inertia', 'Expression', '<&b&>.*<&h&>.^3/12');
% Set of Random Variable Set
Mcorrelation = eye(4);
Mcorrelation(3, 4) = 0.8; % Add correlation between rho and E
Mcorrelation(4, 3) = 0.8;
Xrvset = RandomVariableSet('members', [P; h; rho; E], ...
    'names', ["P", "h", "rho", "E"], 'Correlation', Mcorrelation);

%% Prepare Input Object
% The above prepared object can be added to an Input Object
Xinput = Input('Members', {L b Xrvset I maxDisplacement}, ...
    'MembersNames', {'L', 'b', 'Xrvset', 'I', 'maxDisplacement'});
% Show summary of the Input Object
display(Xinput)
%% Preparation of the Evaluator
% Use of a matlab script to compute the Beam displacement
currentFolder = fileparts(mfilename('fullpath'));
Xmio = MatlabWorker('FullFileName', fullfile(currentFolder, 'model', 'tipDisplacement.m'), ...
    'InputNames', {'I', 'b', 'L', 'h', 'rho', 'P', 'E'}, ...
    'OutputNames', {'w'}, 'Format', 'structure');
% Add the MatlabWorker object to an Evaluator object
% By default all the samples are processed by the workers using an
% horizontal splitting strategy (i.e. all the samples processed by the
% first workers, then the results of the first worker are passed to the
% second worker and so on). 
Xevaluator = Evaluator('Solver', Xmio, 'SolverName',"Xmio");

% To split the execution in vertical use set "VerticalSplit",true);
%Xevaluator.VerticalSplit=true;

%% Preparation of the Physical Model
% Define the Physical Model
XmodelBeamMatlab = Model('Input', Xinput, 'Evaluator', Xevaluator);

% Perform deterministic analysis
Xout = XmodelBeamMatlab.deterministicAnalysis;
NominalDisplacement = Xout.getValues('Sname', 'w');

% Validate Solution
assert(abs(NominalDisplacement - 7.1922e-03) < 1e-6, ...
    'CossanX:Tutorials:CantileverBeamMatlab', ...
    'Nominal solution does not match reference solution.')

%% Uncertainty Quantification
% Define simulation method
Xmc = MonteCarlo('Nsamples', 100);
% preform Analysis
XsimOutMC = Xmc.apply(XmodelBeamMatlab);

%% Plot Results
% show scatter of the beam tip displacement
f1 = figure;
fah = gca(f1);
Vw = XsimOutMC.getValues('Sname', 'w');
histogram(fah, Vw, 50);

%% Close Figures
close(f1)

%% Optimization
% This tutorial continues with the optimization section
% See Also:  <TutorialCantileverBeamMatlabOptimization.html>

% echodemo TutorialCantileverBeamMatlabOptimization

%% RELIABILITY ANALYSIS
% The reliaility analysis is performed by the following tutorial
%  See Also: <TutorialCantileverBeamMatlabReliabilityAnalysis.html>

% echodemo TutorialCantileverBeamMatlabReliabilityAnalysis

%% RELIABILITY BASED OPTIMIZAZION
% The reliability based optimization is shown in the following tutotial
% See Also: <TutorialCantileverBeamMatlabReliabilityBasedOptimizaion.html>

% echodemo TutorialCantileverBeamMatlabRBO
