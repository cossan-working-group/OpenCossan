%% Tutorial for the Gradient object 
% 
%
% This tutorial is based on the Model tutorial for the definition of the 
% inputs, the mio object and the physical model.
%
% The model is a simple function: 
%   $y=2+x_1^2+5*x_2^2+0.01*x_4^2$ 
% where x1, x2, x3, x4 are modelled as random variables (RV1,...,RV4)
% 
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Gradient
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$ 
clear;
close all
clc;

%% Define a Model 
% Define an Input
% Define Random Variables 
RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',1,'std',1);  %#ok<SNASGU>
RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',1,'std',1);  %#ok<SNASGU>
RV3=opencossan.common.inputs.random.NormalRandomVariable('mean',1,'std',1);  %#ok<SNASGU>
RV4=opencossan.common.inputs.random.NormalRandomVariable('mean',1,'std',1);  %#ok<SNASGU>
% Define the RVset
Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2', 'RV3', 'RV4'}, 'members',[RV1; RV2; RV3; RV4;]); 
% Define Xinput
Xin = opencossan.common.inputs.Input('description','Gradient Tutorial Input');
Xin = add(Xin,'name','Xrvs1','member',Xrvs1);

% Construct a Mio object that defines the model
Xm=opencossan.workers.Mio('description', 'Performance function', ...
                'Script','for j=1:length(Tinput), Toutput(j).out1=2+Tinput(j).RV1^2+5*Tinput(j).RV2^2+0.01*Tinput(j).RV4^2; end', ...
...                'Liostructure',true,...
				'IsFunction',false, ...
                'InputNames',{'RV1' 'RV2' 'RV3' 'RV4'},...
                'OutputNames',{'out1'}); % This flag specify if the .m file is a script or a function. 

% Construct the Evaluator
Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','fist Evaluator');

%  Construct the Model 
Xmdl=opencossan.common.Model('CXmembers',{Xin,Xeval1});

% Show Model details
display(Xmdl)

%% Compute the Gradient of the model 
% Around the origin in standard normal space

% In order compute the gradient the Local Sensitivity Analysis needs to be used
% For instance LocalSensitivityFiniteDifference can be used to estimate the
% Gradient by means of the finite difference method.

% Prepare the Local sensitivity Problem
Xlocal=opencossan.sensitivity.LocalSensitivityFiniteDifference('Xtarget',Xmdl);
display(Xlocal)

% Compute the gradient
Xg=Xlocal.computeGradient;
% Show the results
display(Xg)

% The Xtarget object must contain the quantity of interest
% If Xtarget provides more then 1 output the optional parameter Coutputname 
% can be used to define the quantity of interest.
Xlocal=LocalSensitivityFiniteDifference('Xtarget',Xmdl,'Coutputname',{'out1'});
Xg=Xlocal.computeGradient;
% Show the results
display(Xg)

% If teh simulation at the reference point is available the gradient can be computed reusing
% this sample.
% An Samples object containing the samples and the corresponding value of
% the quantity of interest have to be passed as optional arguments.
Xlocal=LocalSensitivityFiniteDifference('Xtarget',Xmdl,'perturbation',1e-8);
Xg=Xlocal.computeGradient;
% Show the results
display(Xg)

% Use reference point defined in the Samples Object
Xin=Xin.sample('Nsamples',1);
Xs=Xin.Xsamples;
Xout=Xmdl.apply(Xs);

%% Estimate the gradient via Monte Carlo sampling
% Monte Carlo method can only be used to estimate the gradient in Standard
% Normal Space or to estimate the local sensitivity measures. 
Xlocal=LocalSensitivityMonteCarlo('Xtarget',Xmdl,'Nsamples',100);
% The gradient output contains 
display(Xlocal)

Xg2=Xlocal.computeGradientStandardNormalSpace;
display(Xg2)

Xg3=Xlocal.computeIndices;

% Add components to the same figure
h1=Xg2.plotComponents('Stitle','Gradient in StandardNormalSpace','Scolor','m','Nmaxcomponents',3);

% Close figure
close(h1)




