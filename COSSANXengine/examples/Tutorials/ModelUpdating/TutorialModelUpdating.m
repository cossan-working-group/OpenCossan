%% Tutorial2DOFModelUpdating
%
% This script shows how to perform model updating of a 2 degree of freedom
% system.

% We want to identify the parameters of a system k1 and k2 from some
% measurements affected by noise. The displacement of a 2DOF system is
% computed by a script called displacement.m
% We used some generated data from a model called
% displacementsPerturbation.m where some random noise is added to the
% response of the system 


% See Also: ModelUpdating

% $Copyright~1993-2019,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ %

% Reset the random number generator in order to obtain always theme
% results. using the method 'resetRandomNumberGenerator' from OpenCossan

% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125);

%% Model inputs
% The parameters of the model are defined using Parameter class 
F1=Parameter('value',2.0,'Sdescription','Applied Load in node 1');
F2=Parameter('value',1.0,'Sdescription','Applied Load in node 2');
k1real=Parameter('value',1.0,'Sdescription','Stiffness of spring 1');
k2real=Parameter('value',1.0,'Sdescription','Stiffness of spring 2');

k1=Parameter('value',0.5,'Sdescription','Stiffness of spring 1');
k2=Parameter('value',1.4,'Sdescription','Stiffness of spring 2');

% Definition of the Random Variables to simulate synthetic data using
% 'RandomVariable' class 
p1=RandomVariable('Sdistribution','normal','mean',0.0,'std',1.0,...
    'Sdescription','randomperturbation for measured displacement 1');
p2=RandomVariable('Sdistribution','normal','mean',0.0,'std',1.0,...
    'Sdescription','randomperturbation for measured displacement 2');
% Gathering random data into a single structure set using
% 'RandomVariableSet' 
Xrvset=RandomVariableSet('CXrandomVariables',{p1 p2},'CSmembers',{'p1' 'p2'});

%%---------------Simulations to built Synthetic ExperimentalData-----------
%  ------------------------------------------------------------------------
% Create a new model to simulate perturbed data, inputs forces, stiffness
% and random displacement output values with random noise 
% Create Input values using 'Input' class
XinputPert=Input('CXmembers',{F1 F2 k1real k2real Xrvset},...
            'CSmembers',{'F1' 'F2' 'k1' 'k2' 'Xrvset'});
% Show summary of the Input object        
display(XinputPert); 

%% Define Model
Sfolder=fileparts(which('TutorialModelUpdating.m')); % returns the current folder
% Prepare the perturbed Model by 'mio' class from OpenCossan using a
% matlab script that is coded to handle the random vector to be added to the output
% displacements (to simulate synthetic data)
XmioPert=Mio('Spath',fullfile(Sfolder,'MatlabModel'),...
    'Sfile','displacementsPerturbation.m',...
    'Cinputnames',{'F1' 'F2' 'k1' 'k2', 'p1','p2'}, ...
    'Coutputnames',{'y1' 'y2'},...
    'Liostructure',true);

%% Construct Model
% Add the XmioPert object to an 'Evaluator' 
XevaluatorPert=Evaluator('CXmembers',{XmioPert},'CSmembers',{'XmioPert'});
% Defining the Physical Model by the 'Model' constructor from OpenCossan
XmodelPert=Model('Xinput',XinputPert,'Xevaluator',XevaluatorPert);

%% Monte Carlo simulation
% Define Monte Carlo simulation
Xmc=MonteCarlo('Nsamples',100);

% Perform Monte Carlo simulation using 'Apply' method
XsyntheticData=Xmc.apply(XmodelPert);
% Display the resulted outputs
XsyntheticData.getValues('Cnames',{ 'F1' 'F2' 'y1' 'y2' });

%% --------------------------Deterministic Analysys------------------------
%  ------------------------------------------------------------------------
% Prepare Input Object using 'Input' constructor from OpenCossan
% The previously prepared Parameters should be added together to an 'Xinput' Object
XinputNoise=Input('CXmembers',{F1 F2 k1real k2real},'CSmembers',{'F1' 'F2' 'k1' 'k2'});
% Show summary of the Input Object using 'Display' Method from OpenCossan
display(XinputNoise); %It could also be :  Xinput.display
% It will be used a matlab script to compute the the 2DOF displacements
Sfolder=fileparts(which('Tutorial2DOFModelUpdatingMatlab.m')); % returns the current folder
% Preparation for the Evaluator defining Input-Output method by 'mio' constructor from OpenCossan
Xmio=Mio('Spath',fullfile(Sfolder,'MatlabModel'),... %Pass Input/output names to the Matlab-Input-Output object
    'Sfile','displacements.m',...
    'Cinputnames',{'F1' 'F2' 'k1' 'k2'}, ...
    'Coutputnames',{'y1' 'y2'},...
    'Liostructure',true);
% Add the 'mio' constructor to the 'Evaluator' constructor
Xevaluator=Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});
%% Preparation of the Physical Model
% Defining the Physical Model by the 'Model' constructor from OpenCossan
Xmodel2DOFModelUpdatingMatlab=Model('Xinput',XinputNoise,'Xevaluator',Xevaluator);
%% Perform deterministic analysis to obtain deterministic values for the
% displcaments using 'deterministicAnalysis' method from OpenCossan aaplied
% to the constructed 'Model' knwon as  Xmodel2DOFModelUpdatingMatlab
Xout=deterministicAnalysis(Xmodel2DOFModelUpdatingMatlab); %It could also be  Xout=Xmodel2DOFModelUpdatingMatlab.deterministicAnalysis
%% Get the output values from this deterministic analysis (that is contained
% in Xout)
ActualDisplacements=Xout.getValues('Cnames',{'y1' 'y2'});

%% Define Model
%Define the Model such as the input values contain the Synthetic data (can
%be alo experimental ones)
Xinput=Input('CXmembers',{F1 F2 k1 k2},'CSmembers',{'F1' 'F2' 'k1' 'k2'});
Xmodel2DOFModel=Model('Xinput',Xinput,'Xevaluator',Xevaluator);
% Show summary of the Input Object using 'Display' Method from OpenCossan
display(Xinput); %It could also be :  Xinput.display
%Defining the 'ModelUpdating' constructor


%% ---------------------------Model Updating-------------------------------
% The model updating analysis requires the definition of parameters of the
% model that that will be updated 'Cinputnames', the output variables that
% will be used to mount the error function 'Coutputnames', the
% Synthetic/Experimental data 'Xsimulationdata' and finally the model to be updated 'Xmodel'
VupperBounds=[2.0 2.0];
VlowerBounds=[0.1 0.1];
Xmupd=ModelUpdating('Sdescription','descriptors', ...
    'Cinputnames',{'k1' 'k2'}, ...
    'XupdatingData',XsyntheticData,...
    'Xmodel',Xmodel2DOFModel,...
    'VupperBounds',VupperBounds,...
    'VlowerBounds',VlowerBounds);
% Display the modelUpdating Object 'Coutputnames',{'y1' 'y2'}, ...
display(Xmupd);
% Define the Optimization engine method as 'Cobyla' from OpenCossan
Xopt=Cobyla('NmaxIterations',100);
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
[Xout , Xoptimum]=Xmupd.updateSensitivity('Xoptimizer',Xopt,...    
    'Regularizationfactor',0.01,...
    'Luseregularization',false);
%  ------------------------------------------------------------------------
%Shows the optimazation results
display(Xoptimum)
%Get the design variables updated values  from the outputed model 'Xout' as
% the result of 'updateSensitivity' method
Vupdatedvalues=Xout.Xinput.getValues('Cnames',Xmupd.Cinputnames);
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