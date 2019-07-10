%% Tutorial for the Sensitivity analysis
%
% In this tutorial a very simplified model is considered.  
% 
% See Also: https://cossan.co.uk/wiki/index.php/Infection_Dynamic_Model
% 
%
% $Copyright~1993-2019,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ 


%% Problem setup
% In this examples we consider only 3 uniform random variables
Xrv1   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xrv2   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xrv3   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xrvset = RandomVariableSet('Cmembers',{'Xrv1','Xrv2','Xrv3'},'CXrandomvariables',{Xrv1,Xrv2,Xrv3});
Xin    = Input('XrandomVariableSet',Xrvset);

% The model is defined using a Mio object
Xm = Mio('Sscript','for j=1:length(Tinput), Toutput(j).out1=Tinput(j).Xrv1^2+2*Tinput(j).Xrv2-Tinput(j).Xrv3; end', ...
         'Coutputnames',{'out1'},...
         'Cinputnames',{'Xrv1' 'Xrv2' 'Xrv3'},...
         'Liostructure',true,...
	     'Lfunction',false); 
     
Xev    = Evaluator('Xmio',Xm);
Xmdl   = Model('Xinput',Xin,'Xevaluator',Xev);

% Here we go!!!
%% Local Sensitivity Analysis
% To start with, we compute the local sensitivity analysis based on Finite
% Differnce Methos

XlsMC=LocalSensitivityMonteCarlo('Xmodel',Xmdl);
display(XlsMC)

% Compute the LocalSensitivityMeasure
Xsm = XlsMC.computeIndices;
display(Xsm)

% Compute the Gradient
Xgrad = XlsMC.computeGradientStandardNormalSpace;
display(Xgrad)


% Please notice that the Gradient method based on MonteCarlo simulation produces
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
