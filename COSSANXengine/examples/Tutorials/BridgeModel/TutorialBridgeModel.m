%% TutorialBridgeModel
% In this tutorial the global sensitivity analysis is applied to a practical
% problem in structural engineering: a mechanical model of a long bridge.
%
% The conceptual model is sketched below.
%
%                                       | L 
%                                       |
%     w_1  E_1 h_1   w_2  E_2 h_2        v             w_20  E_20 h_20   w_21
%       @=============@=============@==========@   ....  @================@
%      | |           | |           | |        | |       | |              | |
%  k_1 z u c_1       z u           z u        z u       z u         k_21 z u c_21
%      | |           | |           | |        | |       | |              | |
%      --- <-------> --- <-------> ---        ---       --- <----------> ---
%      ///    l_1    ///    l_2    ///        ///       ///     l_20     ///
% 
% Legend:
%
% * w_i = supportRotational stiffness (i=1-21)
% * k_i = support stiffness           (i=1-21)
% * c_i = support damping             (i=1-21)
% * h_i = beam height                 (i=1-20)
% * l_i = beam lenth                  (i=1-20) 
% * E_i = beam E modulus              (i=1-20) 
% * L = Load                       
%
% This model is interesting for several reasons, which makes it suitable for an
% example application of  the total sensitivity analysis and their upper bounds. 
% The conceptual model contains 123 uncertain parameters.
% All the uncertain parameters are considered to be uncorrelated. 
%
% The bridge is subjected to a harmonic load with a frequency of 10 Hz, applied
% at the mid point of the 3rd bay. The aim of the analysis is to identify the
% parameters that affect the variance of the maximum displacement of any points
% of the bridge as well as the parameters that have negligible effects. 
%
% It is important to note, that in order to avoid unrealistic values of the
% input parameters during the simulation, truncated normal distributions are
% used.  
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/BridgeModel
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(46354)

%% Define Input factors
% It is necessary to define 124 random variables that are grouped into 3 random
% variable sets. It is not necessary to group the Random variables in different
% sets because they are not correlated. However, it is convenient for the
% definition of  indipendent  identical distributed random variables

%% Beams geometry: heights
h=RandomVariable('Sdistribution','normal','mean',0.001,'cov',0.05,'lowerBound',0);

hSet=RandomVariableSet('Xrv',h,'Nrviid',20);
% Please note that the random variables in the randomvariables set are named h_1
% to h_20
disp(hSet.Cmembers)

%% Beams geometry: E modulus
E=RandomVariable('Sdistribution','normal','mean',210e9,'cov',0.03,'lowerBound',0);

ESet=RandomVariableSet('Xrv',E,'Nrviid',20);
% Please note that the random variables in the random variables set are named E_1
% to E_20
disp(ESet.Cmembers)

%% Beams geometry: length
l=RandomVariable('Sdistribution','normal','mean',0.36,'cov',0.05,'lowerBound',0);

lSet=RandomVariableSet('Xrv',l,'Nrviid',20);
% Please note that the random variables in the random variables set are named l_1
% to l_20
disp(lSet.Cmembers)

%% Supports: stiffness
k=RandomVariable('Sdistribution','normal','mean',200,'cov',0.10,'lowerBound',0);

kSet=RandomVariableSet('Xrv',k,'Nrviid',21);
% Please note that the random variables in the random variables set are named k_1
% to k_21
disp(kSet.Cmembers)

%% Supports: rotation stiffness
w=RandomVariable('Sdistribution','normal','mean',40,'cov',0.16,'lowerBound',0);

wSet=RandomVariableSet('Xrv',w,'Nrviid',21);
% Please note that the random variables in the random variables set are named w_1
% to w_21
disp(kSet.Cmembers)

%% Supports: damping
c=RandomVariable('Sdistribution','normal','mean',0.4,'cov',0.25,'lowerBound',0);

cSet=RandomVariableSet('Xrv',c,'Nrviid',21);
% Please note that the random variables in the random variables set are named c_1
% to c_21
disp(cSet.Cmembers)

%% Load
load=Parameter('Sdescription','Harmonic load frequency (Hz)','value',10);
rho=Parameter('Sdescription','material density','value',7800);
width=Parameter('Sdescription','BeamWidth','value',0.04);

%% Create a Input object
Xinput=Input('CXmembers',{hSet lSet ESet kSet wSet cSet load rho width},...
        'CSmembers',{'hSet' 'lSet' 'ESet' 'kSet' 'wSet' 'cSet' 'load' 'rho' 'width'},...
        'Sdescription','Input object for Bridge Model Tutorial');
% Show the input object
display(Xinput)

%% Create the Evaluator
% The mathematical model of the bridge is implemented in a matlab function.
% Hence, an object of type Mio is required to connect the solver with COSSAN-X.

% Use of a matlab script to compute the maximum displacement of the bridge
Sfolder=fileparts(which('TutorialBridgeModel.m'));% returns the current folder
Xmio=Mio('Spath',Sfolder,'Sfile','bridgeModel.m',...
         'Liomatrix',true, ...  % This flag specify the type of I/O
         'Liostructure',false,...
         'Cinputnames',Xinput.Cnames, ...
         'Coutputnames',{'maxDisplacement'});

% Add the MIO object to an Evaluator object
Xevaluator=Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});

%% Preparation of the Physical Model
% Define the Physical Model
XmodelBridge=Model('Xinput',Xinput,'Xevaluator',Xevaluator);

display(XmodelBridge)

%% Perform deterministic analysis
Xout=XmodelBridge.deterministicAnalysis;
NominalDisplacement=Xout.getValues('Sname','maxDisplacement');

% Validate Solution
assert(abs(NominalDisplacement-4.05230e-03)<1e-6,...
    'CossanX:Tutorials:TutorialBridgeModel', ...
    'Nominal sulution does not match Reference Solution.')


%% Uncertainty Quantification
% The reliaility analysis is performed by the following tutorial
%  See Also: <TutorialBridgeModelUncertaintyQuantification.html>

% echodemo TutorialBridgeModelUncertaintyQuantification


%% Global Sensitivity Analysis
% This tutorial continues with the optimization section
% See Also:  <TutorialBridgeModelGlobalSensitivityAnalysis.html> 

% echodemo TutorialBridgeModelGlobalSensitivityAnalysis
