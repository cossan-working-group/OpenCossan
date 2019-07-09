function [TableOutput] = executeWorkersVertical(Xobj,TableInput)
% EXECUTEWORKERSVERTICAL  This is a protected method of evaluator to run the
% analysis in vertical chunks.
%
% It requires a Table  object as input and return a table object
%
%  Usage:  tableOutput = executeWorkersVertical(Xobj,tableInput)
%
% See Also: http://cossan.co.uk/wiki/index.php/executeWorkersVertical@Evaluator
%
%
% Author: Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================


%% Initialization
assert(istable(TableInput),'OpenCossan:Evaluator:executeWorkersVertical:wrongInput',...
    'A Tables object is required as input.\nProvided class %s is not valid',class(TableInput))
% Retrieve Analysis object;
Xanalysis=OpenCossan.getAnalysis;

% Preallocate table
TableOutput=array2table(zeros(height(TableInput),length(Xobj.Coutputnames)),...
                        'VariableNames',Xobj.Coutputnames);

%% Analysis
% The analysis is split over the number of samples and the workers are
% executed sequentially. The n-worker starts after only after the
% execution of the  n-1 worker

for ns=1:height(TableInput)
    % Predefine and reset tableOutput
    TableOutputSolver=[];
    
    % Evaluator execution
    for n=1:length(Xobj.CXsolvers)
        OpenCossan.cossanDisp(['[Status:workers  ]  * Processing solver ' ...
            num2str(n) '/' num2str(length(Xobj.CXsolvers))],3)
        
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
            TableOutputSolverTmp=Xobj.CXsolvers{n}.evaluate(TableSolver(:,Xobj.CXsolvers{n}.Cinputnames));
        catch Exception
            warning('OpenCossan:Evaluator:executeWorkersVertical:workerFaild',...
            'Unable to execute worker %i of type %s',n,class(Xobj.CXsolvers{n}))
            % Add meaningful error message
            msgID = 'OpenCossan:Evaluator:executeWorkersVertical:workerFaild';
            msg = sprintf('Unable to execute worker %i for realization #%i.',n,ns);
            causeException = MException(msgID,msg);
            
            % Store Exception in the Analysis object
            Xanalysis.Cerrors{end+1} = addCause(Exception,causeException);
            
            % Construct a tableOutputSolverTmp with NaN
            TableOutputSolverTmp=array2table(NaN(1,length(Xobj.CXsolvers{n}.Coutputnames)),...
                'VariableNames',Xobj.CXsolvers{n}.Coutputnames);
        end
        % Merge workers output for the currenct analysis
        TableOutputSolver=[TableOutputSolver, TableOutputSolverTmp]; %#ok<AGROW>
        
    end   
    % Merge analysis outputs    
    
    % Merge simulation
    TableOutput(ns,:)=TableOutputSolver; 
end
