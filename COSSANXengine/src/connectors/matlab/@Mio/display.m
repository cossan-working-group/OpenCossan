function display(Xobj)
%DISPLAY  Displays the summary of the  MATLAB INPUT/OUTPUT (mio) object
%
% See also: https://cossan.co.uk/wiki/index.php/@Mio
%
% Author: Edoardo Patelli, Matteo Broggi
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

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

%%  Output to Screen
%  Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' Object - Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',2);
% 1.2.   main paramenters
OpenCossan.cossanDisp(' ');

if Xobj.Lfunction
    OpenCossan.cossanDisp([' * Matlab function file: ' fullfile(Xobj.Spath,Xobj.Sfile) '.m'],1);
    
    if Xobj.Liostructure
        OpenCossan.cossanDisp ([' * Input/Ouput passed as structures: e.g. Toutput = ' Xobj.Sfile '(Tinput)'],2)
    elseif Xobj.Liomatrix
        OpenCossan.cossanDisp ([' * Input/Ouput passed as matrixies: e.g. Moutput = ' Xobj.Sfile '(Minput)'],2)
    else
        OpenCossan.cossanDisp ([' * Input/Ouput passed using multiple inputs and outputs: e.g. [Output1,Output2,...] = ' Xobj.Sfile '(Input1,Input2,...)'],2)
    end
    
    if Xobj.Lcompiled
        OpenCossan.cossanDisp(' Mio object has been already compiled ',2);
    end
else
    if isempty(Xobj.Sscript)
        OpenCossan.cossanDisp([' * Matlab script file: ' fullfile(Xobj.Spath,Xobj.Sfile) ],1);
    else
        OpenCossan.cossanDisp(' * Matlab script defined in the field Sscript',1);
    end
end


if ~isempty(Xobj.Cinputnames)
    OpenCossan.cossanDisp([' * Input Variables: ' sprintf('%s; ',Xobj.Cinputnames{:})],2)
end
if ~isempty(Xobj.Coutputnames)
    OpenCossan.cossanDisp([' * Output Variables: ' sprintf('%s; ',Xobj.Coutputnames{:})],2)
end


