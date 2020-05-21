function obj=add(obj,varargin)
%ADD This method adds a worker object to the current Evaluator
%
% See also: Evaluator, Worker
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
[requiredArgs, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
    "Solver", varargin{:});

% Define optional arguments and default values

OptionalsArguments={...
    "Queues","";...
    "Hostnames","";...
    "ParallelEnvironments","";...
    "Slots",[];...
    "MaxCuncurrentJobs",inf;...
    "RemoteInjectExtract", false;...
    "MaxNumberofJobs",[];...
    "SolverName",""};

[optionalArg, ~] = opencossan.common.utilities.parseOptionalNameValuePairs(...
    [OptionalsArguments{:,1}],{OptionalsArguments{:,2}}, varargin{:});

obj.Solver = [obj.Solver requiredArgs.solver];

obj.SolverName = [obj.SolverName optionalArg.solvername];

obj.Queues = [obj.Queues, optionalArg.queues];
obj.Hostnames = [obj.Hostnames, optionalArg.hostnames];
obj.ParallelEnvironments = [obj.ParallelEnvironments, optionalArg.parallelenvironments];
obj.Slots = [obj.Slots, optionalArg.slots];
obj.MaxCuncurrentJobs = [obj.MaxCuncurrentJobs, optionalArg.maxcuncurrentjobs];
obj.MaxNumberofJobs = optionalArg.maxnumberofjobs;

% Validate object
obj=validateObject(obj);
end