function Xmkv = buildChain(Xmkv,Npoints)
%BUILDCHAIN  Create MARKOV CHAINS
%
% This method will populate the Tree substructure of the Xmarkovchain
% object
%
% The optional inputs is:
% * Npoints  = length of the chains
%
% See also: https://cossan.co.uk/wiki/index.php/buildChain@MarkovChain
%
% ==================================================================
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

if nargin<=1
    Npoints=1;
end

%% Construct chain
for c=1:Npoints
    XsampleOffSpring = offspring(Xmkv);
    
    % Add Samples to the MarkovChain
    Xmkv.Samples(c+1)=XsampleOffSpring;
end




