function Xsample = sample(Xobj,varargin)
%SAMPLE Generate realisations from a GaussianMixtureRandomVariableSet.
%
%  SAMPLE(Xobj,Nsamples) creates a Samples object contining Nsamples
%  realizations. The samples are created according the distribution defined
%  in the GaussianRandomVariable object
%
%  OPTIONAL ARGUMENT
%    - Nsamples: the number of sample to compute. If unspecified, one
%      sample is computed.
% See also:
% https://cossan.co.uk/wiki/index.php/sample@GaussianMixtureRandomVariableSet
%
% Author: Silvia Tolo, Matteo Broggi, Edoardo Patelli
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
%  Usage: XS=Xobj.SAMPLE(Nsamples)


%% Process arguments

if nargin==0
    Nsamples = 1;
elseif length(varargin)==1
    Nsamples = varargin{1};
else
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'nsample','nsamples'} % Define the number of samples
                Nsamples = varargin{k+1};
            otherwise
                error('openCOSSAN:GaussianMixtureRandomVariableSet:WrongInput',...
                    'Option %s not implemented',varargin{k})
        end
    end
end




if isempty(Xobj.Mcoeff)||isempty(Xobj.Vconstraints)
    %% No bounds defined: use method random of gmdistribution class
    MphysicalSpace = random(Xobj.gmDistribution,Nsamples);
else
    MphysicalSpace = Xobj.generatePhysicalSamples(Nsamples);
end

%% Construct the Samples Object
Xsample = Samples('XgaussianRandomVariableSet',Xobj,'MsamplesPhysicalSpace',MphysicalSpace);

end



