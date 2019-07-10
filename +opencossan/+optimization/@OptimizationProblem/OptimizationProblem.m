classdef OptimizationProblem
    %   This class allows defining an optimization problem. The objective
    %   function and constraints are defined using the object Function. The
    %   parameters associated with the problem are defined using a Input
    %   object and the design variables are defined by means of a cell of
    %   Parameters
    
    % Properties
    properties (SetAccess=protected)
        Xmodel              % Model to be evaluated object
        Xinput              % Input of the model (with DesignVariables)
        XobjectiveFunction  % Objective function(s)
        Xconstraint         % Constraint(s)
    end
    
    properties
        Sdescription       % description of optimization problem
        VinitialSolution   % vector of the initial solution
        VweightsObjectiveFunctions % Vector of weights for the objective functions
    end
    
    properties (Dependent = true, SetAccess = protected)
        OutputNames            % Names of the generated outputs
        InputNames             % Names of the required inputs
        ConstraintsNames       % Names of the constraint outputs
        ObjectiveFunctionNames % Names of the objectiveFunction outputs
        DesignVariableNames    % names of the DesignVariable
        NdesignVariables        % Total number of DesignVariable
        NobjectiveFunctions     % Total number of ObjectiveFunction
        Nconstraints            % Total number of Constraints
        Linequality             % Type of inequality constraints
        VlowerBounds            % Lower Bounds of the DesignVariable
        VupperBounds            % Upper Bounds of the DesignVariable
    end
    
    %%   Methods inherited from the superclass
    methods
        
        function Xobj    = OptimizationProblem(varargin)
            %OPTIMIZATIONPROBLEM This method defines a OptimizationProblem object
            %
            %   The object contains: ObjectiveFunction, Constraint, and a Model
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/@OptimizationProblem
            %
            % Copyright 1993-2011, COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo-Patelli
            
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
            % 
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
            %
            
            import opencossan.optimization.*
            
            %% Construct empty object
            if nargin==0
                return
            end
            
            %% Validate Inputs
            opencossan.OpenCossan.validateCossanInputs(varargin{:});
            
            %% Process inputs arguments
            for k=1:2:length(varargin),
                switch lower(varargin{k}),
                    %2.1.   Description of the object
                    case 'sdescription'
                        Xobj.Sdescription   = varargin{k+1};
                    case 'xobjectivefunction'
                        if isa(varargin{k+1},'opencossan.optimization.ObjectiveFunction')
                            Xobj.XobjectiveFunction  = varargin{k+1};
                        else
                            error('openCOSSAN:OptimizationProblem',...
                                [ inputname(k+1) ' must  be an ObjectiveFunction ']);
                        end
                    case 'cxobjectivefunctions'
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n},'opencossan.optimization.ObjectiveFunction'), ...
                                'openCOSSAN:OptimizationProblem',...
                                'CXobjectivefunctions must contains only ObjectiveFunction Objects ');
                            if n==1
                                Xobj.XobjectiveFunction= varargin{k+1}{n};
                            else
                                Xobj.XobjectiveFunction(n)= varargin{k+1}{n};
                            end
                        end
                        
                    case 'ccxobjectivefunctions'
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n}{:},'opencossan.optimization.ObjectiveFunction'), ...
                                'openCOSSAN:OptimizationProblem',...
                                'CXobjectivefunctions must contains only ObjectiveFunction Objects ');
                            if n==1
                                Xobj.XobjectiveFunction= varargin{k+1}{n}{:};
                            else
                                Xobj.XobjectiveFunction(n)= varargin{k+1}{n}{:};
                            end
                        end
                    case 'xconstraint'
                        % Add constraint object
                        if isa(varargin{k+1}(1),'opencossan.optimization.Constraint')
                            Xobj.Xconstraint  = varargin{k+1};
                        else
                            error('openCOSSAN:OptimizationProblem',...
                                [ inputname(k+1) ' must  be a optimization.Constrains Object ']);
                        end
                    case 'cxconstraint'
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n},'opencossan.optimization.Constraint'), ...
                                'openCOSSAN:OptimizationProblem',...
                                'CXconstraint must contains only optimization.Constraint Object ');
                            if n==1
                                Xobj.Xconstraint= varargin{k+1}{n};
                            else
                                Xobj.Xconstraint(n)= varargin{k+1}{n};
                            end
                        end
                    case {'ccxconstraints' 'ccxconstraint'}
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n}{:},'opencossan.optimization.Constraint'), ...
                                'openCOSSAN:OptimizationProblem',...
                                'CXconstrains must contains only optimization.Constraint Objects ');
                            if n==1
                                Xobj.Xconstraint= varargin{k+1}{n}{:};
                            else
                                Xobj.Xconstraint(n)= varargin{k+1}{n}{:};
                            end
                        end
                    case {'vinitialsolution','minitialsolutions'}
                        Xobj.VinitialSolution   = varargin{k+1};
                    case {'vweightsobjectivefunctions'}
                        Xobj.VweightsObjectiveFunctions = varargin{k+1};
                    case 'xmodel'
                        Xobj.Xmodel   = varargin{k+1};
                    case 'cxmodel'
                        Xobj.Xmodel   = varargin{k+1}{1};
                    case 'xinput'
                        Xobj.Xinput   = varargin{k+1};
                    case 'cxinput'
                        Xobj.Xinput   = varargin{k+1}{1};
                    otherwise
                        error('openCOSSAN:OptimizationProblem',...
                            'Field name %s is not valid',varargin{k});
                end
            end
            
            
            assert(~isempty(Xobj.XobjectiveFunction),...
                'openCOSSAN:OptimizationProblem:noObjectiveFunction', ...
                'An objective function is required to define an OptimizationProblem')
            
            %% Check Input and Model
            
            if isempty(Xobj.Xinput)
                % Only Model object is provided
                assert(~isempty(Xobj.Xmodel),...
                    'openCOSSAN:OptimizationProblem:noModel', ...
                    'A Model or an Input object is required to define an OptimizationProblem')
                
                switch class(Xobj.Xmodel)
                    case 'opencossan.common.Model'
                        Xobj.Xinput=Xobj.Xmodel.Xinput;
                    case 'opencossan.reliability.ProbabilisticModel'
                        Xobj.Xinput=Xobj.Xmodel.Xmodel.Xinput;
                    otherwise
                        if strcmp(superclasses(Xobj.Xmodel),'opencossan.metamodels.MetaModels')
                            Xobj.Xinput=Xobj.Xmodel.XFullmodel.Xinput;
                        else
                            error('openCOSSAN:OptimizationProblem',...
                                'Object of type %s not supported, yet!', class(Xobj.Xmodel))
                        end
                end
                
            elseif ~isempty(Xobj.Xmodel)
                
                switch class(Xobj.Xmodel)
                    case 'opencossan.common.Model'
                        %% Merge the input of Model with the input containing the DesignVariables
                        Xobj.Xinput=Xobj.Xinput.merge(Xobj.Xmodel.Xinput);
                    case 'opencossan.reliability.ProbabilisticModel'
                        %% Merge the input of Model with the input containing the DesignVariables
                        Xobj.Xinput=Xobj.Xinput.merge(Xobj.Xmodel.Xmodel.Xinput);
                    case {'opencossan.workers.SolutionSequence'}
                        % Do nothing
                    otherwise
                        if strcmp(superclasses(Xobj.Xmodel),'opencossan.metamodels.MetaModel')
                            %% Merge the input of Model with the input containing the DesignVariables
                            % only if the full model is available
                            if ~isempty(Xobj.Xmodel.XFullmodel)
                                Xobj.Xinput=Xobj.Xinput.merge(Xobj.Xmodel.XFullmodel.Xinput);
                            else
                                Xobj.Xinput=Xobj.Xinput.merge(Xobj.Xmodel.XcalibrationInput);
                            end
                        else
                            error('openCOSSAN:OptimizationProblem',...
                                'Models type %s not supported, yet!', class(Xobj.Xmodel))
                        end
                end
            else
                % Only Input object provided
                % Nothing to do
            end
            
            
            if isempty(Xobj.VweightsObjectiveFunctions)
                Xobj.VweightsObjectiveFunctions=ones(length(Xobj.XobjectiveFunction),1);
            end
            
            assert(length(Xobj.XobjectiveFunction)==length(Xobj.VweightsObjectiveFunctions), ...
                'openCOSSAN:OptimizationProblem', ...
                'Length of the weights (%i) does not match with the number of objective function (%i)', ...
                length(Xobj.VweightsObjectiveFunctions), length(Xobj.XobjectiveFunction))
            
            
            %% Validate Constructor
            assert(~isempty(Xobj.Xinput.DesignVariableNames), ...
                'openCOSSAN:OptimizationProblem',...
                'The input object must contains at least 1 design variable')
            
            % Check if the output names are unique
            Cout=Xobj.ObjectiveFunctionNames;
            
            assert(length(Cout)==length(unique(Cout)),...
                'openCOSSAN:OptimizationProblem', ...
                'The name of the objective functions name must be unique!/n Outputnames: %s',...
                sprintf('\n* "%s"',Cout{:}))
            
            % Check if the output names are unique
            Cout=Xobj.ConstraintsNames;
            
            assert(length(Cout)==length(unique(Cout)),...
                'openCOSSAN:OptimizationProblem', ...
                'The name of the constraints output name must be unique!/n Outputnames: %s',...
                sprintf('\n* "%s"',Cout{:}))
            
            
            % Set default initial solution
            if isempty(Xobj.VinitialSolution)
                CdefaultValues=Xobj.Xinput.getDefaultValuesCell;
                Xobj.VinitialSolution= cell2mat(CdefaultValues( ...
                    ismember(Xobj.Xinput.Names,Xobj.DesignVariableNames)))';
            else
                assert(length(Xobj.Xinput.DesignVariableNames)==size(Xobj.VinitialSolution,2), ...
                    'openCOSSAN:OptimizationProblem',...
                    ['The length of VinitialSolution (' num2str(size(Xobj.VinitialSolution,2)) ...
                    ') must be equal to the number of design variables (' ...
                    num2str(length(Xobj.Xinput.DesignVariableNames)) ')' ] )
            end
            
            %% Check if the input object contains all the variables required by the optimization and contrains
            
            CprovidedInputs=Xobj.Xinput.Names;
            if ~isempty(Xobj.Xmodel)
                CprovidedInputs=[CprovidedInputs Xobj.Xmodel.OutputNames];
            end
            
            assert(all(ismember(Xobj.InputNames,CprovidedInputs)), ...
                'openCOSSAN:OptimizationProblem',...
                ['The input object does not contain all the required inputs to ' ...
                'evaluate objective function and constraints. ' ...
                '\nRequired inputs: ' sprintf('\n* "%s"',Xobj.InputNames{:}) ...
                '\nDefined inputs: ' sprintf('\n* "%s"',CprovidedInputs{:}) ])
            
        end     %of constructor
        
        display(Xobj)                   % shows the summary of the Xobj
        
        Xoptimum=initializeOptimum(Xobj,varargin) % Initialize an empty Optimum object
        
        function Xobj=addConstraint(Xobj,Xconstraint) % add a new Constraint
            assert(isa(Xconstraint,'opencossan.optimization.Constraint'), ...
                'openCOSSAN:OptimizationProblem:addConstraint',...
                'The object of type %s can not be used here, required a optimization.Constraint object',class(Xconstraint))
            if isempty(Xobj.Xconstraint)
                Xobj.Xconstraint=Xconstraint;
            else
                Xobj.Xconstraint(end+1)=Xconstraint;
            end
        end
        
        function Xobj=addObjectiveFunction(Xobj,XobjectiveFunction) % add a new Objective Function
            assert(isa(XobjectiveFunction,'optimization.ObjectiveFunction'), ...
                'openCOSSAN:OptimizationProblem:addObjectiveFunction',...
                'The object of type %s can not be used here, required an optimization.ObjectiveFunction object',class(XobjectiveFunction))
            
            Xobj.XobjectiveFunction(end+1)=XobjectiveFunction;
        end
        
        
        %% Method optimize
        function  [Xopt, varargout]  = optimize(Xobj,varargin)
            
            assert(~isempty(varargin),'openCOSSAN:OptimizationProblem:optimize',...
                'Missing input argument!');
            OpenCossan.validateCossanInputs(varargin{:})
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'xoptimizer'
                        Xoptimizer=varargin{k+1};
                        npos=k;
                        break
                    case 'cxoptimizer'
                        Xoptimizer=varargin{k+1}{1};
                        npos=k;
                        break
                end
            end
            
            % Remove optimizer from varargin
            varargin=varargin([1:npos-1 npos+2:end]);
            
            % This method call the apply method of the Optimizer object
            [Xopt, XSimOutput]  = Xoptimizer.apply('XOptimizationProblem',Xobj,varargin{:});
            if nargout>1
                varargout{1}=XSimOutput;
            end
        end % of optimize
        
        %% Dependent Fields
        function NdesignVariables = get.NdesignVariables(Xobj)
            NdesignVariables  = length(Xobj.DesignVariableNames);
        end
        
        function Nconstraints = get.Nconstraints(Xobj)
            Nconstraints=length(Xobj.Xconstraint);
        end
        
        function NobjectiveFunctions = get.NobjectiveFunctions(Xobj)
            NobjectiveFunctions=length(Xobj.XobjectiveFunction);
        end
        
        function Linequality = get.Linequality(Xobj)
            Linequality=true(length(Xobj.Xconstraint),1);
            for n=1:length(Xobj.Xconstraint)
                Linequality(n)= Xobj.Xconstraint(n).Linequality;
            end
        end
        
        function DesignVariableNamess = get.DesignVariableNames(Xobj)
            DesignVariableNamess  = Xobj.Xinput.DesignVariableNames;
        end
        
        function Cinputnames = get.InputNames(Xobj)
            Cinputnames={};
            % Collect inputs required by the Objective function(s)
            for n=1:length(Xobj.XobjectiveFunction)
                Cinputnames=[Cinputnames Xobj.XobjectiveFunction(n).InputNames]; %#ok<AGROW>
            end
            % Collect inputs required by the Constraint(s)
            for n=1:length(Xobj.Xconstraint)
                Cinputnames=[Cinputnames Xobj.Xconstraint(n).InputNames]; %#ok<AGROW>
            end
            % Collect Inputs required by the model
            if ~isempty(Xobj.Xmodel)
                Cinputnames=[Cinputnames Xobj.Xmodel.InputNames];
            end
            % Remove duplicates
            Cinputnames= unique(Cinputnames);
            
        end
        
        function Coutputnames = get.OutputNames(Xobj)
            Coutputnames=[Xobj.ObjectiveFunctionNames Xobj.ConstraintsNames];
            if ~isempty(Xobj.Xmodel)
                Coutputnames=[Coutputnames Xobj.Xmodel.Coutputnames];
            end
        end
        
        function CobjectiveFunctionNames = get.ObjectiveFunctionNames(Xobj)
            
            CobjectiveFunctionNames={};
            for n=1:length(Xobj.XobjectiveFunction)
                CobjectiveFunctionNames  = [CobjectiveFunctionNames Xobj.XobjectiveFunction(n).OutputNames]; %#ok<AGROW>
            end
        end
        
        function CconstraintsNames = get.ConstraintsNames(Xobj)
            
            CconstraintsNames={};
            for n=1:length(Xobj.Xconstraint)
                CconstraintsNames  = [CconstraintsNames Xobj.Xconstraint(n).OutputNames;]; %#ok<AGROW>
            end
        end
        
        function VlowerBounds = get.VlowerBounds(Xobj)
            DesignVariableNamess=Xobj.DesignVariableNames;
            VlowerBounds=zeros(length(DesignVariableNamess),1);
            for n=1:length(DesignVariableNamess)
                VlowerBounds(n)=Xobj.Xinput.XdesignVariable.(DesignVariableNamess{n}).lowerBound;
            end
        end
        
        function VupperBounds = get.VupperBounds(Xobj)
            DesignVariableNamess=Xobj.DesignVariableNamess;
            VupperBounds=zeros(length(DesignVariableNamess),1);
            for n=1:length(DesignVariableNamess)
                VupperBounds(n)=Xobj.Xinput.XdesignVariable.(DesignVariableNamess{n}).upperBound;
            end
        end
        
    end     %of methods
    
end     %of classdef
