%% Tutorial for the Global Sensitivity analysis using Random Balance Method
% The tutorial InfectionDynamicModel expains in very details how to use the
% Sensitivity Toolbox. For this reason the uses is invited to check the
% tutorial InfectionDynamicModel. 
%
% In this tutorial a very simplified model is considered.  
% 
% See Also: Infection_Dynamic_Model Sensitivity
% 
%
% $Copyright~1993-2020,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ 
clear
close all
clc;
import opencossan.sensitivity.*
%% Problem setup
% In this examples we consider only 3 uniform random variables
Xrv1   = opencossan.common.inputs.random.UniformRandomVariable('bounds',[-1, 1]);
Xrv2   = opencossan.common.inputs.random.UniformRandomVariable('bounds',[-1, 1]);
Xrv3   = opencossan.common.inputs.random.UniformRandomVariable('bounds',[-1, 1]);
Xrvset = opencossan.common.inputs.random.RandomVariableSet('names',{'Xrv1','Xrv2','Xrv3'},'members',[Xrv1;Xrv2;Xrv3]);
Xin    = opencossan.common.inputs.Input('members',Xrvset,'membersnames','Xrvset');

% The model is defined using a Mio object
Xm = opencossan.workers.MatlabWorker('Script','for j=1:length(Tinput), Toutput(j).out1=Tinput(j).Xrv1^2+2*Tinput(j).Xrv2-Tinput(j).Xrv3; end', ...
         'OutputNames',{'out1'},...
         'InputNames',{'Xrv1' 'Xrv2' 'Xrv3'},...
	     'IsFunction',false); 
     
Xev    = opencossan.workers.Evaluator('Solver',Xm);
Xmdl   = opencossan.common.Model('Input',Xin,'Evaluator',Xev);

      
%% Global Sensitivity Analysis
% The global sensitivity analysis is independent of the reference points.
% There are different methods to estimate the global sensitivity analysis.

% The method randomBalanceDesign is a very rubust method to compute the first
% order sensitivity indicies. 

%% Define GlobalSensitivityRandomBalanceDesign object
Xgs=GlobalSensitivityRandomBalanceDesign('Xmodel',Xmdl,'Nbootstrap',1,'Nsamples',5);
display(Xgs)
Xsm = Xgs.computeIndices;
display(Xsm)
   