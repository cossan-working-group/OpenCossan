function [samples, obj] = sample(obj,varargin)
%SAMPLE This method generate a Samples object using the selected DOE type
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/sample@DesignOfExperiments
%
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

import opencossan.common.Dataseries
import opencossan.common.Samples

required = opencossan.common.utilities.parseRequiredNameValuePairs("input", varargin{:});
validateattributes(required.input, {'opencossan.common.inputs.Input'}, {'scalar'});

input = required.input;

% Check the validity of inputs
% Check whether or not any RandomVariable or DeseignVariables are defined
assert(input.NumberOfRandomInputs + input.NumberOfDesignVariables > 0, ...
    'OpenCossan:DesignOfExperiments:samples', ...
    'The provided input does not contain any DesignVariables or RandomVariables.')

if input.NumberOfDesignVariables > 0
    lb = [input.DesignVariables.LowerBound];
    ub = [input.DesignVariables.UpperBound];
    
    assert(~any(isinf([lb, ub])), 'openCOSSAN:DesignOfExperiments:sample',...
        'All DesignVariables must be bounded.');
end

switch obj.DesignType
    case "BoxBehnken"
        [samples, obj] = obj.boxbehnken(input);
    case "2LevelFactorial"
        [samples, obj] = obj.twolevelfactorial(input);
    case "FullFactorial"
        [samples, obj] = obj.fullfactorial(input);
    case "CentralComposite"
        [samples, obj] = obj.centralcomposite(input);
    case "UserDefined"
        [samples, obj] = obj.userdefined(input);
end

samples = input.addParametersToSamples(samples);
samples = input.evaluateFunctionsOnSamples(samples);

return
