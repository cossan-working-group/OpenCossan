%% Tutorial for the objective function
% The ObjectiveFunction object defines the objective function for the
% optimization problem. It is a subclass of the Mio object and inherits all
% the methods from this class. 
% Please refer to the Mio tutorial and Optimization tutorial  for more
% examples of objective function
%
% See Also: ObjectiveFunction TutorialConstraint
% TutorialOptimizationProblem
%
% Author: Edoardo Patelli
    
%{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2020 COSSAN WORKING GROUP

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
    
clear, clc;
import opencossan.optimization.*

%% Constructor
Xofun   = ObjectiveFunction('description','objective function', ...
          'InputNames',{'X1','X2'},... % Define the inputs 
          'FunctionHandle',@rastriginsfcn,...
          'OutputNames',{'fobj'}); % Define the outputs

% Show details of the ObjectiveFunction
display(Xofun)

% The ObjectFunction can also be defined as a script.

ScurrentPath=which('TutorialObjectiveFunction');
[Spath, ~ ]=fileparts(ScurrentPath);
Xofun1  = ObjectiveFunction('description','objective function of optimization problem', ...
    'FullFileName',fullfile(Spath,'Files4MatlabWorker','ExampleMatlabWorkerStructure.m') ,...
    'InputNames',{'X1','X2'},...
    'OutputNames',{'mioout'});

display(Xofun1)


%% Use ObjectiveFunction
% ObjectiveFunction can be evaluate by passing a table containing the name
% of variables defined in ObjectiveFunction.InputNames

TableInput=array2table([0 0; 4 3; 4, 1],'VariableName',{'X1','X2'});
TableOutput=Xofun1.evaluate(TableInput);

disp(TableOutput.fobj)