function Xs     = chop(Xs,varargin)
%CHOP   eliminates samples of the object Samples
%
% This method is intended for eliminating samples from the Samples object
%
%   MANDATORY ARGUMENTS,
%   - Vchopsamples: vector containing samples to be eliminated
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/chop@Dataseries
%
% Author: Matteo Broggi, Edoardo Patelli
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

%% Argument Check
OpenCossan.validateCossanInputs(varargin{:})

%% Chop samples
for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case {'vchopsamples'}
            Vchopsamples=varargin{k+1};
        case {'nchopsamples'}
            Vchopsamples=varargin{k+1};
        otherwise
            error('openCOSSAN:Samples:chop:WrongInputFieldName', ...
                'PropertyName: %s is not a valid input argument',varargin{k})
    end
end

%% Check input
assert(max(Vchopsamples)<=Xs.Nsamples,'openCOSSAN:Samples:chop:ExceedNumberOfSamples',...
    'Required indices (%i) not valid, Samples object contains only %i realizations',...
    max(Vchopsamples),Xs.Nsamples)

%% Remove samples
% Remove realizations of Random Variables 
if ~isempty(Xs.MsamplesHyperCube)
    Xs.MsamplesHyperCube(Vchopsamples,:)= [];
end
% Remove realizations of Design Variables 
if ~isempty(Xs.MdoeDesignVariables)
    Xs.MdoeDesignVariables(Vchopsamples,:)= []; 
end
% Remove realizations of StochasticProcess
if ~isempty(Xs.Xdataseries)
    Xs.Xdataseries = Xs.Xdataseries.chopSamples(Vchopsamples); % Remove samples
end
% Remove weights 
if ~isempty(Xs.Vweights)
    Xs.Vweights(Vchopsamples) = [];
end



