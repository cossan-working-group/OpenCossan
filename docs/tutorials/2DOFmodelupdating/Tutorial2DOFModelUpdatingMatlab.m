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
opencossan.OpenCossan.resetRandomNumberGenerator(51125);

%% Preparation of the parameters and random variables
% Definition of the Parameters using 'Parameter' constructor from OpenCossan
F1=opencossan.common.inputs.Parameter('value',2.0,'description','Applied Load in node 1');
F2=opencossan.common.inputs.Parameter('value',1.0,'description','Applied Load in node 2');
k1real=opencossan.common.inputs.Parameter('value',1.0,'description','Stiffness of spring 1');
k2real=opencossan.common.inputs.Parameter('value',1.0,'description','Stiffness of spring 2');

k1=opencossan.common.inputs.Parameter('value',0.5,'description','Stiffness of spring 1');
k2=opencossan.common.inputs.Parameter('value',1.4,'description','Stiffness of spring 2');

% Definition of the Random Variables to simulate synthetic data using
% 'RandomVariable' constructor from OpenCossan
p1=opencossan.common.inputs.random.NormalRandomVariable('mean',0.0,'std',1.0,'description','randomperturbation for measured displacement 1');
p2=opencossan.common.inputs.random.NormalRandomVariable('mean',0.0,'std',1.0,'description','randomperturbation for measured displacement 2');
% Gathering random data into a single structure set using
% 'RandomVariableSet' from OpenCossan
Xrvset=opencossan.common.inputs.random.RandomVariableSet('members',[p1 p2],'names',["p1" "p2"]);

%%---------------Simulations to built Synthetic ExperimentalData-----------
%  ------------------------------------------------------------------------
% Create a new model to simulate perturbed data, inputs forces, stiffness and randon displacement
% output values with random noise
% Create Input values using 'Input' constructor from OpenCossan
XinputPert=opencossan.common.inputs.Input('Members',{F1 F2 k1real k2real Xrvset},'Names',["F1" "F2" "k1" "k2" "Xrvset"]);
display(XinputPert); %It could also be:  Xinput.display
Sfolder=fileparts(which('Tutorial2DOFModelUpdatingMatlab.m')); % returns the current folder
% Prepare the perturbed Model by 'mio' constructor from OpenCossan using a
% matlab script that is coded to handle the random vector to be added to the output
% displacements (to simulate synthetic data)
XmioPert=opencossan.workers.Mio('FullFileName',fullfile(Sfolder,'MatlabModel','displacementsPerturbation.m'),...
    'inputnames',{'F1' 'F2' 'k1' 'k2', 'p1','p2'}, ...
    'outputnames',{'y1' 'y2'},...
    'format','structure');
% Add the 'mio' constructor to 'Evaluator' constructor from OpenCOssan
XevaluatorPert=opencossan.workers.Evaluator('CXmembers',{XmioPert},'CSmembers',{'XmioPert'});
% Defining the Physical Model by the 'Model' constructor from OpenCossan
XmodelPert=opencossan.common.Model('input',XinputPert,'evaluator',XevaluatorPert);
% Prepare 'MonteCarlo' constructor from OpenCossan
Xmc=opencossan.simulations.MonteCarlo('Samples',100);
% Perform Monte Carlo simulation using 'Apply' method
XsyntheticData=Xmc.apply(XmodelPert);
% Display the resulted outputs
XsyntheticData.Samples{:,{ 'F1' 'F2' 'y1' 'y2' }};

%% --------------------------Deterministic Analysys------------------------
%  ------------------------------------------------------------------------
% Prepare Input Object using 'Input' constructor from OpenCossan
% The previously prepared Parameters should be added together to an 'Xinput' Object
Xinput=opencossan.common.inputs.Input('Members',{F1 F2 k1real k2real},'Names',{'F1' 'F2' 'k1' 'k2'});
% Show summary of the Input Object using 'Display' Method from OpenCossan
display(Xinput); %It could also be :  Xinput.display
% It will be used a matlab script to compute the the 2DOF displacements
Sfolder=fileparts(which('Tutorial2DOFModelUpdatingMatlab.m')); % returns the current folder
% Preparation for the Evaluator defining Input-Output method by 'mio' constructor from OpenCossan
Xmio=opencossan.workers.Mio(... %Pass Input/output names to the Matlab-Input-Output object
    'FullFileName',fullfile(Sfolder,'MatlabModel','displacements.m'),...
    'inputnames',{'F1' 'F2' 'k1' 'k2'}, ...
    'outputnames',{'y1' 'y2'},...
    'format','structure');
% Add the 'mio' constructor to the 'Evaluator' constructor
Xevaluator=opencossan.workers.Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});
%% Preparation of the Physical Model
% Defining the Physical Model by the 'Model' constructor from OpenCossan
Xmodel2DOFModelUpdatingMatlab=opencossan.common.Model('input',Xinput,'evaluator',Xevaluator);
%% Perform deterministic analysis to obtain deterministic values for the
% displcaments using 'deterministicAnalysis' method from OpenCossan aaplied
% to the constructed 'Model' knwon as  Xmodel2DOFModelUpdatingMatlab
XupdatedModel=deterministicAnalysis(Xmodel2DOFModelUpdatingMatlab); %It could also be  Xout=Xmodel2DOFModelUpdatingMatlab.deterministicAnalysis
%% Get the output values from this deterministic analysis (that is contained
% in Xout)
ActualDisplacements=XupdatedModel.Samples{:,{'y1' 'y2'}};

%% ---------------------------Model Updating-------------------------------
%  ------------------------------------------------------------------------
%Define the Model such as the input values contain the Synthetic data (can
%be alo experimental ones)
Xinput=opencossan.common.inputs.Input('Members',{F1 F2 k1 k2},'Names',{'F1' 'F2' 'k1' 'k2'});
Xmodel2DOFModel=opencossan.common.Model('input',Xinput,'evaluator',Xevaluator);
% Show summary of the Input Object using 'Display' Method from OpenCossan
display(Xinput); %It could also be :  Xinput.display
%Defining the 'ModelUpdating' constructor
% The model updating analysis requires the definition of parameters of the
% model that that will be updated 'Cinputnames', the output variables that
% will be used to mount the error function 'Coutputnames', the
% Synthetic/Experimental data 'Xsimulationdata' and finally the model to be updated 'Xmodel'
VupperBounds=[2.0 2.0];
VlowerBounds=[0.1 0.1];
Xmupd=opencossan.inference.ModelUpdating('Sdescription','descriptors', ...
    'Cinputnames',{'k1' 'k2'}, ...
    'XupdatingData',XsyntheticData,...
    'Xmodel',Xmodel2DOFModel,...
    'VupperBounds',VupperBounds,...
    'VlowerBounds',VlowerBounds);
% Display the modelUpdating Object 'Coutputnames',{'y1' 'y2'}, ...
%display(Xmupd);
% Define the Optimization engine method as 'Cobyla' from OpenCossan
Xopt=opencossan.optimization.Cobyla('MaxIterations',100);
%Define the Weighting matrices for the error and regularisation in the same
%size as the output from the Xmodel2DOFModel
%We=eye(size(Xmupd.Xmodel.Xevaluator.Coutputnames,2)); %Weighting Error matrix
%Wt=eye(size(Xmupd.Xmodel.Xevaluator.Coutputnames,2)); %Weighting reguralisation matrix
We=[0.8 0.0;0.0 1.2]; %Weighting Error matrix
Wt=[0.8 0.0;0.0 1.2]; %Weighting reguralisation matrix
%Perform ModelUpdating using 'updateSensitivity' method applied to the
%constructed object 'Xmupd', using some parameters passed as input
%arguments
%---perform model updating ---without regularisation---
[XupdatedModel , Xoptimum]=Xmupd.updateSensitivity('Xoptimizer',Xopt,...
    'Luseregularization',false);
%  ------------------------------------------------------------------------
%Shows the optimazation results
display(Xoptimum)
%Get the design variables updated values  from the outputed model 'Xout' as
% the result of 'updateSensitivity' method
Tupdatedvalues=XupdatedModel.Input.getDefaultValues;
Vupdatedvalues=table2array(Tupdatedvalues(:,Xmupd.Cinputnames));
%Validate Solutions
%Define the expected values for the parameters k1 and  k2
Vreference=[ 1.003   0.9621];
assert(max(Vreference-Vupdatedvalues)<1e-3, 'Tutorial:Tutorial2DOFModelUpdating',...
    ['Solutions do not match reference values maybe because the random numbers are',...
    ' different for the realisation of sysnthetic data']);
%Perform ModelUpdating using 'updateSensitivity' method applied to the
%constructed object 'Xmupd', using some parameters passed as input
%arguments -
%---perform model updating---with regularisation----
[Xout2 , Xoptimum2]=Xmupd.updateSensitivity('Xoptimizer',Xopt,...
    'Regularizationfactor',0.1,...
    'Luseregularization',true,...
    'MWeighterror', We,...
    'MWeightregularisation',Wt);
%  ------------------------------------------------------------------------
%Shows the optimazation results
display(Xoptimum)
disp('Tutorial terminated successfully')