function display(Xobj)
%DISPLAY  Displays the summary of the ImportanceSampling object
%
%
% See also: https://cossan.co.uk/wiki/index.php/@ImportanceSampling
%
% Author: Edoardo Patelli
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

OpenCossan.cossanDisp('==============================================',2)
OpenCossan.cossanDisp('=       Importance Sampling  Object          =',1)
OpenCossan.cossanDisp('==============================================',2)
OpenCossan.cossanDisp('',2);
OpenCossan.cossanDisp(['* Description: ' Xobj.Sdescription],2);
OpenCossan.cossanDisp('* Termination Criteria: ',2);
if ~isempty(Xobj.Nsamples)
    OpenCossan.cossanDisp(['** Number of samples: ' sprintf('%e',Xobj.Nsamples)],2);
end
if ~isempty(Xobj.CoV)
    OpenCossan.cossanDisp(['** CoV: ' sprintf('%e',Xobj.CoV)],2);
end
if ~isempty(Xobj.timeout)
    OpenCossan.cossanDisp(['** Max computational time: ' sprintf('%e',Xobj.timeout)],2);
end
OpenCossan.cossanDisp(['** Simulation will perform in ' sprintf('%d',Xobj.Nbatches) ' batches'],1);
if Xobj.Lintermediateresults
    OpenCossan.cossanDisp('** Partial results files will be stored',2);
else
    OpenCossan.cossanDisp('** Partiel results will NOT be provided',2);
end
if isempty(Xobj.XrvsetUD)
    if (Xobj.Lcomputedesignpoint)
        OpenCossan.cossanDisp('',2);
        OpenCossan.cossanDisp('* Proposal distribution AUTOMATICALLY computed on run-time!',1);
        OpenCossan.cossanDisp('',2);
    else
        OpenCossan.cossanDisp('',2);
        OpenCossan.cossanDisp('* Proposal distribution NOT defined!!!',1);
        OpenCossan.cossanDisp('',2);
    end
else
    OpenCossan.cossanDisp('* Proposal sampling distribution:',2);
    for irvs=1:length(Xobj.XrvsetUD)
        display(Xobj.XrvsetUD{irvs})
    end
    OpenCossan.cossanDisp('** Mapping (IS density) (Original density):',2);
    OpenCossan.cossanDisp(Xobj.Cmapping,2);
end
