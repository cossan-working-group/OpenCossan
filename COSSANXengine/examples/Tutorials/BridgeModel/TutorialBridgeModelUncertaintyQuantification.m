%% TutorialBridgeModelUncertaintyQuantification
% In this tutorial a simple uncertainty quantification of a mechanical
% model of a long bridge is presented.
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/BridgeModel
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(46354)

%% Requirements
% This tutorial needs the mechanical model defined in the tutorial
% TutorialBridgeModel 

assert(logical(exist('XmodelBridge','var')),'openCOSSAN:Tutorials', ...
    'Please run first the tutorial TutorialBridgeModel\n\n run TutorialBridgeModel')

%% Perform Uncertainty Quantification using a quasi Monte Carlo methods
% The lating hypercube sampling method is used to generate samples in the
% multidimensional input space.
Xlhs=LatinHypercubeSampling('Nsamples',100);

% Perform simulation
XoutLHS=Xlhs.apply(XmodelBridge);

% Plot statistics of the output
f1=XoutLHS.plotData('Sname','maxDisplacement','Stitle','Bridge Model UQ (LHS)','Nfontsize',14);

% Show statistics of the output
Mstatistics=XoutLHS.getStatistics('Sname','maxDisplacement');

% Show Min, Max, Mean, median and std for maxDisplacement 
fprintf('* Min   : %e\n* Max   : %e\n* Mean  : %e\n* Median: %e\n* Std   : %e\n',...
    Mstatistics(:))



% Validate Solution
assert(abs(Mstatistics(3)- 4.20537e-03)<1e-6,...
    'CossanX:Tutorials:TutorialBridgeModel', ...
    'Nominal sulution does not match Reference Solution.')

%% Use sobol sampling
Xss=SobolSampling('Nsamples',1000);

% Perform simulation
XoutSS=Xss.apply(XmodelBridge);

% Plot statistics of the output
f2=XoutSS.plotData('Sname','maxDisplacement','Stitle','Bridge Model UQ (Sobol sampling)','Nfontsize',14);

Mstatistics=XoutLHS.getStatistics('Sname','maxDisplacement');

% Show Min, Max, Mean, median and std for maxDisplacement 
% Show Min, Max, Mean, median and std for maxDisplacement 
fprintf('* Min   : %e\n* Max   : %e\n* Mean  : %e\n* Median: %e\n* Std   : %e\n',...
    Mstatistics(:))

%% Scatter plot
% From the scatter plots it is possible to see if a correlation between some
% input factors and the maximum diplacement exist. However, this task can be
% performed in a more clear way using the Sensitivity methods.

Mdata=XoutSS.getValues('Cnames',{'k_2','maxDisplacement'});
f3=figure;
scatterhist(Mdata(:,1),Mdata(:,2))
xlabel('k_2');
ylabel('maxDisplacement');

%% Close figures
close(f1),close(f2),close(f3)

%% Global Sensitivity Analysis
% This tutorial continues with the optimization section
% See Also:  <TutorialBridgeModelGlobalSensitivityAnalysis.html> 

% echodemo TutorialBridgeModelGlobalSensitivityAnalysis
