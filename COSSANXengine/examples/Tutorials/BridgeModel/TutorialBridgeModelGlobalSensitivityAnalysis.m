%% TutorialBridgeModelGlobalSensitivityAnalysis
% In this tutorial the global sensitivity analysisl of a mechanical
% model of a long bridge is presented.
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/BridgeModel
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(46354)

%% First order sensitivity measure
% The most efficient way to compute the first order sensitivity analysis is by
% means of the random balance design method.

XsensitivityRBD=GlobalSensitivityRandomBalanceDesign('Xmodel',XmodelBridge,'Nsamples',1000);
XsensitivityMeasures1=XsensitivityRBD.computeIndices;
% Show results
display(XsensitivityMeasures1)

% Plot results
f1=XsensitivityMeasures1.plot;
f2=XsensitivityMeasures1.plot3d;

% These figures are not really readible because contain a large number of input
% variables.
% It is also possible to plot the results for the most important quantities.

% Identify most important components
[~,b]=sort(XsensitivityMeasures1.VsobolFirstIndices,'descend');

% Show the names of the most important components
CimportantComponents=XsensitivityMeasures1.CinputNames(b(1:10));
disp(CimportantComponents)

%% Plot the 10th most important factors
% Plot the 2d plot using the confindence interval for the error bars
f3=XsensitivityMeasures1.plot('CSnames',CimportantComponents,'LplotCov',false);
% Plot the 2d plot using the std of the estimated values for the error bar
f4=XsensitivityMeasures1.plot('CSnames',CimportantComponents,'LplotCov',true);
% plot 3d plot
f5=XsensitivityMeasures1.plot3d('CSnames',CimportantComponents);

%% Close figures
close(f1),close(f2),close(f3),close(f4),close(f5)

%% Compute First order and total order indices
% The Saltelli methods allows to compute the first order sensitivity analysis
% and the total indices during the same simulations.
% This method can be very computational demanding. For this reason only the total
% indices of the most important paramenter are computed.
Xlhs=LatinHypercubeSampling('Nsamples',4000);

XsensitivitySobol = GlobalSensitivitySobol('Xmodel',XmodelBridge, ...
    'CinputNames',CimportantComponents((1:10)),'Xsimulation',Xlhs);
XsensitivityMeasures2=XsensitivitySobol.computeIndices;

% Show results
display(XsensitivityMeasures2)
% plot figures. The plot now contains also the total sensitivity indices.
f1=XsensitivityMeasures2.plot;

%% Compute upper bounds of the total sensitivity indices
% The computational cost of the upper bounds for the total indices depends on
% the number of input factors. In fact, it is necessary to compute the gradient
% for each point of the markov chain. Hence the number of model evaluation
% increases with the number of input factors. However, an estimation of the
% gradient based on Monte Carlo sampling can be used instead of the gradient
% estimated by means of the finite difference method.  
% The Monte Carlo gradient estimation is especially efficient for a large number
% of imput factor (>20).

XsensitivityUpperBounds = GlobalSensitivityUpperBound('Xmodel',XmodelBridge,'Nsamples',100, ...
    'CSinputNames',CimportantComponents(1:10),'LfiniteDifference',true);
XsensitivityMeasures3=XsensitivityUpperBounds.computeIndices;

display(XsensitivityMeasures3)


f2=XsensitivityMeasures3.plot('LplotCov',false);

%% Merge Sensitivity Measures
XsensitivityMeasuresTot=XsensitivityMeasures1.merge(XsensitivityMeasures3);

display(XsensitivityMeasuresTot);

f3=XsensitivityMeasuresTot.plot('CSnames',CimportantComponents(1:10));

%% Final Remarks
% The sensitivity analysis of the Bridge Model has shown which components play a
% main role on the variability of the maximum displacement of the bridge.
% In particular, it seems that the most important sourse of variability are the
% beam heigths of the bay 4-6 and the stiffness of the supports (k_4 and k_6)
% the damping coefficient of the 4th support. All these components are very
% close to the application point of the external load.
% It is important to note that the estimated sensitivity indices have been
% estimate with a large confidence interval. For a more realible simulation it
% is suggested to re-run the analysis using a larger number of simulation points
% (e.g.  at least 1000 points for the upper bounds as shown in the follow lines)
%
% XsensitivityMeasures3=Sensitivity.upperBounds('Xmodel',XmodelBridge, ...
%    'CSinputNames',CimportantComponents(1:10),'LfiniteDifferences',true,...
%    'Nsamples',500);

%% Close figures
close(f1),close(f2),close(f3)
