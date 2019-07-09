%% TutorialCantileverBeamMatlabReliabilityAnalysis
%
% The documentation and the problem description of this example is available on
% the User Manual -> Tutorials -> Cantilever_Beam
%
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/Cantilever_Beam
%
% <html>
% <h3 style="color:#317ECC">Copyright 2006-2014: <b> COSSAN working group</b></h3>
% Author: <b>Edoardo-Patelli</b> <br> 
% <i>Institute for Risk and Uncertainty, University of Liverpool, UK</i>
% <br>COSSAN web site: <a href="http://www.cossan.co.uk">http://www.cossan.co.uk</a>
% <br><br>
% <span style="color:gray"> This file is part of <span style="color:orange">openCOSSAN</span>.  The open source general purpose matlab toolbox
% for numerical analysis, risk and uncertainty quantification (<a
% href="http://www.cossan.co.uk">http://www.cossan.co.uk</a>).
% <br>
% <span style="color:orange">openCOSSAN</span> is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
% <span style="color:orange">openCOSSAN</span> is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. 
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses/"</a>.
% </span></html>


%% Require input 
% This tutorial requires the Model create by the tutorial TutorialCantileverBeamMatlab

assert(logical(exist('XmodelBeamMatlab','var')),'openCOSSAN:Tutorial', ...
    'Please run first the tutorial TutorialCantileverBeamMatlab')


% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
opencossan.OpenCossan.resetRandomNumberGenerator(51125);

%% Define a Probabilistic Model
% Performance Function
Xperfun = opencossan.reliability.PerformanceFunction('OutputName','Vg','Demand','w','Capacity','maxDisplacement');
% Define a Probabilistic Model
XprobModelBeamMatlab=opencossan.reliability.ProbabilisticModel('Model',XmodelBeamMatlab,'PerformanceFunction',Xperfun);

%% Reliability Analysis via Monte Carlo Sampling
% The Monte Carlo simulation is used here to estimate the failure probability

% Compute Reference Solution
Xmc=opencossan.simulations.MonteCarlo('Nsamples',1e4,'Nbatches',1);

% Run Reliability Analysis
XfailureProbMC=Xmc.computeFailureProbability(XprobModelBeamMatlab);
% Show the estimated failure probability
display(XfailureProbMC);

% Validate Solution
assert(abs(XfailureProbMC.pfhat-7.38e-02)<eps,...
    'CossanX:Tutorials:CantileverBeam','Reference Solution pf MCS not matched.')

%% Reliability Analysis via Latin Hypercube Sampling
% Definition of the Simulation object
Xlhs=opencossan.simulations.LatinHypercubeSampling('Nsamples',1e3);
% Run Reliability Analysis
XfailureProbLHS=Xlhs.computeFailureProbability(XprobModelBeamMatlab);
% Show the estimated failure probability
display(XfailureProbLHS);

% Validate Solution
assert(abs(XfailureProbLHS.pfhat-8.30e-02)<eps,...
    'CossanX:Tutorials:CantileverBeam','Reference Solution pf LHS not matched.')

%% Reliability Analysis via LineSampling
% Line Sampling requires the definition of the so-called important direction.
% It can be computed usig the sensitivity method. For instance here the Local
% Sensitivity Analysis is computed.

XlsFD=opencossan.sensitivity.LocalSensitivityFiniteDifference('Xmodel',XprobModelBeamMatlab,'Coutputname',{'Vg'});
display(XlsFD)

% Compute the LocalSensitivityMeasure
XlocalSensitivity = XlsFD.computeIndices;

opencossan.OpenCossan.resetRandomNumberGenerator(49564);
% Use sensitivity information to define the important direction for LineSampling
XLS=opencossan.simulations.LineSampling('XlocalSensitivityMeasures',XlocalSensitivity,'Nlines',50);
% Run Analysis
[XfailureProbLS, Xout]=XLS.computeFailureProbability(XprobModelBeamMatlab);
% Show Results
display(XfailureProbLS);
display(Xout);

% Validate Solution
assert(abs(XfailureProbLS.pfhat-6.085e-002)<2e-5,...
    'CossanX:Tutorials:CantileverBeam',...
    'Estimated failure probability (%e) does not match the reference Solution (%e)',...
    XfailureProbLS.pfhat,6.1e-002)

%% Plot Results
% show lines 
f1=Xout.plotLines;

%% Close figure
close(f1);

% % Line Sampling with adaptive method (under development)
% XLS=LineSampling('XlocalSensitivityMeasures',XlocalSensitivity,'Nlines',20,'Ladaptive',true);
% XfailureProbLS2=XLS.computeFailureProbability(XprobModelBeamMatlab);
% display(XfailureProbLS2);

% % Validate Solution
% assert(abs(XfailureProbLS2.pfhat-5.992e-02)<1e-4,...
%     'CossanX:Tutorials:CantileverBeam',...
%     'Estimated failure probability (%e) does not match the reference Solution (%e)',...
%     XfailureProbLS2.pfhat,5.992e-02)

%% Optimization
% This tutorial continues with the optimization section
% See Also:  <TutorialCantileverBeamMatlabOptimization.html> 

% echodemo TutorialCantileverBeamMatlabOptimization

%% RELIABILITY BASED OPTIMIZAZION 
% The reliability based optimization is shown in the following tutotial 
% See Also: <TutorialCantileverBeamMatlabRBO.html>

% echodemo TutorialCantileverBeamMatlabRBO


