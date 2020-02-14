classdef Input < opencossan.common.CossanObject
    %INPUT  Constructor for the Input object
    % This class is linking the various input objects with the toolboxes of COSSAN X
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Input
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
    
    properties
        DoFunctionsCheck(1,1) logical = true;
        Samples opencossan.common.Samples
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
        NumberOfStochasticProcesses
        % NumberOfSamples
        
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
        % GaussianMixtureRandomVariableSets 
 
        AreDesignVariablesDiscrete
    end
    
    methods
        
        varargout=sample(Xobj,varargin)         % Generate samples from the Input object
        Xobj=add(Xobj,varargin)                 % Add an object to the Input object
        
        Xobj=merge(Xobj,XobjectToBeAdded)       % Merge 2 input objects
        
        varargout=evalpdf(Xobj,varargin)        % evaluate pdf of samples passed as argument
        
        Xo=remove(Xobj,varargin)                % Remove an object from the Input object
        
        Xo=jacobianNataf(Xobj,varargin)         % calculates jacobian matrix associated with point in standard normal space
        
        Tout=getStructure(Xobj)                 % Generate matlab structure with the realizations of input objecs
        
        TableOutput=getTable(Xobj)              % Generate matlab table with the realizations of input objecs
        
        Poutput=getValues(Xobj,varargin)        % Retrieve the value(s) of a single variable
        
        Cout = evaluateFunction(Xobj,varargin)  % Compute the functions
        
        MX = getSampleMatrix(Xobj)              % Retrive reliazation in a matrix format
        
        varargout = getMoments(Xobj,varargin)   % Retrive the moments of Random Variables
        varargout = getStatistics(Xobj,varargin)% Retrieve the Statistic of interest
        varargout = getBounds(Xobj,varargin)    % Retrive the bounds  of Input variables
        
        %mapping between spaces
        varargout=cdf2physical(Xobj,varargin)
        varargout=cdf2stdnorm(Xobj,varargin)
        varargout=map2physical(Xobj,varargin)
        varargout=map2stdnorm(Xobj,varargin)
        varargout=map2uspace(Xobj,varargin)
        varargout=map2deltaSpace(Xobj,varargin)
        
        [MphysicalSpace, Msamplesdoe] = hypercube2physical(Xinput,MsamplesHypercube)
        
        % Set methods
        Xobj=setDesignVariable(Xobj,varargin)
        Xobj=setDesignOfExperiments(Xobj,varargin)
        
        %% constructor
        function obj = Input(varargin)
            %INPUT Constructor method for the Input object.
            %
            % See Also: http://cossan.co.uk/wiki/index.php/@Input
            %
            % Author: Edoardo Patelli Institute for Risk and Uncertainty, University of Liverpool,
            % UK email address: openengine@cossan.co.uk Website: http://www.cossan.co.uk
            
            import opencossan.common.Samples
            import opencossan.common.inputs.*
            import opencossan.optimization.DesignVariable
            
            if nargin == 0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["members", "names"], varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["dofunctionscheck", "samples"], ...
                    {true, Samples.empty(1,0)}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.Members = required.members;
                obj.Names = required.names;
                
                obj.DoFunctionsCheck = optional.dofunctionscheck;
                obj.Samples = optional.samples;
            end
            
            assert(length(obj.Members) == length(obj.Names), ...
                'openCOSSAN:Input:WrongInputLength',...
                'Length of Members (%i) must be equal to the length of MembersNames (%i)', ...
                length(obj.Members),length(obj.Names))
            
            if ~isempty(obj.Samples)
                assert(isempty(setxor(obj.Samples.Cvariables, obj.names)), ...
                    'openCOSSAN:Input:SamplesObjectsMismatchVariables',...
                    ['The variables defined in the Samples object do not match',...
                    ' the variable defined in the Input object)\n',...
                    'Input variables: %s\nSamples variables: %s'],...
                    sprintf(' ''%s'';',obj.XSmples.Cvariables{:}),...
                    sprintf(' ''%s'';',obj.Names));
            end
            
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
        function dvs = get.RandomVariableSets(obj)
            dvs = obj.filterMembers('opencossan.common.inputs.random.RandomVariableSet');
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
        
        function Tdef = getDefaultValuesStructure(Xobj)
            Tdef =  Xobj.get('DefaultValues');
        end
        
        function Cdef = getDefaultValuesCell(Xobj)
            Cdef = struct2cell( Xobj.get('DefaultValues'));
        end
        
        function TableDefault = getDefaultValuesTable(Xobj)
            TableDefault = struct2table( Xobj.get('DefaultValues'),'AsArray',true);
        end
        
        function AreDesignVariablesDiscrete = get.AreDesignVariablesDiscrete(Xobj)
            AreDesignVariablesDiscrete=false;
            CDVNames=Xobj.DesignVariableNames;
            for n=1:length(CDVNames)
                if isa(Xobj.DesignVariables(CDVNames{n}), ...
                        'opencossan.optimization.DiscreteDesignVariable')
                    AreDesignVariablesDiscrete=true;
                    break
                end
            end
        end
        
        checkFunction(Xobj)  %method checking whether the input functions are valid
        
    end % End methods
    
    %% Private Methods
    methods (Access=private)
        % Estimate the function defined in the Input Object and return a cell array
        Cout=evaluateFunctions(Xobj,varargin)
        
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

