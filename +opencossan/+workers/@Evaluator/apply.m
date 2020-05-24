function XSimData = apply(Xobj,Pinput)
% APPLY  The method used the Input provided to evaluate the Evaluator
% object and returns an object of type SimulationData.
% The accepted input are:
% * Table object
% * Input object
% * Structure
% * Samples object
%
%  Usage:  XSimout = Xev.apply(Pinput)
%
% See Also: Evaluator, Worker
%
%
% Author: Edoardo Patelli
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

import opencossan.common.outputs.SimulationData
import opencossan.highperformancecomputing.*

%% Process Inputs
switch class(Pinput)
    case 'opencossan.common.inputs.Input'
        if isempty(Pinput.Samples) 
            % Use the default values (i.e. mean) of the Random Variables
            % if no samples are present in the Input object
            TableInput=Pinput.getDefaultValuesTable;
        else
            TableInput=Pinput.getTable;
        end
    case 'struct'
        TableInput = struct2table(Pinput);
    case 'table'
        % This should be the default way to pass the realizations to the
        % Evaluator object
        TableInput=Pinput;
    otherwise
        error('openCOSSAN:evaluator:apply:wrongInputType',...
            'The input of type %s is not supported',class(Pinput));
end

% Add input variables to the SimulationData object
XSimInp=SimulationData('Table',TableInput);

if isempty(Xobj.Solver)
    XSimData=XSimInp;
    % Add input samples to the Simulation output object
    XSimData.Sdescription= 'created by the Evaluator with no workers';
    return
end

if Xobj.VerticalSplit    
    % Setting the JobManager
    if ~isempty(Xobj.JobManager)
        % TODO: Not implemented
        TableOutput=executeWorkersGrid(Xobj,XSimInp);
    else        
        TableOutput=executeWorkersVertical(Xobj,TableInput);
    end
else
 
    % Setting the JobManager
    if ~isempty(Xobj.JobManager)
        % TODO: Not implemented
        TableOutput=executeWorkersGrid(Xobj,XSimInp);
    else        
        TableOutput=executeWorkersHorizontal(Xobj,TableInput);  
    end
end
% Export data 
XSimData=SimulationData('Table',TableOutput);
XSimData=XSimData.merge(XSimInp);
