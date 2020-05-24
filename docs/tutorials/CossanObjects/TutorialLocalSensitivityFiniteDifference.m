%% Tutorial for the Local Sensitivity analysis using Finite Difference approach 
%
% The tutorial InfectionDynamicModel expains in very details how to use the
% Sensitivity Toolbox. For this reason the uses is invited to check the
% tutorial InfectionDynamicModel. 
%
% In this tutorial very simplified models are considered. Nevertheless, it
% allows to understand how the LocalSensitivity* methods works in
% OpenCossan. 
% 
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Infection_Dynamic_Model
% 
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$ 
clear
close all
clc;

%% Problem setup
% In this first examples we consider only 3 uniform random variables and
% the aim is to compute the gradient in the Physical Space. 

% Defination of the input
Xrv1   = opencossan.common.inputs.random.UniformRandomVariable('bounds',[-1,0]);
Xrv2   = opencossan.common.inputs.random.UniformRandomVariable('bounds',[-1,1]);
Xrv3   =opencossan.common.inputs.random.UniformRandomVariable('bounds',[-1,1]);
Xrvset = opencossan.common.inputs.random.RandomVariableSet('names',{'Xrv1','Xrv2','Xrv3'},'members',[Xrv1;Xrv2;Xrv3]);
Xin    = opencossan.common.inputs.Input('members',Xrvset, 'membersnames','Xrvset');

% The model is defined using a Mio object
Xm = opencossan.workers.MatlabWorker('Script','for j=1:length(Tinput), Toutput(j).out1=Tinput(j).Xrv1^2+2*Tinput(j).Xrv2-Tinput(j).Xrv3; end', ...
         'OutputNames',{'out1'},...
         'InputNames',{'Xrv1' 'Xrv2' 'Xrv3'},...
	     'IsFunction',false); 
     
Xev    = opencossan.workers.Evaluator('Solver',Xm);
Xmdl   = opencossan.common.Model('Input',Xin,'Evaluator',Xev);

% Here we go!!!
%% Local Sensitivity Analysis
% To start with, we compute the local sensitivity analysis based on Finite
% Differnce Method
XlsFD=LocalSensitivityFiniteDifference('Xmodel',Xmdl);
display(XlsFD)

% The LocalSensitivityFiniteDifference has 2 methods to compute the
% LocalSensitivityMeasure and not a Gradient object. 

% Compute the LocalSensitivityMeasure
Xsm = XlsFD.computeIndices;
display(Xsm)

% Compute the Gradient
Xgrad = XlsFD.computeGradient;
display(Xgrad)


%% Select a user defined point
XlsFD2=LocalSensitivityFiniteDifference('Xtarget',Xmdl,...
    'VreferencePoint',[0.5 0.4 0.2],'Cinputnames',{'Xrv1','Xrv2','Xrv3'});
display(XlsFD2)

Xgrad2 = XlsFD2.computeGradient;
display(Xgrad2)

%% Test Gradient with DesignVariables

DV1 = DesignVariable('value',30,'minvalue',10,'maxvalue',50);
DV2 = DesignVariable('value',30,'minvalue',20,'maxvalue',40);

Xin   = Input('Sdescription','Input Object of our model',...
    'CXmembers',{DV1 DV2},'CSmembers',{'DV1' 'DV2'});

Sscript=['for i=1:length(Tinput),'...
    'Toutput(i).Out1   = 2*Tinput(i).DV1-Tinput(i).DV2^2;'...
    'end'];

XmDV  = opencossan.workers.MatlabWorker('Description', 'Performance function', ...
                'Script',Sscript, ... % Define the script
                'OutputNames',{'Out1'},... % This field is mandatory
                'InputNames',{'DV1';'DV2'},...    % This field is mandatory
                'Format','structure');
            
Xev     = opencossan.workers.Evaluator('Solver',XmDV);
% Define probmodel
Xmodel  = opencossan.common.Model('Xnput',Xin,'Evaluator',Xev);     

%% Select a user defined point
XlsFD2=LocalSensitivityFiniteDifference('Xtarget',Xmodel,...
    'VreferencePoint',[25 30],'Cinputnames',{'DV1','DV2'});

Xgrad2 = XlsFD2.computeGradient;
display(Xgrad2)

% Reference solution [2 -60]


%% Second Example
% In this second example we consider only 2 correlated gaussian random
% variables and a very simple model $y=-2x_1+x_2-2$

% define the input
Xrv1   = RandomVariable('Sdistribution','normal','mean',0,'std',1);
Xrv2   = RandomVariable('Sdistribution','normal','mean',2,'std',1);
Xrvset = RandomVariableSet('Cmembers',{'Xrv1','Xrv2'},'CXrandomvariables',{Xrv1,Xrv2},'Mcorrelation',[1 0.666; 0.666 1]);
Xin    = Input('XrandomVariableSet',Xrvset);

% Plot the correlation 
Xin=Xin.sample('Nsamples',1000);
f1=figure;
hf1=gca(f1);
plotmatrix(hf1,Xin.Xsamples.MsamplesPhysicalSpace)
title(hf1,'Samples in Physical Space')
f2=figure;hf2=gca(f2);
plotmatrix(hf2,Xin.Xsamples.MsamplesStandardNormalSpace)
title(hf2,'Samples in Standard Normal Space')

% The figures show the correlation of the sample in physical space. 

% The model is defined using a Mio object
Xm = opencossan.workers.MatlabWorker('Script','for j=1:length(Tinput), Toutput(j).out1=-2*Tinput(j).Xrv1+(Tinput(j).Xrv2-2); end', ...
         'OutputNames',{'out1'},...
         'InputNames',{'Xrv1' 'Xrv2'},...
         'Format','structure'); 
     
Xev    = Evaluator('Solver',Xm);
Xmdl   = Model('Input',Xin,'Evaluator',Xev);

% Define the Local Sensitivity method 
XlsFD=LocalSensitivityFiniteDifference('Xmodel',Xmdl);
display(XlsFD)

% Compute the gradient
[Xgrad,Xout] = XlsFD.computeGradient;
% Compute the gradient in standard normal space
[XgradSNS,XoutSNS] = XlsFD.computeGradientStandardNormalSpace;

% Show the results of the Gradient evaluation
% The perturbation points are evaluted in the Physical Space
display(Xgrad)
assert(all(Xgrad.Vgradient==[-2;1]),'OpenCossan:TutorialLocalSensitivityFiniteDifference','Results do not match with the reference solution')

% Show the results of the Gradient evaluation 
% The perturbation points are evaluted in the Standard Normal Space
display(XgradSNS)
assert(sum(abs(XgradSNS.Vgradient -[1.226; -0.913]))<1e-3,'OpenCossan:TutorialLocalSensitivityFiniteDifference','Results do not match with the reference solution')

% Plot the evaluation points in both spaces
M1=Xout.getValues('Cnames',{'Xrv1','Xrv2'});
M2=XoutSNS.getValues('Cnames',{'Xrv1','Xrv2'});

% Points in the standard normal space
U1=Xin.map2stdnorm(M1);
U2=Xin.map2stdnorm(M2);

% plot figures
f3=figure;
subplot 211
h3=gca(f3);
scatter(h3,M1(:,1),M1(:,2))
hold
scatter(h3,M2(:,1),M2(:,2),'r')
subplot 212
h3=gca(f3);
scatter(h3,U1(:,1),U1(:,2))
hold
scatter(h3,U2(:,1),U2(:,2),'r')


%% Close files
close all
