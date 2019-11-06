%% Tutorial2DOFModelUpdating:
% This script runs the 2 DOF model updating in the OpenCossan Engine
% The documentation and the problem description of this example is available on
% the User Manual -> Tutorials -> ModelUpdating
% See Also http://cossan.co.uk/wiki/index.php/

% $Copyright~1993-2015,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$ %



% Reset the random number generator in order to obtain always theme
% results. using the method 'resetRandomNumberGenerator' from OpenCossan

% DO NOT CHANGE THE VALUES OF THE SEED
%opencossan.OpenCossan.resetRandomNumberGenerator(51125);

%% Preparation of the parameters and random variables
% Definition of the Parameters using 'Parameter' constructor from OpenCossan

opencossan.OpenCossan.getVerbosityLevel

F1=opencossan.common.inputs.Parameter('value',2.0,'description','Applied Load in node 1');
F2=opencossan.common.inputs.Parameter('value',1.0,'description','Applied Load in node 2');
k1real=opencossan.common.inputs.Parameter('value',1.0,'description','Stiffness of spring 1');
k2real=opencossan.common.inputs.Parameter('value',1.0,'description','Stiffness of spring 2');

% Definition of the Random Variables to simulate synthetic data using
% 'RandomVariable' constructor from OpenCossan
p1=opencossan.common.inputs.random.NormalRandomVariable('mean',0.0,'std',1.0,'description','randomperturbation for measured displacement 1');
p2=opencossan.common.inputs.random.NormalRandomVariable('mean',0.0,'std',1.0,'description','randomperturbation for measured displacement 2');
% Gathering random data into a single structure set using
% 'RandomVariableSet' from OpenCossan
Xrvset=opencossan.common.inputs.random.RandomVariableSet('members',[p1; p2],'names',['p1'; 'p2']);

%%---------------Simulations to built Synthetic ExperimentalData-----------
%  ------------------------------------------------------------------------
% Create a new model to simulate perturbed data, inputs forces, stiffness and randon displacement
% output values with random noise
% Create Input values using 'Input' constructor from OpenCossan
XinputPert=opencossan.common.inputs.Input('Members',{F1, F2, k1real, k2real, Xrvset},'MembersNames',{'F1', 'F2', 'k1', 'k2', 'Xrvset'});
display(XinputPert); %It could also be:  Xinput.display
Sfolder=fileparts(which('Tutorial2DOFModelUpdatingMatlab.m')); % returns the current folder
% Prepare the perturbed Model by 'mio' constructor from OpenCossan using a
% matlab script that is coded to handle the random vector to be added to the output
% displacements (to simulate synthetic data)
XmioPert=opencossan.workers.Mio('FullFileName',fullfile(Sfolder,'MatlabModel/displacementsPerturbation.m'),...
    'inputnames',{'F1' 'F2' 'k1' 'k2', 'p1','p2'}, ...
    'outputnames',{'y1' 'y2'},...
    'Format', 'structure');
% Add the 'mio' constructor to 'Evaluator' constructor from OpenCOssan
XevaluatorPert=opencossan.workers.Evaluator('CXmembers',{XmioPert},'CSmembers',{'XmioPert'});
% Defining the Physical Model by the 'Model' constructor from OpenCossan
XmodelPert=opencossan.common.Model('input',XinputPert,'evaluator',XevaluatorPert);
% Prepare 'MonteCarlo' constructor from OpenCossan
Xmc=opencossan.simulations.MonteCarlo('Nsamples',100);
% Perform Monte Carlo simulation using 'Apply' method
XsyntheticData=Xmc.apply(XmodelPert);
% Display the resulted outputs
XsyntheticData.getValues('Cnames',{ 'F1' 'F2' 'y1' 'y2' });

%% --------------------------Deterministic Analysys------------------------
%  ------------------------------------------------------------------------

Xinput=opencossan.common.inputs.Input('Members',{F1 F2 k1real k2real},'MembersNames',{'F1' 'F2' 'k1' 'k2'});
display(Xinput);
Sfolder=fileparts(which('Tutorial2DOFModelUpdatingMatlab.m')); 

Xmio=opencossan.workers.Mio('FullFileName',fullfile(Sfolder,'MatlabModel/displacements.m'),...
    'inputnames',{'F1' 'F2' 'k1' 'k2'}, ...
    'outputnames',{'y1' 'y2'},...
    'Format', 'structure');


Xevaluator=opencossan.workers.Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});


Xmodel2DOFModelUpdatingMatlab=opencossan.common.Model('input',Xinput,'evaluator',Xevaluator);


Xout=deterministicAnalysis(Xmodel2DOFModelUpdatingMatlab); 


ActualDisplacements=Xout.getValues('Cnames',{'y1' 'y2'});

%% ---------------------------Model Updating-------------------------------
%  ------------------------------------------------------------------------


F1 = opencossan.common.inputs.Parameter('value',2.0,'description','Applied Load in node 1');
F2 = opencossan.common.inputs.Parameter('value',1.0,'description','Applied Load in node 2');

k1 = opencossan.common.inputs.random.UniformRandomVariable('bounds',[0.01,4],'description','Stiffness of spring 1');
k2 = opencossan.common.inputs.random.UniformRandomVariable('bounds',[0.01,4],'description','Stiffness of spring 2');


Xrvset = opencossan.common.inputs.random.RandomVariableSet('members',[k1; k2],'names',['k1'; 'k2']);

XinputBayes = opencossan.common.inputs.Input('Members',{F1, F2, Xrvset},'MembersNames',{'F1', 'F2','Xrvset'});
display(XinputBayes); 
Sfolder = fileparts(which('Tutorial2DOFModelUpdatingMatlab.m')); 

XmioBayes = opencossan.workers.Mio('FullFileName',fullfile(Sfolder,'MatlabModel/displacements.m'),...
    'inputnames',{'F1' 'F2' 'k1' 'k2'}, ...
    'outputnames',{'y1' 'y2'},...
    'Format', 'structure');


XevaluatorBayes = opencossan.workers.Evaluator('CXmembers',{XmioBayes},'CSmembers',{'XmioBayes'});

XmodelBayes = opencossan.common.Model('input',XinputBayes,'evaluator',XevaluatorBayes);

LogLike = opencossan.inference.LogLikelihood('Xmodel',XmodelBayes, 'Data', XsyntheticData, 'ShapeParameters', [0.1,0.1]);

Bayes = opencossan.inference.BayesianModelUpdating('Xmodel', XmodelBayes,'Xlog',LogLike ,'CoutputNames', {'k1', 'k2'}, 'Nsamples', 200);

Samps = applyTMCMC(Bayes);