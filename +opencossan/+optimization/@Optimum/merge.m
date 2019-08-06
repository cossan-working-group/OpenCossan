function Xobj = merge(Xobj,Xobj2)
%MERGE merge 2 Optimium objects
%
%   MANDATORY ARGUMENTS
%   - Xobj2: Optimum object
%
%   OUTPUT
%   - Xobj: object of class Optimum
%
%   USAGE
%   Xobj = Xobj.merge(Xobj2)
%
% See Also https://cossan.co.uk/wiki/index.php/Merge@Optimum
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

%%    Argument Check
assert(isa(Xobj2,'Optimum'), ...
    'OpenCossan:Optimum:merge',...
    ' The object passed to this function is of type %s\nRequired type Optimum.', class(Xobj2));


%% Merge Properties
Xobj.Sdescription=strcat(Xobj.Sdescription,' | ', Xobj2.Sdescription); % Description of the object
Xobj.Sexitflag=strcat(Xobj.Sexitflag,' | ', Xobj2.Sexitflag);       % exit flag of optimization algorithm
Xobj.totalTime=Xobj.totalTime+Xobj2.totalTime;                      % time required to solve problem

assert(all(ismember(Xobj.CdesignVariableNames,Xobj2.CdesignVariableNames)),...
        'openCOSSAN:Optimum:merge',...
        strcat('The two optimum objects must contain the same designvaliable name',...
        '\nObj1: Design Variable name %s\nObj1: Design Variable name %s'), ...
        sprintf(Xobj.CdesignVariableNames{:}),sprintf(Xobj2.CdesignVariableNames{:}))
    
 
% DO MERGE    
Xobj.TablesValues=outerjoin(Xobj.TablesValues,Xobj2.TablesValues,'MergeKeys',true);