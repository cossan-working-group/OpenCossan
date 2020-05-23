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


assert(numel(obj.Solver) == numel(obj.SolverName),...
         'Evaluator:IllegalArguments',...
         'Number of solvers (%i) specified must be the same size of SolverName (%i)',...
         numel(obj.Solver),numel(obj.SolverName));
                







