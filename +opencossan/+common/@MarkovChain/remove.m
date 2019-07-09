function Xmkv = remove(Xmkv,varargin)
%REMOVE  Remove samples from the Markov Chains
%
% This method remove samples from specific Markov Chains. The length of the
% chains is restored comping the latest valid sample of the chain.
%
% The optional inputs is:
% * Npoints  = length of the chain
% * Vchain   = Specific with chain must be dropped 
%
% See also: https://cossan.co.uk/wiki/index.php/remove@MarkovChain
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


% Default values
Nremove=1; %The last chain

%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'npoints','nchainlength'}
            Nremove = varargin{k+1};
        case {'vchain','chain'}
            Vchain = varargin{k+1};
        otherwise
            error('openCOSSAN:MarkovChain:remove',...
                 'PropertyName %s is not allowed',varargin{k})
    end
end

if exist('Vchain','var')
    
    Mreplicated=Xmkv.Samples(end-Nremove).MsamplesHyperCube(Vchain,:);
    
    for ichain=0:Nremove-1
        MHCubeSamples=Xmkv.Samples(end-ichain).MsamplesHyperCube; %Retrive Samples object
        MHCubeSamples(Vchain,:) = Mreplicated;
        % Modify the samples 
        Xmkv.Samples(end-ichain).MsamplesHyperCube=MHCubeSamples;
    end
else
    % Drop the last "Nremove" links from the Markov Chains
    Xmkv.Xsamples=Xmkv.Xsamples(1:end-Nremove);
end
