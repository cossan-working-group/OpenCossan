function samples = sample(obj,Nsamples)
%SAMPLE   produce samples of a set of random variables
%
% The method returns a Samples object containing the samples of the
%       set of random variable
%
%  MANDATORY ARGUMENTS
%    - obj:        object of RandomVariableSet - Nsamples:   Includes the
%    number of samples
%
%  OUTPUT ARGUMENTS:
%    - XS:   Vector with the length of Nsamples, which is filled with
%    samples according to the RandomVariablesSet
%
%
%  Example:  XS = obj.sample(Nsamples)
%
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/Sample@RandomVariableSet
%
% Author: Edoardo Patelli Institute for Risk and Uncertainty, University of
% Liverpool, UK email address: openengine@cossan.co.uk Website:
% http://www.cossan.co.uk

%{
This file is part of OpenCossan <https://cossan.co.uk>. Copyright (C)
2006-2018 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License or, (at your
option) any later version.

OpenCossan is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along
with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

assert(isnumeric(Nsamples) && 0 < Nsamples && mod(Nsamples,1) == 0,...
    'openCOSSAN:RandomVariableSet:sample',...
    'The number of samples has to be positiv, numeric and an integer.');

%% Sampling
if obj.isIndependent()
    VX = rand(Nsamples,obj.Nrv);
else
    VX = copularnd('Gaussian', obj.NatafModel.Correlation,Nsamples);
end

VX = cdf2physical(obj, VX);

samples = array2table(VX);
samples.Properties.VariableNames = obj.Names;

end
