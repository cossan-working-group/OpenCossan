classdef Input < opencossan.common.CossanObject
    %INPUT  Constructor for the Input object
    % This class is linking the various input objects with the toolboxes of COSSAN X
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Input
    %
    % Author: Edoardo Patelli Institute for Risk and Uncertainty, University of Liverpool, UK email
    % address: openengine@cossan.co.uk Website: http://www.cossan.co.uk
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2020 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    properties
        DoFunctionsCheck(1,1) logical = true;
    end
    
    properties (SetAccess = private)
        Members(1, :) = {}
        Names(1, :) string = []
    end
    
    properties (Dependent = true)
        NumberOfInputs
        NumberOfParameters
        NumberOfFunctions
        NumberOfDesignVariables 
        NumberOfRandomVariables 
        NumberOfRandomVariableSets
        NumberOfGaussianMixtureRandomVariableSets
        NumberOfStochasticProcesses
        
        ParameterNames
        FunctionNames
        DesignVariableNames
        RandomVariableNames
        RandomVariableSetNames
        StochasticProcessNames
        GaussianMixtureRandomVariableSetNames 
        
        Parameters
        Functions
        DesignVariables 
        RandomVariables
        RandomVariableSets
        StochasticProcesses
        GaussianMixtureRandomVariableSets 
 
        AreDesignVariablesDiscrete
        
        InputNames
        RandomInputNames
        NumberOfRandomInputs
    end
    
    methods
        
        samples = sample(obj, varargin)             % Generate samples from the Input object
        
        obj = add(obj, varargin)                    % Add an object to the Input object
        obj = remove(obj, varargin)                 % Remove an object from the Input object
        
        varargout = getMoments(obj, varargin)       % Retrive the moments of Random Variables
        varargout = getStatistics(obj, varargin)    % Retrieve the Statistic of interest
        varargout = getBounds(obj, varargin)        % Retrive the bounds  of Input variables
        
        %mapping between spaces
        samples = cdf2physical(obj, samples)
        samples = cdf2stdnorm(obj, samples)
        samples = map2physical(obj, samples)
        samples = map2stdnorm(obj, samples)
        samples = hypercube2physical(obj, samples)
        
        %% constructor
        function obj = Input(varargin)
            %INPUT Constructor for the Input object.
            %
            % See Also: http://cossan.co.uk/wiki/index.php/@Input
                       
            if nargin == 0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["members", "names"], varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["dofunctionscheck"], {true}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.Members = required.members;
                obj.Names = required.names;
                
                obj.DoFunctionsCheck = optional.dofunctionscheck;
            end
            
            assert(length(obj.Members) == length(obj.Names), ...
                'openCOSSAN:Input:WrongInputLength',...
                'Length of Members (%i) must be equal to the length of MembersNames (%i)', ...
                length(obj.Members),length(obj.Names))
            
            if obj.NumberOfFunctions > 0 && obj.DoFunctionsCheck
                checkFunction(obj)
            end
        end
        
        function n = get.NumberOfInputs(obj)
            n = numel(obj.Members);
        end
        
        %% Dependent Parameter properties
        
        function parameters = get.Parameters(obj)
            parameters = obj.filterMembers('opencossan.common.inputs.Parameter');
        end
        
        function n = get.NumberOfParameters(obj)
            n = numel(obj.Parameters);
        end
        
        function names = get.ParameterNames(obj)
            names = obj.filterNames('opencossan.common.inputs.Parameter');
        end
        
        %% Dependent Function properties
        function funs = get.Functions(obj)
            funs = obj.filterMembers('opencossan.common.inputs.Function');
        end
        
        function n = get.NumberOfFunctions(obj)
            n = numel(obj.Functions);
        end
        
        function names = get.FunctionNames(obj)
            names = obj.filterNames('opencossan.common.inputs.Function');
        end
        
        %% Dependent RandomVariable properties
        function rvs = get.RandomVariables(obj)
            rvs = obj.filterMembers('opencossan.common.inputs.random.RandomVariable');
        end
        
        function n = get.NumberOfRandomVariables(obj)
            n = numel(obj.RandomVariables);
        end
        
        function names = get.RandomVariableNames(obj)
            names = obj.filterNames('opencossan.common.inputs.random.RandomVariable');
        end
        
        %% Dependent DesignVariable properties
        function dvs = get.DesignVariables(obj)
            dvs = obj.filterMembers('opencossan.optimization.DesignVariable');
        end
        
        function n = get.NumberOfDesignVariables(obj)
            n = numel(obj.DesignVariables);
        end
        
        function names = get.DesignVariableNames(obj)
            names = obj.filterNames('opencossan.optimization.DesignVariable');
        end
        
        %% Dependent RandomVariableSet properties
        function rvsets = get.RandomVariableSets(obj)
            rvsets = obj.filterMembers('opencossan.common.inputs.random.RandomVariableSet');
            if isempty(rvsets)
                rvsets = opencossan.common.inputs.random.RandomVariableSet.empty(0, 0);
            end
        end
        
        function n = get.NumberOfRandomVariableSets(obj)
            n = numel(obj.RandomVariableSets);
        end
        
        function names = get.RandomVariableSetNames(obj)
            names = obj.filterNames('opencossan.common.inputs.random.RandomVariableSet');
        end
        
        %% Dependent StochasticProcess properties
        function sps = get.StochasticProcesses(obj)
            sps = obj.filterMembers('opencossan.common.inputs.StochasticProcess');
        end
        
        function n = get.NumberOfStochasticProcesses(obj)
            n = numel(obj.StochasticProcesses);
        end
        
        function names = get.StochasticProcessNames(obj)
            names = obj.filterNames('opencossan.common.inputs.StochasticProcess');
        end
        
        %% Dependent GaussianMixtureRandomVariableSets properties
        function gsmrvset = get.GaussianMixtureRandomVariableSets(obj)
            gsmrvset = obj.filterMembers('opencossan.common.inputs.GaussianMixtureRandomVariableSets');
        end
        
        function n = get.NumberOfGaussianMixtureRandomVariableSets(obj)
            n = numel(obj.GaussianMixtureRandomVariableSets);
        end
        
        function names = get.GaussianMixtureRandomVariableSetNames(obj)
            names = obj.filterNames('opencossan.common.inputs.GaussianMixtureRandomVariableSets');
        end
        
        %%
        
        function names = get.InputNames(obj)
            names = obj.Names;
            for set = obj.RandomVariableSets
                names = [names set.Names]; %#ok<AGROW>
            end
            [~, idx] = ismember(obj.RandomVariableSetNames, names);
            names(idx) = [];
        end
        
        function names = get.RandomInputNames(obj)
            names = obj.RandomVariableNames;
            for set = obj.RandomVariableSets
                names = [names set.Names]; %#ok<AGROW>
            end
        end
        
        function n = get.NumberOfRandomInputs(obj)
            n = obj.NumberOfRandomVariables;
            for set = obj.RandomVariableSets
                n = n + set.Nrv;
            end
        end
        
        function discrete = get.AreDesignVariablesDiscrete(obj)
            discrete = any(arrayfun(@(dv) isa(dv, 'opencossan.optimization.DiscreteDesignVariable'), ...
                obj.DesignVariablesdescrete));
        end       
        
        values = getDefaultValues(obj);
        checkFunction(obj);
        samples = completeSamples(obj, samples);
    end
    
    %% Private Methods
    methods (Access=private)        
        function members = filterMembers(obj, type)
            idx = cellfun(@(m) isa(m, type), obj.Members);
            members = [obj.Members{idx}];
        end
        
        function members = filterNames(obj, type)
            idx = cellfun(@(m) isa(m, type), obj.Members);
            members = obj.Names(idx);
        end
    end
    
end

