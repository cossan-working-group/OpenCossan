function Xsamples = sample(Xobj,varargin)
%SAMPLE
% This method generate a Samples object using Monte Carlo method. This
% method relies on the method sample of the Input Object.
%
% See also: https://cossan.co.uk/wiki/index.php/sample@MonteCarlo
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

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Process inputs

Nsamples=Xobj.Nsamples;

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'nsamples'}
            Nsamples=varargin{k+1};
        case 'xinput'
            Xinput=varargin{k+1};
        case 'xrandomvariableset'
            Xrvset=varargin{k+1};
        otherwise
            error('openCOSSAN:MonteCarlo',...
                ['Input parameter ' varargin{k} ' not allowed '])
    end
    
end

if ~exist('Xrvset','var') && ~exist('Xinput','var') && ~exist('Xinput','var')
    error('openCOSSAN:MonteCarlo:sample',...
        'An Input object or a RandomVariableSet is required')
end



%% generate samples
if exist('Xrvset','var')
    Xsamples = Xrvset.sample('Nsamples',Nsamples);
else
    Xin = Xinput.sample('Nsamples',Nsamples);
    Xsamples=Xin.Xsamples;
end


