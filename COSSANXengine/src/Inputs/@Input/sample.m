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

%% Process inputs
OpenCossan.validateCossanInputs(varargin{:});

% Set default values

Ladd=false; % If false, the samples present in the input object are replaced by a new set of values 

perturbation=1;


if isempty(varargin)
    Nsamples = 1;
else
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'nsample','nsamples'} % Define the number of samples
                Nsamples = varargin{k+1};
            case {'ladd','laddsamples'} % Flag to add the new samples to the previous ones.
                Ladd = varargin{k+1};  
            case {'perturbation'} % Flag to add the new samples to the previous ones.
                perturbation = varargin{k+1};
            otherwise
                error('openCOSSAN:Input:sample:wronginput',...
                    'Argument name %s not valid',varargin{k})
        end
    end
end

% Collect Input Names
CStochasticProcess=Xinput.CnamesStochasticProcess;
Crvset=[Xinput.CnamesRandomVariableSet Xinput.CnamesGaussianMixtureRandomVariableSet];
Cdv=Xinput.CnamesDesignVariable;

%% Here we go!
% Initialize a Sample object
Xsample=Samples();

% generates samples for all RandomVariableSets
for irvs=1:length(Crvset)
    XsmplAdd=sample(Xinput.Xrvset.(Crvset{irvs}),Nsamples);
    Xsample=Xsample.add('Xsamples',XsmplAdd);
end


% generates samples for all StochasticProcesses
for j=1:Xinput.NstochasticProcesses
    XsmplAdd=Xinput.Xsp.(CStochasticProcess{j}).sample('Nsamples',Nsamples,'Sname',CStochasticProcess{j});
    Xsample=Xsample.add('Xsamples',XsmplAdd);
end

% generates samples for DesignVariables
if Xinput.NdesignVariables>0
    Mdv=zeros(Nsamples,Xinput.NdesignVariables);
    for n=1:Xinput.NdesignVariables
        Mdv(:,n)=Xinput.XdesignVariable.(Cdv{n}).sample('Nsamples',Nsamples,'perturbation',perturbation);
    end
    XsmplAdd=Samples('CnamesDesignVariable',Xinput.CnamesDesignVariable,'MdoeDesignVariables',Mdv);
    Xsample=Xsample.add('Xsamples',XsmplAdd);
end

% If Ladd is true add generated samples to the sample object present in the Input
if Ladd
    % Check if a Sample object exist in the Input object
    if isa(Xinput.Xsamples,'Samples') 
        Xinput.Xsamples=Xinput.Xsamples.add('Xsamples', Xsample);
    else
        warning('openCOSSAN:Input:sample',...
        'Samples not present in the Input object, new samples set created')    
        Xinput.Xsamples=Xsample;
    end
else
    Xinput.Xsamples=Xsample;
end

%% Add Samples to the Input object
% Export objects
varargout{1}=Xinput;
varargout{2}=Xsample;
