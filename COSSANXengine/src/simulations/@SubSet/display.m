function display(Xobj)
%DISPLAY  Displays the summary of the SUBSET object
%
% See also: https://cossan.co.uk/wiki/index.php/@Subset
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
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' Object  - Description: ' Xobj.Sdescription ],2);
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp(['Intermediate threshold         : ' sprintf('%e',Xobj.Ntarget_pf)],2);
OpenCossan.cossanDisp(['Max number of levels           : ' sprintf('%i',Xobj.Nmaxlevels)],2);
OpenCossan.cossanDisp(    ['Initial sample (for each batch): '  sprintf('%i',Xobj.NinitialSimxBatch)],3);
if Xobj.NinitialSimxBatch~=Xobj.NinitialSimLastBatch
    OpenCossan.cossanDisp(['Initial sample (last batch)    : '  sprintf('%i',Xobj.NinitialSimLastBatch)],3);
end
if Xobj.Nbatches==1
    OpenCossan.cossanDisp(['Simulation performed in        : ' sprintf('%d',Xobj.Nbatches) ' batch'],3);
else
    OpenCossan.cossanDisp(['Simulation performed in        : ' sprintf('%d',Xobj.Nbatches) ' batches'],3);
end
if Xobj.Lintermediateresults
    OpenCossan.cossanDisp('Partial results files          : will be stored',3);
else
    OpenCossan.cossanDisp('Partial results files          : will NOT be stored',3);
end

OpenCossan.cossanDisp('--------------------------------------------------------------------',3)
OpenCossan.cossanDisp('Termination Criteria: ',2);
if ~isempty(Xobj.Nsamples)
    OpenCossan.cossanDisp(['Number of samples              : ' sprintf('%e',Xobj.Nsamples)],2);
end

if ~isempty(Xobj.CoV)
    OpenCossan.cossanDisp(['CoV: ' sprintf('%e',Xobj.CoV)],2);
end
if ~isempty(Xobj.timeout)
    OpenCossan.cossanDisp(['Max computational time: ' sprintf('%e',Xobj.timeout)],2);
end
OpenCossan.cossanDisp('--------------------------------------------------------------------',3)


if ~isempty(Xobj.VproposalStd)
    OpenCossan.cossanDisp( 'Conditional samples            : SubSim-\infty algorithm',2);
    OpenCossan.cossanDisp(['Proposed standard deviation(s) : ' sprintf('%i',Xobj.VproposalStd)],3);
else
    OpenCossan.cossanDisp( 'Conditional samples            : SubSim-MCMC',2);
    OpenCossan.cossanDisp(['Number of Markov chains        : ' sprintf('%i',Xobj.Nmarkovchainssimxbatch)],3);
    OpenCossan.cossanDisp(['Length of Markov chains        : ' sprintf('%i',Xobj.Nmarkovchainsamples)],3);
    if isempty(Xobj.XproposedDistributionSet)
        OpenCossan.cossanDisp(['Proposal distribution witdh    : ' sprintf('%i',Xobj.Vdeltaxi)],3);
    else
        OpenCossan.cossanDisp('Using user defined proposal distribution',3);
    end
end








