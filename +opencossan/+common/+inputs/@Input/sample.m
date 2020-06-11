function [samples, ds] = sample(obj,varargin)
    %SAMPLE   produce samples of the random variables and stochastic processes defined in the Input
    %object and evaluate eventually the parameters.
    %
    % INPUTS:
    %   The constructor takes a variable number of token value pairs.  These pairs set properties
    %   (optional values) of the method.
    %
    %  Valid PropertyName:
    %  * Nsamples
    %  * Ladd
    %
    % This method DOES NOT generate designofexperiment values for the DesignVariable
    %
    % OUTPUTS: The method returns an Input object as the first optional output and a Sample object
    % as a second argument.
    %
    %  Usage: SAMPLE(XRVS,'Nsamples',NSIM) E.g.:  [Xinput MSAMPLES]=SAMPLE(XRVS,'Nsamples',10)
    %  produces ten samples (rows)
    %
    % See Also: http://cossan.co.uk/wiki/index.php/Sample@Input
    %
    
    % Author: Edoardo Patelli Institute for Risk and Uncertainty, University of Liverpool, UK email
    % address: openengine@cossan.co.uk Website: http://www.cossan.co.uk
    
    % ===================================================================== This file is part of
    % openCOSSAN.  The open general purpose matlab toolbox for numerical analysis, risk and
    % uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify it under the terms of the
    % GNU General Public License as published by the Free Software Foundation, either version 3 of
    % the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
    % the GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License along with openCOSSAN.  If
    %  not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    %% Process inputs
    p = inputParser;
    p.FunctionName = 'opencossan.common.inputs.Input.sample';
    
    % Use default values
    p.addParameter('Samples',1,@(x) ~isinf(x) & floor(x) == x);
    p.addParameter('Perturbation',1, @isnumeric);
    
    p.parse(varargin{:});
    
    samples = table();
    
    for rvset = obj.RandomVariableSets
        samples = [samples sample(rvset, p.Results.Samples)]; %#ok<AGROW>
    end
    
    dvs = obj.DesignVariables;
    names = obj.DesignVariableNames;
    for i = 1:obj.NumberOfDesignVariables
        samples.(names(i)) = sample(dvs(i), 'nsamples', p.Results.Samples, 'perturbation', p.Results.Perturbation);
    end
    
    rvs = obj.RandomVariables;
    names = obj.RandomVariableNames;
    for i = 1:obj.NumberOfRandomVariables
        samples.(names(i)) = sample(rvs(i), p.Results.Samples);
    end
    
    parameters = obj.Parameters;
    names = obj.ParameterNames;
    for i = 1:obj.NumberOfParameters
        samples.(names(i)) = repmat(parameters(i).Value, p.Results.Samples, 1);
    end
    
    funs = obj.Functions;
    names = obj.FunctionNames;
    for i = 1:obj.NumberOfFunctions
        samples.(names(i)) = evaluate(funs(i), samples);
    end
    
    if nargout > 1
        ds = opencossan.common.Dataseries.empty(0, obj.NumberOfStochasticProcesses);
        if obj.NumberOfStochasticProcesses > 0
            for i = 1:obj.NumberOfStochasticProcesses
                ds(1, i) = obj.StochasticProcesses(i).sample('samples', p.Results.Samples);
            end
        end
    end
end
