function TableOutput = evaluate(Xmio,TableInput)
%EVALUATE This method evaluates the user defined script/function
%
% See Also: https://cossan.co.uk/wiki/
%
%
% Copyright~1993-2018, COSSAN Working Group
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

% Use only required inputs. If some names are not present in the TableInput
% the following line is failing.
TableInput=TableInput(:,Xmio.InputNames);

%% Prepare inputs
switch lower(Xmio.Format)
    case 'structure'
        Tinput=table2struct(TableInput);
        if Xmio.IsFunction
            Toutput  = feval(Xmio.FunctionHandle,Tinput);
        else
            Toutput  = runScript(Xmio,Tinput);
        end
        % Check names of the created structure
        assert(all(isfield(Toutput,Xmio.OutputNames)),...
            'OpenCossan:Mio:evaluate:wrongOutputStructure',...
            ['The computed structure does not contain one or more expected output\n', ...
            'Missing Output: %s'], ...
            sprintf(' "%s"; ',Xmio.OutputNames{~isfield(Toutput,Xmio.OutputNames)}))
        % Construct output Table
        TableOutput=struct2table(Toutput, 'AsArray', true);
    case 'matrix'
        MinputMIO = TableInput{:,:};
        
        if Xmio.IsFunction
            MoutputMIO = feval(Xmio.FunctionHandle,MinputMIO);
        else
            MoutputMIO  = runScript(Xmio,MinputMIO);
        end
        % Check output
        assert(size(MoutputMIO,2)==length(Xmio.OutputNames), ...
            'OpenCossan:Mio:evaluate:wrongOutputMatrix',...
            ['The computed matrix does not contain one or more expected output\n', ...
            ' Output size: %i %i; Expected size: %i %i'], ...
            size(MoutputMIO),height(TableInput),length(Xmio.OutputNames))
        
        TableOutput = array2table(MoutputMIO,'VariableNames',Xmio.OutputNames);
    case 'vectors'  % Function with multiple input and output
        if Xmio.IsFunction           
            % Create Input variables
            Cinput=mat2cell(table2array(TableInput)',ones(1,length(Xmio.InputNames)))';
            Poutput = zeros(height(TableInput),length(Xmio.OutputNames));
            % Define execution script
            Sexec='[';
            for iout=1:length(Xmio.OutputNames)-1
                Sexec=[Sexec 'Poutput(:,' num2str(iout) '), ']; %#ok<AGROW>
            end
            Sexec=[Sexec 'Poutput(:,' num2str(length(Xmio.OutputNames)) ...
                ')]=feval(Xmio.FunctionHandle, Cinput{:});'];
            
            % Evaluate Mio
            eval(Sexec);
        else
            error('OpenCossan:Mio:evaluate:vectorScript',...
                'It is not possible to use vectors format with a script.')
        end
                
        TableOutput=array2table(Poutput,'VariableNames',Xmio.OutputNames);
    case 'table'
        if Xmio.IsFunction
            TableOutput = feval(Xmio.FunctionHandle,TableInput);
        else
            TableOutput  = runScript(Xmio,TableInput);
        end
         % Check output
        assert(all(ismember(TableOutput.Properties.VariableNames,Xmio.OutputNames)),...
            'OpenCossan:Mio:evaluate:wrongOutputTable',...
            ['The computed table does not contain one or more expected output\n', ...
            ' Output name: %s; Expected names: %s'], ...
             sprintf(' "%s"; ',TableOutput.Properties.VariableNames{:}),...
             sprintf(' "%s"; ',Xmio.OutputNames{:}))
    otherwise
        error('OpenCossan:Mio:evaluate:wrongFormat',...
              'Format %s is not valid',Xmio.Format)  
end




