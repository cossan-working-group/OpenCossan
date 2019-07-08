function resetRandomNumberGenerator(Nseed)
% RESETRANDOMNUMBERGENERATOR This static method of OpenCossan allows to
% reset the status of the random number generator. 
%
% Resetting a stream should be used primarily for reproducing results.
%
% If the value of the seed is provides, it is used to reinitilised the
% random number generator otherwise the  internal state corresponding to
% the initialised state of the random number generator is used
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

global OPENCOSSAN

assert(~isempty(OPENCOSSAN),'openCOSSAN:OpenCossan:resetRandomNumberGenerator',...
    'OpenCossan has not been initialise. \n Please run OpenCossan! ')

if nargin==0
    reset(OPENCOSSAN.Xanalysis.XrandomStream);
elseif nargin==1    
    OPENCOSSAN.Xanalysis.XrandomStream = RandStream(OPENCOSSAN.Xanalysis.SrandomNumberAlgorithm,'Seed',Nseed);
    RandStream.setGlobalStream(OPENCOSSAN.Xanalysis.XrandomStream)
else
    error('openCOSSAN:OpenCossan:resetRandomNumberGenerator:wrongNumberOfInputArguments',...
        'This method requires only 1 input argument, i.e. the seed of the random number generator')
end
    



            
