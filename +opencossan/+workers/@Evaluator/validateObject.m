function obj=validateObject(obj)
%VALIDATEOBJCECT This is a protected function of Evaluator used to validate
%the inputs.
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

% Validate objects
if obj.VerticalSplit
    Nworkers=1;
else
    Nworkers=length(obj.Solver);
end

if ~isempty(obj.SolverName)
    assert(length(obj.SolverName)==Nworkers,...
        'Evaluator:SolverName:wrongSize',...
        ['Length of SolverNames (' num2str(length(obj.SolverName)) ...
        ') must be equal to the length of Solver (' ...
        num2str(Nworkers) ')' ])
else
    obj.SolverName=repmat("N/A",Nworkers,1);
end

if ~isempty(obj.MaxCuncurrentJobs)
    assert(length(obj.MaxCuncurrentJobs)==Nworkers,...
        'Evaluator:MaxCuncurrentJob:wrongSize',...
        ['Length of MaxCuncurrentJobs (' num2str(length(obj.MaxCuncurrentJobs)) ...
        ') must be equal to the length of Solver (' ...
        num2str(Nworkers) ')' ])
else
    obj.MaxCuncurrentJobs=inf(size(obj.Solver));
end

if ~isempty(obj.Queues)
    assert(length(obj.Queues)==Nworkers,...
        'Evaluator:Queues:wrongSize',...
        'Length of Queues (%i) must be equal to the length of Solver (%i)',...
        length(obj.Queues),Nworkers)
end

if ~isempty(obj.Hostnames)
    assert(length(obj.Hostnames)==Nworkers,...
        'Evaluator:Hostnames:wrongSize',...
        'Length of Hostnames (%i) must be equal to the length of Solver (%i)',...
        length(obj.Hostnames),Nworkers)
end

if ~isempty(obj.ParallelEnvironments)
    assert(length(obj.ParallelEnvironments)==Nworkers,...
        'openCOSSAN:Evaluator',...
        ['Length of ParallelEnvironments (' num2str(length(obj.ParallelEnvironments)) ...
        ') must be equal to the length of Solver (' ...
        num2str(Nworkers) ')' ])
end

if ~isempty(obj.Slots)
    assert(length(obj.Slots)==Nworkers,...
        'openCOSSAN:Evaluator',...
        ['Length of Slots (' num2str(length(obj.Slots)) ...
        ') must be equal to the length of Solver (' ...
        num2str(Nworkers) ')' ])
else
    obj.Slots=ones(size(obj.Solver));
end




