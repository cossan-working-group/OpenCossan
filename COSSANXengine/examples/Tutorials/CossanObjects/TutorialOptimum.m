%% TutorialOptimum
% This tutorial shows how to use the OpenCossan object OPTIMUM. 
% It is used to store the values of an optimisation process. 
%
% See also: TutorialOptimisationProblem 
% Author: Edoardo Patelli

%{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.
    
    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

% Create an empty object
Xoptimum=Optimum; 
display(Xoptimum)

% Define a simple OptimisationProblem 
% The objective function requires two design variables, defined as following:
X1      = DesignVariable('Sdescription','design variable 1','value',7);
% Create an Input object containing the design variable
Xin     = Input('Sdescription','Input for TutorialOptimum', ...
          'CSmembers',{'X1'},'CXmembers',{X1});
% Create objective function
Xobjfun   = ObjectiveFunction('Sdescription','objective function for TutorialOptimum', ...
    'Sscript','for n=1:length(Tinput),Toutput(n).out1=Tinput(n).X1^2;end',...
    'CoutputNames',{'out1'},'CinputNames',{'X1' });
% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem for TutorialOptimum', ...
    'Xinput',Xin,'XobjectiveFunction',Xobjfun);

% Initialise Optimum without any iterations
Xoptimum=Optimum('XoptimizationProblem',Xop);

% Create same dummy values
MvaluesDesignVariables=[1 5 2]';
MvaluesObjectiveFunction=[10 5 2]';
Viterations=[1 2 3]';

% Add first iterations to an object Optimum
Xoptimum=addIteration(Xoptimum,'Viterations',Viterations,...
         'Mdesignvariables',MvaluesDesignVariables,...
         'Mobjectivefunction',MvaluesObjectiveFunction);


%% Define an Optimim object
Xoptimum=Optimum('XoptimizationProblem',Xop,...
    'Mdesignvariables',MvaluesDesignVariables,...
    'Vobjectivefunction',MvaluesObjectiveFunction,...
    'Viterations',Viterations);

% The results are stored in a table 
Xoptimum.TablesValues

% The results can be plot
Xoptimum.plotObjectiveFunction
Xoptimum.plotDesignVariable
Xoptimum.plotConstraint
% Of course constraint can not be plotted since no contraint was defined. 

%% Construct Optimum repeated entries 
% This is a tipical situation when the constraints or objective function
% need to be evaluate more than one at each iteration
X1      = DesignVariable('Sdescription','design variable 1','value',7);
X2      = DesignVariable('Sdescription','design variable 2','value',10);
% Create an Input object containing the design variable
Xin     = Input('Sdescription','Input for TutorialOptimum', ...
          'CSmembers',{'X1' 'X2'},'CXmembers',{X1 X2});

% Create object OptimizationProblem
Xop     = OptimizationProblem('Sdescription','Optimization problem for TutorialOptimum', ...
    'Xinput',Xin,'XobjectiveFunction',Xobjfun);

Viterations=                        [1  2 3 3 3 4 4 4]';
MvaluesDesignVariables=             [1  5 2 3 4 3 1 1; ...
                                     7  5 7 6 5 1 0 1]';
MvaluesObjectiveFunction=           [10 5 2 3 5 1 5 0]';
                                 
Xoptimum=Optimum('XoptimizationProblem',Xop,...
    'Mdesignvariables',MvaluesDesignVariables,...
    'Vobjectivefunction',MvaluesObjectiveFunction,...
    'Viterations',Viterations);

% The results are stored in a table 
Xoptimum.TablesValues

% The results can be plot
Xoptimum.plotObjectiveFunction
Xoptimum.plotDesignVariable
Xoptimum.plotConstraint

%% Add iteration
% Simulate a new iteration from an Optimizer
Xoptimum=addIteration(Xoptimum,'Niteration',5,...
         'Vdesignvariables',[2 3],...
         'objectivefunction',4);
                     
Xoptimum.TablesValues           

% Add iteration with missing components
Xoptimum=addIteration(Xoptimum,'Niteration',6,...
         'Vdesignvariables',[4 1],...
         'objectivefunction',6);

        
% Create Optimum object with 2 iterations
Xoptimum1=Optimum('XoptimizationProblem',Xop,...
         'MDesignVariables',[0 0; 5 2],...
         'VobjectiveFunction',[5; 8],'Viterations',[0; 1]);

% Create Optimum object with 3 iterations
Xoptimum2=Optimum('XoptimizationProblem',Xop,...
         'MDesignVariables',[0 0; 5 2; 1 1],...
         'VobjectiveFunction',[5 8 8]',...
         'Viterations',[0 1 2]');     
     
% Create Optimum object with custum iterations
Xoptimum3=Optimum('XoptimizationProblem',Xop,...
         'MDesignVariables',[0 0; 5 2],...
         'VobjectiveFunction',[5 8]', ...
         'Viterations',[4 7]');

%% Merge 2 Optimum object
Xoptimum4=Xoptimum3.merge(Xoptimum2);
% show marged optimium
display(Xoptimum4)
     
% Show results and summaries 
display(Xoptimum3)

% Access the properties VoptimalDesign, VoptimalScores, VoptimalConstraints
% to show the values at the Optimum 

str=sprintf('%s ',Xoptimum3.CdesignVariableNames{:});
fprintf('Design Variable names: %s\n',str)
fprintf('Design Variable values: %e\n ',Xoptimum3.VoptimalDesign)
   
str=sprintf('%s ',Xoptimum3.CobjectiveFunctionNames	{:});
fprintf('Objective Function names: %s\n',str)
fprintf('Objective Function values: %e\n ',Xoptimum3.VoptimalScores)

str=sprintf('%s ',Xoptimum3.CconstraintsNames{:});
fprintf('Constraints names: %s\n',str)
fprintf('Constraints values: %e\n ',Xoptimum3.VoptimalConstraints)

%% ADDITERATION
% Add iteration with missing components

Xoptimum3=addIteration(Xoptimum3,'Niteration',7,...
         'Vdesignvariables',[5 5],...
         'objectivefunction',6);

Xoptimum3=addIteration(Xoptimum3,'Niteration',7,...
         'Vdesignvariables',[5 5],...
         'Vconstraintfunction',[4]);
     
Xoptimum3=addIteration(Xoptimum3,'Niteration',8,...
         'Vdesignvariables',[6 6],...
         'Vconstraintfunction',[6]);
     
Xoptimum3=addIteration(Xoptimum3,'Niteration',8,...
         'Vdesignvariables',[6 6],...
         'objectivefunction',7);
          
Xoptimum3=addIteration(Xoptimum3,'Niteration',9,...
         'Vdesignvariables',[6 6],...
         'objectivefunction',5);
Xoptimum3=addIteration(Xoptimum3,'Niteration',10,...
         'Vdesignvariables',[6 6],...
         'constraintfunction',2);   
     
% Show results and summaries 
display(Xoptimum3)

%% CompactTable
% This method can be used to remove duplicate entries in the table 

% The method compactTable is used to remove the NaN and duplicated rows in
% the table. 
% TODO: To be completed
%XoptimumCompact=Xoptimum.compactTable