function [TableOutput] = executeWorkersVertical(Xobj,TableInput)
% EXECUTEWORKERSVERTICAL  This is a protected method of evaluator to run the
% analysis in vertical chunks.
%
% It requires a Table  object as input and return a table object
%
%  Usage:  tableOutput = executeWorkersVertical(Xobj,tableInput)
%
% See Also: Evaluator JobManager
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

%% Initialization
assert(istable(TableInput),'OpenCossan:Evaluator:executeWorkersVertical:wrongInput',...
    'A Tables object is required as input.\nProvided class %s is not valid',class(TableInput))
% Retrieve Analysis object;
Xanalysis=opencossan.OpenCossan.getAnalysis;

% Preallocate table
TableOutput=array2table(zeros(height(TableInput),length(Xobj.OutputNames)),...
                        'VariableNames',Xobj.OutputNames);

%% Analysis
% The analysis is split over the number of samples and the workers are
% executed sequentially. The n-worker starts after only after completition of the
% execution of the  n-1 worker

for ns=1:height(TableInput)
    % Predefine and reset tableOutput
    TableOutputSolver=[];
    opencossan.OpenCossan.cossanDisp(['[Status:workers  ]  * Sample ' ...
            num2str(ns) '/' num2str(height(TableInput))],4)
    % Evaluator execution
    for n=1:length(Xobj.Solver)
        opencossan.OpenCossan.cossanDisp(['[Status:workers  ]  * Processing solver ' ...
            num2str(n) '/' num2str(length(Xobj.Solver))],4)
        
        % Merge tableInput with output produced by the workers and then
        % pass only the inputs required by the specific worker. 
        if n>1
            TableSolver=[TableInput(ns,:) TableOutputSolver];
        else
            TableSolver=TableInput(ns,:);
        end
        
        try
            % Execute worker. 
            % Only the input required by the worker are passes. No recheck
            % is needed in the evaluate method. 
            TableOutputSolverTmp=Xobj.Solver(n).evaluate(TableSolver(:,Xobj.Solver(n).InputNames));
        catch Exception
            warning('OpenCossan:Evaluator:executeWorkersVertical:workerFaild',...
            'Unable to execute worker %i of type %s',n,class(Xobj.Solver{n}))
            % Add meaningful error message
            msgID = 'OpenCossan:Evaluator:executeWorkersVertical:workerFaild';
            msg = sprintf('Unable to execute worker %i for realization #%i.',n,ns);
            causeException = MException(msgID,msg);
            
            % Store Exception in the Analysis object
            Xanalysis.Cerrors{end+1} = addCause(Exception,causeException);
            
            % Construct a tableOutputSolverTmp with NaN
            TableOutputSolverTmp=array2table(NaN(1,length(Xobj.Solver(n).OutputNames)),...
                'VariableNames',Xobj.Solver(n).OutputNames);
        end
        % Merge workers output for the currenct analysis
        TableOutputSolver=[TableOutputSolver, TableOutputSolverTmp]; %#ok<AGROW>
        
    end   
    % Merge analysis outputs    
    
    % Merge simulation
    TableOutput(ns,:)=TableOutputSolver; 
end
