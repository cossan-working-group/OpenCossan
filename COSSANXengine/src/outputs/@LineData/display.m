function display(Xobj)
%DISPLAY  Displays the object LineSamplingOutput
%
%
% See also: https://cossan.co.uk/wiki/index.php/@LineSamplingOutput
%
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
%   Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' Object  - Description: ' Xobj.Sdescription ],2);
OpenCossan.cossanDisp('===================================================================',3);

OpenCossan.cossanDisp(['* Number of Variables: ' num2str(Xobj.Nvars)],2)
% if length(Xobj(1).Cnames)<=50
%     OpenCossan.cossanDisp(['**',sprintf(' %s;',Xobj.Cnames{:})], 2)
% end

% for iout=1:length(Xobj)
%     OpenCossan.cossanDisp(['* Batch: ' num2str(iout) ' - Number of realizations: ',  num2str(NtotalPoints) ],2)
% end

Vbatches=[Xobj.Tdata.ibatch];
VnumLinesPerBatch=zeros(1,Xobj.Nbatches);
for i=1:Xobj.Nbatches
    VnumLinesPerBatch(1,i)=sum(Vbatches==i);
end
OpenCossan.cossanDisp(['* Number of Batches: ', num2str(Xobj.Nbatches)],2)
if Xobj.Nbatches~=1
    OpenCossan.cossanDisp(['  - lines per batch: ',  num2str(VnumLinesPerBatch)],2)
end
%OpenCossan.cossanDisp(['  - last batch lines: ',  num2str(sum(Vbatches==Xobj.Nbatches))],2)
%OpenCossan.cossanDisp(['- last batch realizations: ',  num2str(sum(Vbatches==Xobj.Nbatches)) ],2)

% OpenCossan.cossanDisp(['* Exit Flag: ' Xobj.SexitFlag ],2)

%% Show specific results
OpenCossan.cossanDisp(['* Number of processed lines:  ' num2str(Xobj.NprocessedLines) ],2)

OpenCossan.cossanDisp(['* Number of lines:  ' num2str(Xobj.Nlines) ],2)

OpenCossan.cossanDisp(['* Number of lines crossing the state boundary:  ' num2str(Xobj.NcrossingLines) ],2)

%OpenCossan.cossanDisp(['* Number of lines for conditional probabilities:  ' num2str(Xobj.NeffectiveLines) ],2)

if ~Xobj.NprocessedLines==0
    OpenCossan.cossanDisp(['* Total number of evaluations:  ' num2str(Xobj.Nevaluations) ],2)
else
    OpenCossan.cossanDisp(['* Total number of evaluations:  ' num2str(0) ],2)
end
