%% Tutorial for the Sensitivity analysis
% The tutorial InfectionDynamicModel expains in very details how to use the
% Sensitivity Toolbox. For this reason the uses is invited to check the
% tutorial InfectionDynamicModel. 
%
% In this tutorial a very simplified model is considered.  
% 
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Infection_Dynamic_Model
% 
%
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

% $Author: Edoardo-Patelli$ 
clear
close all
clc;

%% Problem setup
% In this examples we consider only 3 uniform random variables
Xrv1   = opencossan.common.inputs.random.UniformRandomVariable('bounds',[-1,1]);
Xrv2   = opencossan.common.inputs.random.UniformRandomVariable('bounds',[-1,1]);
Xrv3   = opencossan.common.inputs.random.UniformRandomVariable('bounds',[-1,1]);
Xrvset = opencossan.common.inputs.random.RandomVariableSet('names',{'Xrv1','Xrv2','Xrv3'},'members',[Xrv1;Xrv2;Xrv3]);
Xin    = opencossan.common.inputs.Input('description','Input LocalSensitivity');
Xin = add(Xin,'member',Xrvset,'name','Xrvset');

% The model is defined using a Mio object
Xm = opencossan.workers.Mio('Script','for j=1:length(Tinput), Toutput(j).out1=Tinput(j).Xrv1^2+2*Tinput(j).Xrv2-Tinput(j).Xrv3; end', ...
         'OutputNames',{'out1'},...
         'InputNames',{'Xrv1' 'Xrv2' 'Xrv3'},...
 ...        'Liostructure',true,...
	     'IsFunction',false); 
     
Xev    = opencossan.workers.Evaluator('Xmio',Xm);
Xmdl   = opencossan.common.Model('Input',Xin,'evaluator',Xev);

% Here we go!!!
%% Local Sensitivity Analysis
% To start with, we compute the local sensitivity analysis based on Finite
% Differnce Methos

XlsMC=opencossan.sensitivity.LocalSensitivityMonteCarlo('Xmodel',Xmdl);
display(XlsMC)

% Compute the LocalSensitivityMeasure
Xsm = XlsMC.computeIndices;
display(Xsm)

% Compute the Gradient
Xgrad = XlsMC.computeGradientStandardNormalSpace;
display(Xgrad)


% Plese notice that the Gradient method based on MonteCarlo simulation produces
% an approximate value of the gradient. It should be used only in high space
% (i.e. number of input > 50) since it allows to reduce significantly the
% conputational efforts

% The localFiniteDifference and the localMonteCarlo methods returns a
% LocalSensitivityMeasure and not a Gradient object. 

% WARNING!!! The other of reference point should be consistent with the
% order of the variable present in the model.
XlsMC=LocalSensitivityMonteCarlo('Xmodel',Xmdl,'VreferencePoint',[0.5 0.4 0.2]);
Xgrad = XlsMC.computeGradientStandardNormalSpace;
display(Xgrad);
