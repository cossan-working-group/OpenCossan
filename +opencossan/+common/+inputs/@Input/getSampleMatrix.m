function MX = getSampleMatrix(Xinput)
%GETSAMPLEMATRIX Get samples in a matrix format of the variables defined in the
%Input object
%
% Author: Edoardo Patelli 
% Copyright~1993-2015, COSSAN Working Group, University of Liverpool, UK
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


if ~isempty(Xinput.StochasticProcessNames)
    warning('openCOSSAN:Input:getSampleMatrix',...
        'the sample of StochasticProcess objects are not in the matrix');
    
end

% retrive variables
if isa(Xinput.Samples,'opencossan.common.Samples')
    Msamples  = Xinput.Samples.MsamplesPhysicalSpace;
    Mdoe      = Xinput.Samples.MdoeDesignVariables;
    
    if isempty(Msamples)
        MX      = Mdoe;
    elseif isempty(Mdoe)
        MX      = Msamples;
    else
        assert(size(Msamples,1)==size(Mdoe,1), ...
        'openCOSSAN:Input:getSampleMatrix', ...
        'Number of samples of the random variables (%i) does not agree with the number of samples of the design variables (%i)', ...
        size(Msamples,2),size(Mdoe,2))
    MX = [Msamples Mdoe];
    end
 
end


return
