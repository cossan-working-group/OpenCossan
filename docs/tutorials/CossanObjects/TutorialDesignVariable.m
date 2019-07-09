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

clear;
close all
clc;

%% Define a Continuos Design Variable
% This example shows how to define a continuos DesignVariable. The minValue and
% maxValue property names are used to defined the bounds of the DesignVariable
DV1 = opencossan.optimization.DesignVariable('value',30,'minvalue',10,'maxvalue',50);

% The content of the object can be see using the dispay method
display(DV1)

%%  Define a Discrete Design Variable
% Discrete Desing Variable are define using the PropertyName Vsupport. It is not
% necessary to specify the bounds of discrete DesignVariable
DV2 = opencossan.optimization.DesignVariable('value',3,'Vsupport',1:2:13);
% The content of the object can be see using the dispay method
display(DV2)

%% Adding Design Variables to Input
Xin   = opencossan.common.inputs.Input('description','Input Object of our model',...
    'members',{DV1 DV2},'membersnames',{'DV1' 'DV2'});
% It is possible to retrieve the name of the DesignVariable using the method
% CnamesDesignVariabl@Input
Xin.DesignVariableNames % Names of DVs

% The number of designVariable are shown by the method NdesignVariables@Input
Xin.NdesignVariables     % Number of DVs

%% Sampling values
% The method sample is used to genarate samples of the object DesignVariable
Vout1=DV1.sample('Nsamples',10)

Vout2=DV2.sample('Nsamples',10)

% The samples method can be applied directly to the Input object
Xin=Xin.sample('Nsamples',10);
% The matrix of sampled values is stored in the field MdoeDesignVariables of the
% Samples object.
disp(Xin.sample.setDesignVariable)

%% Sampling from DesignVariable with infinite support
% Create a design variable with infinite support

DV3 = DesignVariable('value',3);
% Show Design Variable
display(DV3)

% Generate sample for DV3
% It is necessary to define a parturbation around the actual value.
Vout3=DV3.sample('Nsamples',10,'perturbation',3);

Xinput=Input('Xdesignvariable',DV3);


