%TUTORIAL CREDAL NETWORK
% This tutorial aims to show the use Credal networks on OpenCossan 
% A benchmark problem for Bayesian networks is presented adapting the input
% discrete probability measures to credal sets
% For further detail about the model look section 4.1. in: 
%   Estrada-Lugo, H. D., Tolo, S., de Angelis, M., & Patelli, E. (2019).
%   "Pseudo credal networks for inference with probability intervals". ASCE-ASME J Risk and Uncert in Engrg Sys Part B Mech Engrg, 5(4).
% Author: Hector Diego Estrada-Lugo


% Import required packages
import opencossan.bayesiannetworks.CredalNetwork
import opencossan.bayesiannetworks.CredalNode

opencossan.OpenCossan.getInstance(); % Initialize OpenCossan add bnt toolbox to the path

% initialize variable n (number of nodes in the net)
n=0; 

%% Build Network Node Objects
% The first cell in the node contains all the lower bounds
% The second cell contais all the upper bounds
% The structure of the credal sets is: 0.040011<=P(Fire=True)<=0.041022
n=n+1;
% Cell's structure must be (X1,X2...,Xn,Xc) where,X1,X2,...,Xn correspond 
% to the number of states of the parents (X1,X2,...,Xn)of the current node Xc
% E.g. cell(2,5,6,2) means that parents X1, X2, and X3, have 2,5, and 6
% states respectively. The curret node has 2 states.
% If Xc is a binary root, the cell dimensions must be (1,2).
% Variable Nodes, contain the objects DiscreteNode with all its properties
% Node1 : Fire (state 1 = False; state 2 = True)
CPD_LB_Fire = cell(1,2); 
CPD_LB_Fire(1,[1,2]) = {0.958978 0.040011};  %Lower Bounds (LB) for states False True
CPD_UB_Fire = cell(1,2);
CPD_UB_Fire(1,[1,2])= {0.959989 0.041022}; %Upper Bounds (UB) for states False True
Nodes(1,n)=CredalNode('Name','Fire','CPDLow',CPD_LB_Fire,'CPDUp',CPD_UB_Fire);

% Node2: Presence of Smoke (state 1= not present (False); state 2= present (True))
n=n+1;
CPD_LB_Smoke=cell(2,2);
CPD_LB_Smoke(1,[1,2])={0.897531 0.010000};
CPD_LB_Smoke(2,[1,2])={0.090000, 0.890000,};
CPD_UB_Smoke=cell(2,2);
CPD_UB_Smoke(1,[1,2])={0.915557 0.102469};
CPD_UB_Smoke(2,[1,2])={0.110000 0.910000};
Nodes(1,n)=CredalNode('Name','Smoke','CPDLow',CPD_LB_Smoke,'CPDUp',CPD_UB_Smoke,'Parents', "Fire");

%Node3: Occurrence of Tampering (state 1= not occurred; state 2= occurred)
n=n+1;
CPD_LB_Tampering=cell(1,2);
CPD_LB_Tampering(1,[1,2])={0.98999 0.00889};
CPD_UB_Tampering=cell(1,2);
CPD_UB_Tampering(1,[1,2])={0.99111 0.01001};
Nodes(1,n)=CredalNode('Name','Tampering','CPDLow',CPD_LB_Tampering,'CPDUp',CPD_UB_Tampering);

%Node4: Alarm (state 1= not set off; state 2= set off)
n=n+1;
CPD_LB_Alarm=cell(2,2,2);
CPD_LB_Alarm(1,1,[1,2])={0.999800 0.000003};
CPD_LB_Alarm(1,2,[1,2])={0.010000 0.987342};
CPD_LB_Alarm(2,1,[1,2])={0.100000 0.880001}; 
CPD_LB_Alarm(2,2,[1,2])={0.400000 0.564106};
CPD_UB_Alarm=cell(2,2,2);
CPD_UB_Alarm(1,1,[1,2])={0.999997 0.000200};
CPD_UB_Alarm(1,2,[1,2])={0.012658 0.990000};
CPD_UB_Alarm(2,1,[1,2])={0.119999 0.900000}; 
CPD_UB_Alarm(2,2,[1,2])={0.435894 0.600000}; 
Nodes(1,n)=CredalNode('Name','Alarm','CPDLow',CPD_LB_Alarm,'CPDUp',CPD_UB_Alarm,'Parents', ["Fire","Tampering"]);

%Node5: Leaving (state 1= not occurred; state 2= occurred)
n=n+1;
CPD_LB_Leaving=cell(2,2); 
CPD_LB_Leaving(1,[1,2])={0.585577 0.400001};
CPD_LB_Leaving(2,[1,2])={0.100000 0.870001};
CPD_UB_Leaving=cell(2,2); 
CPD_UB_Leaving(1,[1,2])={0.599999 0.414423};
CPD_UB_Leaving(2,[1,2])={0.129999 0.900000};
Nodes(1,n)=CredalNode('Name','Evacuation','CPDLow',CPD_LB_Leaving,'CPDUp',CPD_UB_Leaving,'Parents', "Alarm");

%Node6: Report (state 1= not filed; state 2= filed)
n=n+1;
CPD_LB_Report=cell(2,2);
CPD_LB_Report(1,[1,2])={0.809988 0.171101};
CPD_LB_Report(2,[1,2])={0.240011 0.750000};
CPD_UB_Report=cell(2,2);
CPD_UB_Report(1,[1,2])={0.828899 0.190012};
CPD_UB_Report(2,[1,2])={0.250000 0.759989};
Nodes(1,n)=CredalNode('Name','Report','CPDLow',CPD_LB_Report,'CPDUp',CPD_UB_Report,'Parents', "Evacuation");

%% Build CredalNetwork object
XFire = CredalNetwork('Nodes',Nodes);
% Visualize Net
XFire.makeGraph


%% Inference
% Different options for inference through the method computeInference:
% In this case the queried variables are Fire, Report and Smoke, the
% state 2 of variable Fire has been introduced as new info (evidence) to update the model
% USE Bayes' Toolbox for Matlab (must be installed and in the path!) 
% OpenCossan-master\lib\bnt or...
% Notice here, we use computeInference instead of computeBNInference as these are CNs
Marginal_BuiltIn = XFire.computeInference('MarginalProbability',["Fire","Report","Smoke"],...
    'useBNT',false,'ObservedNode',"Fire",...
    'Evidence',2,...
    'Algorithm',"Variable Elimination");  

% ... with combinatorial approach and using BNToolbox
Marginal_BNT_JT=XFire.computeInference('MarginalProbability',["Report","Smoke"],...
    'useBNT',true,'ObservedNode',"Fire",...
    'Evidence',2,...
    'Algorithm',"Junction Tree");

Marginal_BNT_VE=XFire.computeInference('MarginalProbability',["Report","Smoke"],...
    'useBNT',true,'ObservedNode',"Fire",...
    'Evidence',2,...
    'Algorithm',"Variable Elimination");


