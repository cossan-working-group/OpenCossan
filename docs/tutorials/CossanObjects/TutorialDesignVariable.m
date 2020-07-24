%% Tutorial DesignVariable
%
% This is a demonstration of the use of DesingVariable object.
%
% The demo starts with the definition of two DesignVariable, then proceeds to
% include these DesignVariable in a Input Object. After that, the
% demo shows how to generate Samples from the Input object containing
% DesignVariable.
%
% See also: https://cossan.co.uk/wiki/index.php/@DesignVariable
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

%% Define a Continuos Design Variable
% This example shows how to define a continuos DesignVariable. The minValue and
% maxValue property names are used to defined the bounds of the DesignVariable
dv1 = opencossan.optimization.ContinuousDesignVariable('value',30,'lowerbound',10,'upperbound',50);

% The content of the object can be see using the dispay method
display(dv1)

%%  Define a Discrete Design Variable
% Discrete Desing Variable are define using the PropertyName Vsupport. It is not
% necessary to specify the bounds of discrete DesignVariable
dv2 = opencossan.optimization.DiscreteDesignVariable('value',3,'support',1:2:13);
% The content of the object can be see using the dispay method
display(dv2)

%% Adding Design Variables to Input
input = opencossan.common.inputs.Input('description','Input Object of our model',...
    'members',{dv1 dv2},'names',["DV1" "DV2"]);


%% Sampling values
% The method sample is used to genarate samples of the object DesignVariable
dv1.sample('samples',10)

dv2.sample('samples',10)

% The samples method can be applied directly to the Input object
samples = input.sample('samples',10);

%% Sampling from DesignVariable with infinite support
% Create a design variable with infinite support

dv3 = opencossan.optimization.ContinuousDesignVariable('value',3);
% Show Design Variable
display(dv3)

% Generate sample for dv3
% It is necessary to define a parturbation around the actual value.
dv3.sample('samples',10,'perturbation',3);


