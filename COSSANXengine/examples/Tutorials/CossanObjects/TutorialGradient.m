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
% See Also: Gradient TutorialLocalSensitivityFiniteDifference
%
% $Copyright~1993-2019,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ 


%% Define a Model 
% Define an Input
% Define Random Variables 
RV1=RandomVariable('Sdistribution','normal', 'mean',1,'std',1);  %#ok<SNASGU>
RV2=RandomVariable('Sdistribution','normal', 'mean',1,'std',1);  %#ok<SNASGU>
RV3=RandomVariable('Sdistribution','normal', 'mean',1,'std',1);  %#ok<SNASGU>
RV4=RandomVariable('Sdistribution','normal', 'mean',1,'std',1);  %#ok<SNASGU>
% Define the RVset
Xrvs1=RandomVariableSet('Cmembers',{'RV1', 'RV2', 'RV3', 'RV4'}); 
% Define Xinput
Xin = Input('Sdescription','Gradient Tutorial Input','Xrandomvariableset',Xrvs1);

% Construct a Mio object that defines the model
Xm=Mio('Sdescription', 'Performance function', ...
                'Sscript','for j=1:length(Tinput), Toutput(j).out1=2+Tinput(j).RV1^2+5*Tinput(j).RV2^2+0.01*Tinput(j).RV4^2; end', ...
                'Liostructure',true,...
				'Lfunction',false, ...
                'Cinputnames',{'RV1' 'RV2' 'RV3' 'RV4'},...
                'Coutputnames',{'out1'}); % This flag specify if the .m file is a script or a function. 

% Construct the Evaluator
Xeval1 = Evaluator('Xmio',Xm,'Sdescription','fist Evaluator');

%  Construct the Model 
Xmdl=Model('CXmembers',{Xin,Xeval1});

% Show Model details
display(Xmdl)

%% Compute the Gradient of the model 
% Define a LocalSensitivity object to calculate the gradient. 

XlsFD=LocalSensitivityFiniteDifference('Xmodel',Xmdl);
display(XlsFD)

% If the reference point is not provided the gradient is calculared around
% the mean values of the random variables (as returned by the method
% getDefaultValuesStructure of the Input class.

TreferencePoint=Xin.getDefaultValuesStructure;

% The LocalSensitivityFiniteDifference computes the gradient invoking the
% method computeGradient

% Compute the LocalSensitivityMeasure
Xgrad = XlsFD.computeGradient;
display(Xgrad)

XlsFD=LocalSensitivityFiniteDifference('Xmodel',Xmdl,'VreferencePoint',[1 2 3 4]);
display(XlsFD)

Xgrad2 = XlsFD.computeGradient;
display(Xgrad2)

%% Show results
% The Gradient class provides methods to display the results

Xgrad.plotComponents;

% Custumize the plot. 
Xgrad.plotComponents('Nmaxcomponents',2,'Stitle','Finite difference custum title');


Xgrad.plotPie;

% To save a picture as PDF pass the name of the figure
Xgrad.plotPie('Sfigurename','PieGradient','Sexportformat','pdf')

% The figure is saved in the current working path setted by OpenCossan

% Show current working path
OpenCossan.getCossanWorkingPath




