function display(Xobj)
%DISPLAY   Displays the information related to the IntervalSet
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

for ibset=1:length(Xobj)
    
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp([' ' class(Xobj) ' Description: ' Xobj.Sdescription ] ,3);
    OpenCossan.cossanDisp('===================================================================',3);
    
    NmaxShowIV=5;
    
    if Xobj(ibset).Lindependence
        OpenCossan.cossanDisp([' Set of ' num2str(Xobj(ibset).Niv) ' independent Interval variables'],2)
    elseif isempty(Xobj(ibset).Lindependence)
        OpenCossan.cossanDisp(' Set of 0 independent Interval variables',2)
    else
        OpenCossan.cossanDisp([' Set of ' num2str(Xobj(ibset).Niv) ' CORRELATED Interval variables'],2)
    end
    
    if Xobj.Niv<=NmaxShowIV
        OpenCossan.cossanDisp([' * Names: ' ...
            sprintf('"%s" ',Xobj(ibset).Cmembers{:}) ],3);
    elseif isempty(Xobj.Cmembers)
        OpenCossan.cossanDisp([' * Names: ' ...
            sprintf('"%s" ',Xobj(ibset).Cmembers) ],3);
    else
        OpenCossan.cossanDisp([' * Names: ' ...
            sprintf('"%s" ',Xobj(ibset).Cmembers{1:NmaxShowIV}) ],3);
    end
    
    
    if ~Xobj(ibset).Lindependence
        switch Xobj.ScorrelationFlag
            case '1'
                OpenCossan.cossanDisp(' * Correlation shape: box',2)
            case '2'
                OpenCossan.cossanDisp(' * Correlation shape: ellipse',2)
            case '3'
                OpenCossan.cossanDisp(' * Correlation shape: polytope',2)
        end
    end
end


