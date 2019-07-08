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
Xin = Input('Sdescription','Gradient Tutorial Input');
Xin = add(Xin,Xrvs1);

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
% Around the origin in standard normal space

% In order compute the gradient the static method gradient of the
% Sensitivity toolbox must be invoked
% 
Xg=Sensitivity.gradientMonteCarlo('Xtarget',Xmdl);
display(Xg)

% The Xtarget object must contain the quantity of interest
% If Xtarget provides more then 1 output the optional parameter Coutputname 
% can be used to define the quantity of interest.

Xg=Sensitivity.gradientMonteCarlo('Xtarget',Xmdl,'Coutputname',{'out1'});

% If teh simulation at the reference point is available the gradient can be computed reusing
% this sample.
% An Samples object containing the samples and the corresponding value of
% the quantity of interest have to be passed as optional arguments.

Xg=Sensitivity.gradientFiniteDifferences('Xtarget',Xmdl,'perturbation',1e-8);
display(Xg)

% Use reference point defined in the Samples Object
Xin=Xin.sample('Nsamples',1);
Xs=Xin.Xsamples;
Xout=Xmdl.apply(Xs);

Xg=Sensitivity.gradientFiniteDifferences('Xtarget',Xmdl,'Xsamples',Xs,'FunctionValue',Xout.Tvalues.out1);
% The gradient output contains 
display(Xg)

Xg=Sensitivity.gradientMonteCarlo('Xtarget',Xmdl,'Xsamples',Xs);
% The gradient output contains 
display(Xg)

Xg2=Sensitivity.gradientFiniteDifferences('Xtarget',Xmdl);
display(Xg2)

% Add components to the same figure
h1=Xg2.plotComponents('Stitle','my title','Scolor','m','Nmaxcomponents',3);

% Close figure
close(h1)




