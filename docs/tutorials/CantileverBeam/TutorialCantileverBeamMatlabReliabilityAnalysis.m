%% TutorialCantileverBeam: Reliability Analysis
% Perform reliability analysis on a cantilever beam. The 
% documentation and the problem description of this example is available 
% at: <http://cossan.co.uk/wiki/index.php/Cantilever_Beam>

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2018 COSSAN WORKING GROUP
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


%% Create model if necessary
% This tutorial requires the model created by the tutorial 
% TutorialCantileverBeamMatlab

if ~exist('XmodelBeamMatlab','var')
    run('TutorialCantileverBeamMatlab');
end

%% Define a Probabilistic Model
% Performance Function
Xperfun = opencossan.reliability.PerformanceFunction('OutputName', 'Vg',...
    'Demand', 'w', 'Capacity', 'maxDisplacement');
% Define a Probabilistic Model
XprobModelBeamMatlab = opencossan.reliability.ProbabilisticModel(...
    'Model', XmodelBeamMatlab, 'PerformanceFunction', Xperfun);

%% Reliability Analysis via Monte Carlo Sampling
% Reset the random number generator to always produce the same results
opencossan.OpenCossan.resetRandomNumberGenerator(51125);

% Create MonteCarlo simulation object to run 1e5 samples in 1 batch
Xmc = opencossan.simulations.MonteCarlo('samples', 1e5, 'batches', 1);

% Run reliability analysis
XfailureProbMC = Xmc.computeFailureProbability(XprobModelBeamMatlab);
display(XfailureProbMC);

% Validate Solution
assert(XfailureProbMC.Value == 0.06922,...
       'CossanX:Tutorials:CantileverBeam',...
       'Reference Solution pf MCS not matched.');

%% Reliability Analysis via Latin Hypercube Sampling
% Reset the random number generator to always produce the same results
opencossan.OpenCossan.resetRandomNumberGenerator(49564);

% Create LatinHypercubeSampling simulation object to run 1e4 samples in 1
% batch
Xlhs=opencossan.simulations.LatinHypercubeSampling('samples', 1e4);

% Run reliability analysis
XfailureProbLHS = Xlhs.computeFailureProbability(XprobModelBeamMatlab);
display(XfailureProbLHS);

% Validate Solution
assert(XfailureProbLHS.Value == 0.06840,...
       'CossanX:Tutorials:CantileverBeam',...
       'Reference Solution pf LHS not matched.');

%% Reliability Analysis via LineSampling
% Line Sampling requires the definition of the so-called important 
% direction. It can be compute using sensitivity methods. For instance,
% here the gradient in standard normal space is computed.

XlsFD = opencossan.sensitivity.LocalSensitivityFiniteDifference(...
    'Xmodel', XprobModelBeamMatlab, 'Coutputname', "Vg");
XlocalSensitivity = XlsFD.computeGradientStandardNormalSpace();

% Use sensitivity information to define the important direction for LineSampling
XLS=opencossan.simulations.LineSampling(...
    'gradient', XlocalSensitivity,'lines', 25, 'batches', 2, ...
    'points', 0.5:0.5:3.5, 'seed', 49564);

% Run reliability analysis
XfailureProbLS = XLS.computeFailureProbability(XprobModelBeamMatlab);

% Show Results
display(XfailureProbLS);

% Validate Solution
assert(abs(XfailureProbLS.Value-0.069097) < 1e-4 * 0.069097,...
    'CossanX:Tutorials:CantileverBeam',...
    'Estimated failure probability (%e) does not match the reference Solution (%e)',...
    XfailureProbLS.Value, 0.069097)

%% Plot Results
% f1 = Xout.plotLines;

%% Close figure
% close(f1);

%% Optimization
% This tutorial continues with the optimization section
% See Also:  <TutorialCantileverBeamMatlabOptimization.html> 

% echodemo TutorialCantileverBeamMatlabOptimization

%% RELIABILITY BASED OPTIMIZAZION 
% The reliability based optimization is shown in the following tutotial 
% See Also: <TutorialCantileverBeamMatlabRBO.html>

% echodemo TutorialCantileverBeamMatlabRBO


