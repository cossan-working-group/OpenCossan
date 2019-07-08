function display(Xobj)
%DISPLAY  Displays the summary of the  Constraint  object
%
% $Copyright~1993-2018,~COSSAN~Working~Group$
% $Author:~Edoardo~Patelli$ 

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


for n=1:length(Xobj)
    XcurrentObj=Xobj(n);


%%  Output to Screen
%  Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([' Constraint Object - Description: ' XcurrentObj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',2);

if isempty(XcurrentObj.Coutputnames)
    OpenCossan.cossanDisp(' * Empty object ',1)
else
    
    OpenCossan.cossanDisp([' * Input Variables: ' sprintf('%s; ',XcurrentObj.Cinputnames{:})],2)
    
    if XcurrentObj.Linequality
        OpenCossan.cossanDisp(sprintf(' * Inequality constraint: %s ',XcurrentObj.Coutputnames{1}),2)
    else
        OpenCossan.cossanDisp(sprintf(' * Equality constraint: %s ',XcurrentObj.Coutputnames{1}),2)
    end
end

    
end
