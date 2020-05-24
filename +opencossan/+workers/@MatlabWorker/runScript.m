function [Poutput]=runScript(Xmio,Psamples)
% RUNSCRIPT This is a private method to evaluate the script.
% This method is called by the method run@Mio
% It returns a SimulationData and whatever is returned by the user script
%
% See Also: http://cossan.co.uk/wiki/index.php/runScript@Mio
%
%
% Copyright~1993-2015, COSSAN Working Group
%
% Author: Edoardo Patelli, Matteo Broggi
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

import opencossan.OpenCossan

switch lower(Xmio.Format)
    case 'structure'
        % Rename input
        Tinput = checkPinput(Xmio,Psamples);    %check input
        % Preallocate memory
        Cpreallocate=num2cell(zeros(length(Tinput),length(Xmio.OutputNames)));
        if isempty(Xmio.OutputNames)
            Toutput=struct;
        else
            Toutput = cell2struct(Cpreallocate, Xmio.OutputNames, 2);
        end
    case 'matrix'
        % Convert the Psamples into a Matrix
        Minput = checkPinput(Xmio,Psamples);
        % Preallocate memory
        Moutput = zeros(size(Minput,1),length(Xmio.OutputNames));
    case 'table'
        % Rename input
        TableInput=Psamples;
        TableOutput = array2table(zeros(height(TableInput),length(Xmio.OutputNames)));
        TableOutput.Properties.VariableNames = Xmio.OutputNames;
    otherwise
        error('OpenCossan:Mio:runScript:wrongFormat',...
            'Format %s is not valid in runScript',Xmio.Format)
end


%% Execute the script
if isempty(Xmio.Script)   %checks how the script was defined
    try
        OpenCossan.cossanDisp('[Mio:runScript] Running user defined script',4)
        run(Xmio.FullFileName);        %runs script contained in a file line by line
        OpenCossan.cossanDisp('[Mio:runScript] Execution of user defined script completed',4)
    catch ME
        error('OpenCossan:mio:errorRunningScript',...
            strcat('The user define function can not be evaluate.! \n', ...
            'Please check your function or script!!!\n ',...
            '* Error msg: %s\n* Filename : %s\n* Line num : %i'), ...
            ME.message,ME.stack(1).name,ME.stack(1).line)
        
    end
else
    try
        OpenCossan.cossanDisp('[Mio:runScript] Evaluate matlab script',4)
        eval(Xmio.Script);     %evaluates directly commands contained in the field Xmio.Sscript
        OpenCossan.cossanDisp('[Mio:runScript] End evaluation of the matlab script',4)
    catch ME
        error('OpenCossan:mio:errorRunningScript',...
            [' The user define script can not be evaluate! ' ...
            ' Please check your script \n' ME.message])
        
    end
end

%% Prepare the output
switch lower(Xmio.Format)
    case 'table'
        Poutput = TableOutput;
    case 'structure'
        Poutput = Toutput;
    case 'matrix'
        Poutput = Moutput;
end

