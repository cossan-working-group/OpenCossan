function display(Xobj)
%DISPLAY  Displays a summary of the INTERVAL object
%
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

%% Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',2);

if ~isempty(Xobj.Vdata)
    Sstring=sprintf('%10.3e',Xobj.Vdata(1:5));
    if length(Xobj.Vdata)>5,
        Sstring     = [Sstring ' ...'];
    end
    OpenCossan.cossanDisp(['* data set: ' Sstring ],3);
end

OpenCossan.cossanDisp(['* lower and upper bounds: ' sprintf('[%9.3e, %9.3e]', Xobj.lowerBound,Xobj.upperBound) ],1);
OpenCossan.cossanDisp(['* center: ' sprintf('%9.3e', Xobj.centre) ],2);
OpenCossan.cossanDisp(['* radius: ' sprintf('%9.3e', Xobj.radius) ],2);