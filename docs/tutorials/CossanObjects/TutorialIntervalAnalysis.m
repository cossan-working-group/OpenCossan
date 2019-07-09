%% Tutorial for the IntervalAnalysis
% This tutorial shows how to define and perform an interval analysis.
% The interval analysis can defined using an ObjectiveFunction, a MI-O or a
% model.
% The  parameters associated with the problem are defined using an Input
% object  containing IntervalVariables.
%
% This example computes the volume's bounds of a beam.
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@intervalAnalysis
%
% $Author:~Marco~de~Angelis$
% SmainPath='C:\Users\mda\MATLAB\OPENCOSSAN\TUTORIALS_IntervalAnalysis\TutorialVolume';
clear
close all
clc;

%% Preliminary object to define the Interval Analysis
% Interval variables
H=IntervalVariable('Sdescription','Beam Height','lowerBound',10,'upperBound',50);
W=IntervalVariable('Sdescription','Beam Width','lowerBound',10,'upperBound',50);
% Create the corresponding bounded set
Xivset=IntervalVariableSet('Sdescription','Interval set of beam sizes',...
    'CXmembers',{H,W},...
    'CSmembers',{'H','W'});
display(Xivset)

L=Parameter('Sdescription','Beam Length','value',100);


% Include the design variable in a Input object
Xinput=Input('CXmembers',{Xivset L},'Csmembers',{'Xivset' 'L'});
%% Interval analysis
SmodelType='mio';
switch lower(SmodelType)
    case 'objective'
        % Define an Objective function
        Xobjfun   = ObjectiveFunction('Sdescription','objective function', ...
            'Sscript',...
            strcat('for n=1:length(Tinput),',...
            'Toutput(n).Volume=Tinput(n).H*Tinput(n).L*Tinput(n).W;',...
            'end'),...
            'CoutputNames',{'Volume'},...
            'CinputNames',{'W' 'H' 'L'});
        % Create object IntervalAnalysis
        Xia     = IntervalAnalysis('Sdescription','My first Interval Analysis object',...
            'XobjectiveFunction',Xobjfun,'Xinput',Xinput);
    case 'mio'
        % Define the MI-O object
        Xmio=Mio('Sscript',...
            strcat('for n=1:length(Tinput),',...
            'Toutput(n).Volume=Tinput(n).H*Tinput(n).L*Tinput(n).W;',...
            'end'),...
            'CoutputNames',{'Volume'},...
            'CinputNames',{'W' 'H' 'L'});
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