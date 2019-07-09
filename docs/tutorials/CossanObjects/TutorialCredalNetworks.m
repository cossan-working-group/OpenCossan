%% TUTORIAL CREDAL NETWORKS
% This tutorial aims to show the use Credal networks on OpenCossan 
% A benchmark problem for Bayesian networks is presented adapting the input
% discrete probability measures to Credal sets (K(x))
% The network aims to assess the probability of a person having bronchitis
% or Lung cancer given this person is a smoker
%
% Author: Hector Diego Estrada Lugo
%

import opencossan.bayesiannetworks.CredalNetwork
import opencossan.bayesiannetworks.CredalNode

% N.B. For all the following nodes it applies the convention:
% State 1= Yes, State 2= No


%% Defining Credal network
n=1;

CPD_Smokerlower=cell(1,2); 
CPD_Smokerlower(1,[1,2])={0.25 0.5};  %Lower bounds for states Yes No
CPD_Smokerupper=cell(1,2);
CPD_Smokerupper(1,[1,2])= {0.5 0.75}; %Upper bounds for states Yes No
Nodes(1,n)=CredalNode('Name','Smoker','CPDLow',CPD_Smokerlower,'CPDUp',CPD_Smokerupper);

%%
% Node1: CANCER
n=n+1;
CPD_Cancerlower=cell(2,2);
CPD_Cancerlower(1,[1,2])={0.15 0.6};
CPD_Cancerlower(2,[1,2])={0.05 0.9};
CPD_Cancerupper=cell(2,2);
CPD_Cancerupper(1,[1,2])={0.4 0.85};
CPD_Cancerupper(2,[1,2])={0.1 0.95};
Nodes(1,n)=CredalNode('Name','Cancer','CPDLow',CPD_Cancerlower,'CPDUp',CPD_Cancerupper,'Parents',"Smoker");

% NODE2: BRONCHITIS
n=n+1;
CPD_Bronchitislower=cell(2,2);
CPD_Bronchitislower(1,[1,2])={0.3 0.45};
CPD_Bronchitislower(2,[1,2])={0.2 0.7};
CPD_Bronchitisupper=cell(2,2);
CPD_Bronchitisupper(1,[1,2])={0.55 0.7};
CPD_Bronchitisupper(2,[1,2])={0.3 0.8};
Nodes(1,n)=CredalNode('Name','Bronchitis','CPDLow',CPD_Bronchitislower,'CPDUp',CPD_Bronchitisupper,'Parents',"Smoker");

%% Drawing network graphic
XSmoker=CredalNetwork('Nodes',Nodes);
% Visualize network
XSmoker.makeGraph

%% Compute inference
% ... with combinatorial approach and using BNToolbox
CancerProbabilityBNT=XSmoker.computeInference('MarginalProbability',"Cancer",...
    'useBNT',true,'ObservedNode',"Bronchitis",...
    'Evidence',2,...
    'Algorithm',"Variable Elimination"); 

% ... with combinatorial approach but using built-in tools
CancerProbabilityBuiltIn=XSmoker.computeInference('MarginalProbability',"Cancer",...
    'useBNT',false,'ObservedNode',"Bronchitis",...
    'Evidence',2,...
    'Algorithm',"Variable Elimination"); 


%Result2=XSmoker.computeInference('CSmarginal',{'bronchitis'},'Lapproximate',true);  %Outer approximation
%Result3=XSmoker.computeInference('CSmarginal',{'bronchitis'},'Lexact',true);        %Inner approximation (Only admits binary nodes)