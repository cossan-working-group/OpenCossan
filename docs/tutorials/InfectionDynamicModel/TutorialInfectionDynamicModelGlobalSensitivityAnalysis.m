%% Tutorial Dynamic Model Global Sensitivity Analysis
% 
% This tutorial shows how to perform global sensitivity analysis of the
% Infection Dynamic Model. Plese see the tutorial TutorialInfectionDynamicModel
% for the problem definition.
% 
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Infection_Dynamic_Model
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

%% Define model
% Run the tutorial TutorialInfectionDynamicModel
run('TutorialInfectionDynamicModel');

assert(strcmp(Xmdl.Sdescription,'Model for TutorialInfectionDynamicModel'),...
      'CossanX:Tutorials:InfectionDynamicModel',...
      'Wrong model') 
  
%% Compute First order sensitivity measures by means Random Balance Design
% The sensitivity measures are here estimated using two different methods. The
% random balance design and the Saltelli's method.

% Define RandomBalanceDesign object
Nsamples=1280;
Xrbd=GlobalSensitivityRandomBalanceDesign('Nsamples',Nsamples,'Nbootstrap',100,...
    'Xmodel',Xmdl);
display(Xrbd)

Xsm1=Xrbd.computeIndices;
display(Xsm1)

% It is also possible to estimate the SensitivityMeasure for a specific input
% factors specifing the the input with the field CSinputnames. For instance:
% Xsm1 = Sensitivity.randomBalanceDesign('Xmodel',Xmdl, ...
%  'Nbootstrap',1,'Nsamples',1280,'CSinputnames',{ 'kappa' 'delta'})
 

%% Plot Results
% Plot histogramm of Y
f1=Xsm1.plot;

%% Close figure and validate solution
close(f1);
Vreference=[4.3600e-01 4.1978e-01 1.0654e-02 8.7441e-03];
% Validate Solution
assert(max(Xsm1.VsobolFirstIndices-Vreference)<1e-4,...
    'CossanX:Tutorials:InfectionDynamicModel',...
    'Reference Solution for the infection dynamic model does not match.')

%% Compute First order and total sensitivity 
% The first order and the total sensitivity indices are computed here by means
% of the Saltelli's method.  Saltelli's method is one of the most efficient way
% to estimate the first indices and total indices in one analysis. This algorithm
% is implemented in the method named sobolindices

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(357357)
Nsamples=2048;
Xmc=MonteCarlo('Nsamples',Nsamples);

Xsobol=GlobalSensitivitySobol('Xsimulator',Xmc,'Nbootstrap',100,...
    'Xmodel',Xmdl,'CSinputnames',{'delta' 'kappa' 'r' 'gamma' });
display(Xsobol)

Xsm2=Xsobol.computeIndices;
display(Xsm2)


%% Plot Results
% Plot histogramm of Y
f2=Xsm2.plot;

%% Close figure and validate solution
close(f2);
Vreference=[0.0093    0.5358    0.0093    0.5702];
% Validate Solution
assert(max(Xsm2.VtotalIndices-Vreference)<1e-4,...
    'CossanX:Tutorials:InfectionDynamicModel',...
    'Reference Solution for Total indices does not match.')

Vreference=[0.0450    0.5009    0.0450    0.4219];
% Validate Solution
assert(max(Xsm2.VsobolFirstIndices-Vreference)<1e-4,...
    'CossanX:Tutorials:InfectionDynamicModel',...
    'Reference Solution for First order indices does not match.')

%% Compute the upper bounds of the total indices
% The upper bounds of the total sensitivity indices can be computed using the
% stati method upperBound. It is a very efficient that required very few model
% evaluation.

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(722724)

XupperBounds=GlobalSensitivityUpperBound('Nsamples',50,'Nbootstrap',100,...
    'Xmodel',Xmdl);
display(XupperBounds)

Xsm3=XupperBounds.computeIndices;
display(Xsm3)

%% Plot Results
% Plot histogramm of Y
f3=Xsm3.plot;

%% Close figure and validate solution
close(f3);
% TODO Check reference values (Assertion failing)
Vreference=[70.9361   51.9572   15.3357    6.6088];
% Validate Solution6.4022e+01   6.6431e+01   8.5507e-04   8.4583e-04
assert(max(abs(Xsm3.VupperBounds-Vreference))<1e-3,...
    'CossanX:Tutorials:InfectionDynamicModel',...
    'Reference Solution for Upper Bounds indices does not match.')

