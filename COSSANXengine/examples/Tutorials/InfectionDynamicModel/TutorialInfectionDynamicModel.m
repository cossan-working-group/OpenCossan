%% Tutorial Infection Dynamic Model
%
% This example shows how to perform the global sensitivity analysis of a
% mathematical model representing an infective process at its early state, where
% we assume that the infection is propagated through some kind of contact
% between individuals who do not take any precaution to avoid contagion.   
%
% The equatios describe the dynamics of I and S, repesenting the model of the
% infection process are: 
%
% $$\frac{dI}{dt}=\gamma \kappa I S \textrm{--} r I \textrm{--} \delta I$$
%
% and
%
% $$\frac{dS}{dt}= \textrm{--} \gamma \kappa I S+b S+m$$
%
% where:
% 
% * I is the number of Infected idividuals at time t
% * S number of individual susceptible to infection
% * $\kappa<1$ contact coefficient
% * $\gamma<1$ infection coefficient
% * $r$ recovery rate
% * $\delta$ death rate
% * $m$ migration rate
% * $b$ birth rate
%
% At the early stage $$(t ~ 0) S(t) \gg I(t)$$ and then S(t)~S0. Therefore the first
% equation becames linear and the solution is: 
%
% $I=I_0*exp(Y)$ where $Y=\gamma \kappa S0 \textrm{--} r \textrm{--} \delta$
%
% If the coefficient of the exponential is greater then 0 the infection spreads,
% otherwise the infection dies out. 
%
% This tutorial is base on the example provided in the book:A.Saltelli et al.,
% Global Sensitivity Analysis: the primer, Wiley, 2008: ISBN 978-0-470-05997-5 
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Infection_Dynamic_Model
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 



%% Model definition
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(46354)

Sfolder=fileparts(which('TutorialInfectionDynamicModel.m'));% returns the current folder

% Define inputs
Szero=Parameter('Sdescription','Number of susceptible individuals','value',1000);
gamma=RandomVariable('Sdescription','Infection coefficient', ...
    'Sdistribution','uniform','lowerbound',0,'upperbound',1);
kappa=RandomVariable('Sdescription','Contact coefficient', ...
    'Sdistribution','beta','par1',2,'par2',7);
r=RandomVariable('Sdescription','Recovery rate', ...
    'Sdistribution','uniform','lowerbound',0,'upperbound',1);
delta=RandomVariable('Sdescription','Death rate', ...
    'Sdistribution','uniform','lowerbound',0,'upperbound',1);

% Now we group all the inputs in a Input object
Xrvset=RandomVariableSet('Cmembers',{'gamma' 'kappa' 'r' 'delta'}, ...
    'CXmembers',{gamma kappa r delta});

Xin=Input('Sdescription','Inputs of the infective process', ...
    'XrandomVariableSet',Xrvset,'Xparameter',Szero);

% Define the physical model
% Creating a matlab script for computing Y=gamma*kappa*S0-r-delta
Xm=Mio('Sdescription','Infection model early stage', ... 
       'Cinputnames',{'Szero' 'gamma' 'kappa'  'r' 'delta'}, ...
       'Coutputnames',{'Y'},...
       'Sfile','infectionMatrix.m','Spath',Sfolder,...
       'Lfunction',false,'Liomatrix',true,'Liostructure',false);
   
Xev=Evaluator('Xmio',Xm);
Xmdl=Model('Xinput',Xin,'Xevaluator',Xev,...
    'Sdescription','Model for TutorialInfectionDynamicModel');



%% Uncertainty analysis 
% In order to verified the above model we generate a input object containing
% 10000 reliazations and we compute the quantity of interest Y
Xin=Xin.sample('Nsamples',10000);

% Show the samples 

% Plot histogramm of the realizations
f1=figure;
hist(gca(f1),Xin.Xsamples.MsamplesPhysicalSpace,50)
legend(gca(f1),Xin.CnamesRandomVariable)

% Evaluete the model
Xout=Xmdl.apply(Xin);

% extract quantity of interest (Y) from simulation data object
VY=Xout.getValues('Sname','Y');

% Plot histogramm of Y
f2=figure;
hist(gca(f2),VY,50)
%% Close figure and validate solution
close(f1);close(f2);

% Validate Solution
assert(abs(min(VY)+1.6894)<1e-4,...
    'CossanX:Tutorials:InfectionDynamicModel',...
    'Reference Solution for the infection dynamic model does not matched.')

% Please continue with the tutotial
% TutorialInfectionDynamicModelGlobalSensitivityAnalysis 
