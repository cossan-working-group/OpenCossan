%EBN for a Hydropower Station
%An Enhanced Bayesian Network to produce a simple risk assessment in a
%hydroelectricity station, based on data from the Lianghekou project
%a station in southwest China.
%Author: Hector Diego Estrada-Lugo
%
% Import required packages (Need to be in the root of OpenCossan so it works)

import opencossan.bayesiannetworks.BayesianNetwork
import opencossan.bayesiannetworks.EnhancedBayesianNetwork
import opencossan.bayesiannetworks.ProbabilisticNode
import opencossan.bayesiannetworks.DiscreteNode
import opencossan.common.inputs.random.*
import opencossan.simulations.MonteCarlo %To reduce the network

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
% Node1a: Emission Scenario (state 1=RCP4.5; state 2=RCP8.5)
n=n+1;
CPD_Emission=cell(1,2);
CPD_Emission(1,[1,2])={0 1};
Nodes(1,n)=DiscreteNode('Name','ScenarioEmission','CPD',CPD_Emission);

% Node1b: Time Scenario (state 1=2030; state 2=2060, state 3=2090)
n=n+1;
CPD_Time=cell(1,3);
CPD_Time(1,[1,2,3])={1 0 0};
Nodes(1,n)=DiscreteNode('Name','ScenarioTime','CPD',CPD_Time);

% Node1: Extreme Precipitation (state 1=level1 0mm;state 2=level2 10mm; state 3=level3 25mm; state 4=level4 50mm or more)
n=n+1;
CPD_ExtremePrecipitation=cell(2,2,5);
CPD_ExtremePrecipitation(1,1,[1,2,3,4,5])={0.39 0.37 0.15 0.07 0.01};
CPD_ExtremePrecipitation(1,2,[1,2,3,4,5])={0.39 0.52 0 0.07 0.01};
CPD_ExtremePrecipitation(1,3,[1,2,3,4,5])={0.39 0.52 0 0.07 0.01};
CPD_ExtremePrecipitation(2,1,[1,2,3,4,5])={0.39 0.52 0 0.07 0.01};
CPD_ExtremePrecipitation(2,2,[1,2,3,4,5])={0.39 0.37 0.15 0.07 0.01};
CPD_ExtremePrecipitation(2,3,[1,2,3,4,5])={0.39 0.37 0.15 0.3 0.06};
Nodes(1,n)=DiscreteNode('Name','ExtremePrecipitation','CPD',CPD_ExtremePrecipitation,...
    'Parents',["ScenarioEmission","ScenarioTime"]);

% Node2: Probability of Debris flow (state 1= 0%; state 2= 5%; state 3= 20%; state 4= 40%)
n=n+1;
CPD_DebrisFlow=cell(4,4);
CPD_DebrisFlow(1,[1,2,3,4])={0.444 0.519 0.027 0.01};
CPD_DebrisFlow(2,[1,2,3,4])={0.4 0.543 0.04 0.017};
CPD_DebrisFlow(3,[1,2,3,4])={0.2 0.3 0.352 0.148};
CPD_DebrisFlow(4,[1,2,3,4])={0 0 0.852 0.148};
CPD_DebrisFlow(5,[1,2,3,4])={0 0 0 1};
Nodes(1,n)=DiscreteNode('Name','DebrisFlow','CPD',CPD_DebrisFlow,...
    'Parents',"ExtremePrecipitation","Values",3);

%Node3: Wind velocity (state 1= 18m/s state 2= another velocity)
n=n+1;
CPD_WindVelocity=cell(1,2);
CPD_WindVelocity(1,[1,2])={1 0};
Nodes(1,n)=DiscreteNode('Name','WindVelocity','CPD',CPD_WindVelocity,...
    'Values',[1,2]);

% Node4: Water level (state 1= lowlevel(291m);state 2= highlevel (2m))
n=n+1;
CPD_WaterLevel=cell(4,2);
CPD_WaterLevel(1,[1,2])={0.9 0.1};
CPD_WaterLevel(2,[1,2])={0.8 0.2};
CPD_WaterLevel(3,[1,2])={0.6 0.4};
CPD_WaterLevel(4,[1,2])={0.2 0.8};
CPD_WaterLevel(5,[1,2])={0.1 0.9};
Nodes(1,n)=DiscreteNode('Name','WaterLevel','CPD',CPD_WaterLevel,...
    'Parents',"ExtremePrecipitation");

% ProbabilisticBode is used to define a node described by a continous
% Random Variable. Please consult Cossan wiki to see all the distributions
% available. 
% Node5: Wave Raising Height (state 1= 10m/s; state 2= 22m/s windspeed)
n=n+1;
CPD_WaveRaising=cell(2,1);
CPD_WaveRaising(1,1)={RayleighRandomVariable('Description','WaveRaising','Sigma', 0.387)}; % Wind speed=10m/s
CPD_WaveRaising(2,1)={RayleighRandomVariable('Description','WaveRaising','Sigma',2.068)}; % Wind speed=22m/s
Nodes(1,n)=ProbabilisticNode('Name','WaveRaising','CPD',CPD_WaveRaising,...
    'Parents',"WindVelocity");


% A child ProbabilisticNode is used as a repository on which the
% probabilistic parents will be reduced on. The CPD must be defined in
% terms of Loads and Resistances in which the TableInputs are the output
% smaples from the ProbabilisticNode parents.
% Node5: Wave Raising Height (state 1= 10m/s; state 2= 22m/s windspeed)
n=n+1;
CPD_child=cell(2,1);
CPD_child(1,1)={'TableInput.waveraising+TableInput.windvelocity'}; 
CPD_child(2,1)={'TableInput.waveraising-TableInput.windvelocity'};
Nodes(1,n)=ProbabilisticNode('Name','child','CPD',CPD_child,...
    'Parents',["WaveRaising","WindVelocity"]);

%Node6: Overtopping (state 1= not occured; state 2= occurred)
n=n+1;
CPD_Overtopping=cell(2,1,2);
CPD_Overtopping(1,1,1)={'-296.2+291+TableInput.waveraising'}; %If result is positive, state 1 happens (Overtopping doesn't occur)
CPD_Overtopping(1,1,2)={'296.2-291-TableInput.waveraising'}; %If result is negative, state 2 happens (Overtopping occurs)
CPD_Overtopping(2,1,[1,2])={'-296.2+295.03+TableInput.waveraising' '296.2-295.03-TableInput.waveraising'}; %water level high
Nodes(1,n)=DiscreteNode('Name','Overtopping','CPD',CPD_Overtopping,...
    'Parents',["WaterLevel","WaveRaising"]);

%Node7: Station damaged (state 1=not occurred; state 2= occurred) From Shi
n=n+1;
CPD_StationDamaged=cell(2,4,2);
CPD_StationDamaged(1,1,[1,2])={1-1.871*10^(-4) 1.871*10^(-4)};
CPD_StationDamaged(1,2,[1,2])={0.999807 1.93*10^(-4)};
CPD_StationDamaged(1,3,[1,2])={1-1.095*10^(-4) 1.095*10^(-4)};
CPD_StationDamaged(1,4,[1,2])={1-1.095*10^(-4) 1.095*10^(-4)};
CPD_StationDamaged(2,1,[1,2])={1-1.095*10^(-4) 1.095*10^(-4)};
CPD_StationDamaged(2,2,[1,2])={1-1.095*10^(-4) 1.095*10^(-4)};
CPD_StationDamaged(2,3,[1,2])={0.998 0.002};
CPD_StationDamaged(2,4,[1,2])={0.0999 0.001};
Nodes(1,n)=DiscreteNode('Name','StationDamage','CPD',CPD_StationDamaged,...
    'Parents',["Overtopping","DebrisFlow"]);

%% Build EnhancedBayesianNetwork object
Xhydrostation=EnhancedBayesianNetwork('Nodes',Nodes);
% Visualize Net
Xhydrostation.makeGraph;

% The Enhanced Bayesian network must be reduced to a traditional BN
% choose the sampling method and use reduce2BN method to reduce the EBN
XMC=MonteCarlo('Nsamples',1000,'nseedrandomnumbergenerator',8128);
XBNhydrostation=Xhydrostation.reduce2BN('SimulationObject',XMC);
XBNhydrostation.makeGraph;

%% Introduce evidence
% Once network is reduced, inference can be computed with the
% computeBNInference method

% with the built-in algorithm
Marginalization=XBNhydrostation.computeBNInference('MarginalProbability',["Overtopping","StationDamage"], 'useBNT',false);
