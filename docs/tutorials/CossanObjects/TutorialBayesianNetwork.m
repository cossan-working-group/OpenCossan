%TUTORIAL BAYESIAN NETWORK
% A very simple example of traditional Bayesian Network implementation
% For further detail about the model visit>>>https://www.cs.utah.edu/~tch/notes/matlab/bnt/docs/usage.html#basics
% Author: Silvia Tolo

% Import required packages
import opencossan.bayesiannetworks.BayesianNetwork
import opencossan.bayesiannetworks.DiscreteNode

opencossan.OpenCossan.getInstance(); % Initialize OpenCossan add bnt toolbox to the path

% initialize variable n (number of nodes in the net)
n=0;

%% Build Network Node Objects
% Cell's structure must be (X1,X2...,Xn,Xc) where,X1,X2,...,Xn correspond 
% to the number of states of the parents (X1,X2,...,Xn)of the current node Xc
% E.g. cell(2,5,6,2) means that parents X1, X2, and X3, have 2,5, and 6
% states respectively. The curret node has 2 states.
% If Xc is a binary root, the cell dimensions must be (1,2).
% Variable Nodes, contain the objects DiscreteNode with all its properties
% Node1 : Fire (state 1 = False; state 2 = True)
% Node1: Occurrence of Fire (state 1= not occurred; state 2= occurred)
n=n+1;
CPD_Fire=cell(1,2);
CPD_Fire{1,1}=0.98;
CPD_Fire{1,2}=0.02;
Nodes(1,n)=DiscreteNode('Name','Fire','CPD',CPD_Fire);

% Node2: Presence of Smoke (state 1= not present; state 2= present)
n=n+1;
CPD_Smoke=cell(2,2);
CPD_Smoke([1,2],1)={0.9 0.09};
CPD_Smoke([1,2],2)={0.1 0.91};
Nodes(1,n)=DiscreteNode('Name','Smoke','CPD',CPD_Smoke,'Parents', "Fire");

%Node3: Occurrence of Tampering (state 1= not occurred; state 2= occurred)
n=n+1;
CPD_Tampering_lower=cell(1,2);
CPD_Tampering(1,[1,2])={0.98 0.02};
Nodes(1,n)=DiscreteNode('Name','Tampering','CPD',CPD_Tampering);

%Node4: Alarm (state 1= not set off; state 2= set off)
n=n+1;
CPD_Alarm=cell(2,2,2);
CPD_Alarm(1,1,[1,2])={0.9998  0.0002};
CPD_Alarm(1,2,[1,2])={0.1     0.9 };
CPD_Alarm(2,1,[1,2])={0.03 0.97 }; 
CPD_Alarm(2,2,[1,2])={0.4 0.6};    
Nodes(1,n)=DiscreteNode('Name','Alarm','CPD',CPD_Alarm,'Parents', ["Fire","Tampering"]);

%Node5: Evacuation (state 1= not occurred; state 2= occurred)
n=n+1;
CPD_Evacuation=cell(2,2); 
CPD_Evacuation(1,[1,2])={0.98 0.02};
CPD_Evacuation(2,[1 ,2])={0.1 0.9};
Nodes(1,n)=DiscreteNode('Name','Evacuation','CPD',CPD_Evacuation,'Parents', "Alarm");

%Node6: Report (state 1= not filed; state 2= filed)
n=n+1;
CPD_Report=cell(2,2);
CPD_Report(1,[1,2])={0.80 0.2};
CPD_Report(2,[1,2])={0.24 0.76};
Nodes(1,n)=DiscreteNode('Name','Report','CPD',CPD_Report,'Parents', "Evacuation");

%% Build BayesianNetwork object
XFire=BayesianNetwork('Nodes',Nodes);
% Visualize Net
XFire.makeGraph


%% Inference
% Different options for inference through the method computeBNInference:
% In this case the queried variables are Fire, Report and Smoke, the
% state 2 of variable Fire has been introduced as new info (evidence) to update the model
% USE Bayes' Toolbox for Matlab (must be installed and in the path!) 
% OpenCossan\lib\bnt or...
% Notice here, we use computeBNInference 

% USE Bayes' Toolbox for Matlab (must be installed and in the path!) 
% OpenCossan-master\lib\bnt or...
Marginal_BuiltIn=XFire.computeBNInference('MarginalProbability',["Fire","Report","Smoke"],...
    'useBNT',false,'ObservedNode',"Fire",...
    'Evidence',2,...
    'Algorithm',"Variable Elimination"); 

Joint_BuiltIn=XFire.computeBNInference('JointProbability',["Fire","Report","Smoke"],...
    'useBNT',false,'ObservedNode',"Fire",...
    'Evidence',2,...
    'Algorithm',"Variable Elimination"); 

% Using Bayes' Toolbox for Matlab
Marginal_BNT=XFire.computeBNInference('MarginalProbability',["Fire","Report","Smoke"],...
    'useBNT',true,'ObservedNode',"Fire",...
    'Evidence',2,...
    'Algorithm',"Junction Tree"); 
Joint_BNT=XFire.computeBNInference('JointProbability',["Report","Smoke"],...
    'useBNT',true,'ObservedNode',"Fire",...
    'Evidence',2,...
    'Algorithm',"Variable Elimination"); 
