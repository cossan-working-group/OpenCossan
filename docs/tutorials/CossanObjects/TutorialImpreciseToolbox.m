%% Tutorial for the ImpreciseToolbox
% This tutorial shows the basic implementation of an Imprecise Toolbox
%
% Only one interval is used as a input that creates an ImpreciseInput. The
% ImpreciseInputs is used to define an ImpreciseModels. The model is a
% simple analytical function define an a MIO object.
%
% A simple double loop Monte Carlo method is used to propagate the interval
clear
close all
clc;

import opencossan.imprecise.*
import opencossan.intervals.*
%% Define Input
% Interval variables
I1=IntervalVariable('Description','I1','Bounds',[1 5]);
I2=IntervalVariable('Description','I2','lowerBound',0,'upperBound',2);

% Create the corresponding bounded set
% Xivset=IntervalVariableSet('Description','Interval set ',...
%     'IntervalVariables',{I1,I2},...
%     'IntervalVariablesNames',{'I1','I2'});

Xivset=IntervalVariableSet('Description','Interval set ',...
                           'IntervalVariables',{I1,I2});

% Include the design variable in a Input object
Xinput=ImpreciseInput('IntervalVariableSet',Xivset);

%% Define model
% a very simple model y=x1+x2*x1 is defined as a MIO object 
Xmio=opencossan.workers.Mio('Script','Moutput=Minput(:,1)+Minput(:,2).*Minput(:,1);',...
         'OutputNames',{'Y'},'InputNames',{'I1' 'I2'},...
         'Sformat');
        Xia     = IntervalAnalysis('Sdescription','My first Interval Analysis object',...
            'Xmio',Xmio,'Xinput',Xinput);
    case 'model'
        % Define the MI-O object
        Xmio=Mio('Sscript',...
            strcat('for n=1:length(Tinput),',...
            'Toutput(n).Volume=Tinput(n).H*Tinput(n).L*Tinput(n).W;',...
            'end'),...
            'CoutputNames',{'Volume'},...
            'CinputNames',{'W' 'H' 'L'});
        % Add the MIO object to an Evaluator object
        Xevaluator=Evaluator('CXmembers',{Xmio},'CSmembers',{'Xmio'});
        % Define the Physical Model
        XmodelMatlab=Model('Xinput',Xinput,'Xevaluator',Xevaluator);
        % Create object IntervalAnalysis
        Xia     = IntervalAnalysis('Sdescription','My first Interval Analysis object',...
            'Xmodel',XmodelMatlab,'Xinput',Xinput);
    case 'connector'
end
% Visualize the IntervalAnalysis object
display(Xia)
%% Define IA solver
SsolverName='sqp';
switch lower(SsolverName)
    case 'ga'
        % perform global optimization with GA
        Xsolver=GeneticAlgorithms('NPopulationSize',30,'NStallGenLimit',5,...
            'SMutationFcn','mutationadaptfeasible');
    case 'sqp'
        % perform local optimization with SQP
        Xsolver=SequentialQuadraticProgramming;
    case 'lhs'
        % explore the search domain with LHS
        Xsolver=LatinHypercubeSampling('Nsamples',100);
    case 'doe'
        % explore the search domain using design of experiment (check out
        % the problem dimension before using this option!)
        Xsolver = DesignOfExperiments('SdesignType','FullFactorial',...
            'VlevelValues',[2,2],...
            'ClevelNames',{'W' 'H'});
end

%% Perform the analysis
% In this simple example the optimization is performed by COBYLA using the
% method optimize.
Xextrema=Xia.computeExtrema('Xsolver',Xsolver);
display(Xextrema)