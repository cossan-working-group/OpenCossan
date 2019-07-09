function disp(Xobj)
%DISP  Displays the summary of the  TABLEEXTRACTOR object
%
% See also: TableExtractor
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


%% 1.   Output to Screen
% 1.1.   Name and description
opencossan.OpenCossan.cossanDisp(' ',3);
opencossan.OpenCossan.cossanDisp('===================================================================',2);
opencossan.OpenCossan.cossanDisp([ class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
opencossan.OpenCossan.cossanDisp('===================================================================',2);
% 1.2.   main paramenters
opencossan.OpenCossan.cossanDisp(['* '  num2str(Xobj.Nresponse) ' responses'],3)
opencossan.OpenCossan.cossanDisp(['* ASCII file: ' Xobj.Srelativepath Xobj.Sfile],3) 

% 1.3.  Response details
for i=1:length(Xobj.Coutputnames)
    opencossan.OpenCossan.cossanDisp(['** Response #' num2str(i) ', Output Name: ' Xobj.Coutputnames{i} ],1) ;
end




