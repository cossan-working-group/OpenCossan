function Xobj=compactTable(Xobj,varargin)
%COMPACTTABLE This function removes duplicate entries in the TablesValues
%on the Optimisation object.
%
% Author: Edoardo Patelli

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


% Initialise value
LingnoreIteration=false;

%%   Argument Check
OpenCossan.validateCossanInputs(varargin{:})

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'lignoreiteration'}   %extract OptimizationProblem
         LingnoreIteration=varargin{k+1};
        otherwise
           error('OpenCossan:Optimum:compactTable:wrongPropertyName', ...
                'The PropertyName %s is not valid. ', varargin{k});
    end
end

unique(Xobj.TablesValues.DesignVariables,'rows')

% Extract table with values of the objective functions that are not NaN
T1=Xoptimum.TablesValues(~isnan(Xoptimum.TablesValues.ObjectiveFnc),[1 2 3]);
% Extract table with values of the constraints functions that are not NaN
T2=Xoptimum.TablesValues(~isnan(Xoptimum.TablesValues.Constraints),[1 2 4]);


T3=innerjoin(T1,T2);


