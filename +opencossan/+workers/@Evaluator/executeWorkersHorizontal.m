function [TableOutput] = executeWorkersHorizontal(Xobj,TableInput)
% EXECUTEWORKERSHORIZONTAL  This is a protected method of evaluator to run the
% analysis in horizontal chunks.
%
% It requires a Table  object as input and returns a Table object
%
%  Usage:  TableOutput = executeWorkersVertical(Xobj,TableInput)
%
% See Also: Evaluator
%
%
% Author: Edoardo Patelli
% Cossan Working Group
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

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

import opencossan.*
%% Initialization
assert(istable(TableInput),'OpenCossan:Evaluator:executeWorkersHorizontal:wrongInput',...
    'A Tables object is required as input.\nProvided class %s is not valid',class(TableInput))
% Retrieve Analysis object;
Xanalysis=opencossan.OpenCossan.getAnalysis;

%% Analysis
% The analysis is split over the number workers. All the samples are
% processed for each worker before moving to the execution of the next
% worker.


% Predefine and reset tableOutput
TableOutputSolver=[];

% Evaluator execution
for n=1:length(Xobj.Solver)
    OpenCossan.cossanDisp(['[Status:workers  ]  * Processing solver ' ...
        num2str(n) '/' num2str(length(Xobj.Solver))],3)
    
    % Merge tableInput with output produced by the workers and then
    % pass only the inputs required by the specific worker.
    if n>1
        TableSolver=[TableInput TableOutputSolver]; 
    else
        TableSolver=TableInput;
    end
    
    try
        % Execute worker.
        % Only the input required by the worker are passes. No recheck
        % is needed in the evaluate method.
        TableOutputSolverTmp=Xobj.Solver(n).evaluate(TableSolver(:,Xobj.Solver(n).InputNames));
        %TableOutputSolverTmp=array2table(Xobj.CXSolver{n}.evaluate(TableSolver(:,Xobj.CXSolver{n}.Cinputnames)),'VariableNames',Xobj.Coutputnames);
    catch Exception
        warning('OpenCossan:Evaluator:executeWorkersHorizontal:workerFaild',...
            'Unable to execute worker %i of type %s',n,class(Xobj.Solver(n)))
        % Add meaningful error message
        msgID = 'OpenCossan:Evaluator:executeWorkersHorizontal:workerFaild';
        msg = sprintf('Unable to execute worker %i of type %s',n,class(Xobj.Solver(n)));
        causeException = MException(msgID,msg);
        
        % Store Exception in the Analysis object
        Xanalysis.ErrorsStack{end+1} = addCause(Exception,causeException);
        
        % Construct a tableOutputSolverTmp with NaN
        TableOutputSolverTmp=array2table(NaN(height(TableSolver),length(Xobj.Solver(n).OutputNames)),...
            'VariableNames',Xobj.Solver(n).OutputNames);
    end
    % Merge workers output for the currenct analysis
    TableOutputSolver=[TableOutputSolver, TableOutputSolverTmp]; %#ok<AGROW>
    
end
% Merge analysis outputs

% Merge simulation
TableOutput=TableOutputSolver;

