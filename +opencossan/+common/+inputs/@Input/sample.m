function varargout = sample(Xinput,varargin)
%SAMPLE   produce samples of the random variables and stochastic processes
%defined in the Input object and evaluate eventually the parameters.
%
% INPUTS:
%   The constructor takes a variable number of token value pairs.  These
%   pairs set properties (optional values) of the method.
%
%  Valid PropertyName:
%  * Nsamples
%  * Ladd
%
% This method DOES NOT generate designofexperiment values for the DesignVariable
%
% OUTPUTS:
% The method returns an Input object as the first optional output and a
% Sample object as a second argument.
%
%  Usage: SAMPLE(XRVS,'Nsamples',NSIM)
%  E.g.:  [Xinput MSAMPLES]=SAMPLE(XRVS,'Nsamples',10) produces ten samples (rows)
%
% See Also: http://cossan.co.uk/wiki/index.php/Sample@Input
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

import opencossan.common.Samples

%% Process inputs
p = inputParser;
p.FunctionName = 'opencossan.common.inputs.Input.sample';

% Use default values
p.addParameter('Nsamples',1,@(x) ~isinf(x) & floor(x) == x);
p.addParameter('AddSamples',false,@islogical);
p.addParameter('Perturbation',1, @isnumeric);

p.parse(varargin{:});

Nsamples = p.Results.Nsamples;
Ladd = p.Results.AddSamples;
perturbation = p.Results.Perturbation;


% Collect Input Names
CStochasticProcess=Xinput.StochasticProcessNames;
Crvset=[Xinput.RandomVariableSetNames Xinput.GaussianMixtureRandomVariableSetNames];
Cdv=Xinput.DesignVariableNames;

%% Here we go!
% Initialize a Sample object
Xsample=Samples();

% generates samples for all RandomVariableSets
for irvs=1:length(Crvset)
    XsmplAdd=sample(Xinput.RandomVariableSets.(Crvset{irvs}),Nsamples);
    Xsample=Xsample.add('XSamples',XsmplAdd);
end

% generates samples for all StochasticProcesses
for j=1:Xinput.NstochasticProcesses
    XsmplAdd=Xinput.StochasticProcesses.(CStochasticProcess{j}).sample('Samples',Nsamples,'Name',CStochasticProcess{j});
    Xsample=Xsample.add('XSamples',XsmplAdd);
end

% generates samples for DesignVariables
if Xinput.NdesignVariables>0
    Mdv=zeros(Nsamples,Xinput.NdesignVariables);
    for n=1:Xinput.NdesignVariables
        Mdv(:,n)=Xinput.DesignVariables.(Cdv{n}).sample('Nsamples',Nsamples,'perturbation',perturbation);
    end
    XsmplAdd=Samples('CnamesDesignVariable',Xinput.DesignVariableNames,'MdoeDesignVariables',Mdv);
    Xsample=Xsample.add('XSamples',XsmplAdd);
end

% If Ladd is true add generated samples to the sample object present in the Input
if Ladd
    % Check if a Sample object exist in the Input object
    if isa(Xinput.Samples,'Samples') 
        Xinput.Samples=Xinput.Samples.add('XSamples', Xsample);
    else
        warning('openCOSSAN:Input:sample',...
        'Samples not present in the Input object, new samples set created')    
        Xinput.Samples=Xsample;
    end
else
    Xinput.Samples=Xsample;
end

%% Add Samples to the Input object
% Export objects
varargout{1}=Xinput;
varargout{2}=Xsample;
