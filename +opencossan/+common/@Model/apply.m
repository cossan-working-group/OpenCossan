function XsimData = apply(obj, input)
% APPLY This method evaluates the Model

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2018 COSSAN WORKING GROUP

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

import opencossan.OpenCossan

% OpenCossan.getTimer().lap('description','[Model Apply] Start model evaluation')

%  Evaluator execution
XsimData = apply(obj.Evaluator, input);
XsimData.Description = strjoin(XsimData.Description, " - apply(@Model)");

% OpenCossan.getTimer().lap('description','[Model Apply] Stop model evaluation')

