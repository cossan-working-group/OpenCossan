%% Tutorial 6 storey Building FEAP: Sensitivity Analyis
%
% This tutorial shows how to perform LocalSensitivity analysis (i.e. compute the
% gradient) of a multi-storey building model
% 
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

%% Create the model
run('TutorialBuildingFeap');


%% Compute the Gradient of the model 
% Around the origin in standard normal space

% In order compute the gradient the static method gradient of the
% Sensitivity toolbox must be invoked
Xgfd=Sensitivity.gradientFiniteDifferences('Xtarget',Xmdl);
display(Xgfd)

Xg=Sensitivity.gradientMonteCarlo('Xtarget',Xmdl,'Nsimulations',7);
% The gradient output contains 
display(Xg)

% Gradient in a different reference point
Xg=Sensitivity.gradientMonteCarlo('Xtarget',Xmdl,'Nsimulations',7,'CnamesRandomVariable',{'RV_1' 'RV_3'},'VreferencePoint',[0 4]);
display(Xg)


Xg=Sensitivity.gradientMonteCarlo('Xtarget',Xmdl,'Nsimulations',50);

error=Xgfd.Vgradient+Xg.Vgradient


%% Test with a very large model 
RV=RandomVariable('Sdistribution','normal','mean',0,'std',1);
Xrvs2=RandomVariableSet('Xrv',RV,'Nrviid',250);
Xin = Input('Sdescription','TestGradient');
Xin = add(Xin,Xrvs2);

% Construct a Mio object
Xm2=Mio('Sdescription', 'Performance function', ...
                'Sscript','Moutput=Minput(:,1).^2+5*Minput(:,2)-0.1*Minput(:,3)+0.01*Minput(:,4);', ...
                'Liomatrix',true,...
                'Liostructure',false,...
				'Lfunction',false, ...
                'Cinputnames',{'RV_1' 'RV_2' 'RV_3' 'RV_4' 'RV_5'}, ...
                'Coutputnames',{'out1'}); % This flag specify if the .m file is a script or a function. 

% Construct the Evaluator
Xeval2 = Evaluator('Xmio',Xm2,'Sdescription','fist Evaluator');

Xmdl2=Model('Xinput',Xin,'Xevaluator',Xeval2);
Xg2=Sensitivity.gradientMonteCarlo('Xtarget',Xmdl2,'Nsimulations',7);
display(Xg2)
