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
        Coutputnames            % Names of the generated outputs
        Cinputnames             % Names of the required inputs
        CconstraintsNames       % Names of the constraint outputs
        CobjectiveFunctionNames % Names of the objectiveFunction outputs
        CnamesDesignVariables    % names of the DesignVariable
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
            
            
            %% Construct empty object
            if nargin==0
                return
            end
            
            %% Validate Inputs
            OpenCossan.validateCossanInputs(varargin{:});
            
            %% Process inputs arguments
            for k=1:2:length(varargin),
                switch lower(varargin{k}),
                    %2.1.   Description of the object
                    case 'sdescription'
                        Xobj.Sdescription   = varargin{k+1};
                    case 'xobjectivefunction'
                        if isa(varargin{k+1},'ObjectiveFunction')
                            Xobj.XobjectiveFunction  = varargin{k+1};
                        else
                            error('openCOSSAN:OptimizationProblem',...
                                [ inputname(k+1) ' must  be an ObjectiveFunction ']);
                        end
                    case {'cxobjectivefunctions','cxobjectivefunction'}
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n},'ObjectiveFunction'), ...
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
                            assert(isa(varargin{k+1}{n}{:},'ObjectiveFunction'), ...
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
                        if isa(varargin{k+1}(1),'Constraint')
                            Xobj.Xconstraint  = varargin{k+1};
                        else
                            error('openCOSSAN:OptimizationProblem',...
                                [ inputname(k+1) ' must  be a Constrains Object ']);
                        end
                    case 'cxconstraint'
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n},'Constraint'), ...
                                'openCOSSAN:OptimizationProblem',...
                                'CXconstraint must contains only Constraint Object ');
                            if n==1
                                Xobj.Xconstraint= varargin{k+1}{n};
                            else
                                Xobj.Xconstraint(n)= varargin{k+1}{n};
                            end
                        end
                    case {'ccxconstraints' 'ccxconstraint'}
                        for n=1:length(varargin{k+1})
                            assert(isa(varargin{k+1}{n}{:},'Constraint'), ...
                                'openCOSSAN:OptimizationProblem',...
                                'CXconstrains must contains only Constraint Objects ');
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
                            ['Field name (' varargin{k} ') is not valid']);
                end
            end
            
            
            assert(~isempty(Xobj.XobjectiveFunction),...
                'openCOSSAN:OptimizationProblem', ...
                'An objective function is required to define an OptimizationProblem')
            
            %% Check Input and Model
            
            if isempty(Xobj.Xinput)
                % Only Model object is provided
                assert(~isempty(Xobj.Xmodel),...
                    'openCOSSAN:OptimizationProblem', ...
                    'A Model or an Input object is required to define an OptimizationProblem')
                
                switch class(Xobj.Xmodel)
                    case 'Model'
                        Xobj.Xinput=Xobj.Xmodel.Xinput;
                    case 'ProbabilisticModel'
                        Xobj.Xinput=Xobj.Xmodel.Xmodel.Xinput;
                    case {'ResponseSurface' 'NeuralNetwork'}
                        Xobj.Xinput=Xobj.Xmodel.XFullmodel.Xinput;
                    otherwise
                        error('openCOSSAN:OptimizationProblem',...
                            'Models type %s not supported, yet!', class(Xobj.Xmodel))
                end
                
            elseif ~isempty(Xobj.Xmodel)
                
                switch class(Xobj.Xmodel)
                    case 'Model'
                        %% Merge the input of Model with the input containing the DesignVariables
                        Xobj.Xinput=Xobj.Xinput.merge(Xobj.Xmodel.Xinput);
                    case 'ProbabilisticModel'
                        %% Merge the input of Model with the input containing the DesignVariables
                        Xobj.Xinput=Xobj.Xinput.merge(Xobj.Xmodel.Xmodel.Xinput);
                    case {'ResponseSurface' 'NeuralNetwork' 'PolyharmonicSplines'}
                        %% Merge the input of Model with the input containing the DesignVariables
                        % only if the full model is available
                        if ~isempty(Xobj.Xmodel.XFullmodel)
                            Xobj.Xinput=Xobj.Xinput.merge(Xobj.Xmodel.XFullmodel.Xinput);
                        else
                            Xobj.Xinput=Xobj.Xinput.merge(Xobj.Xmodel.XcalibrationInput);
                        end
                    case {'SolutionSequence'}
                        % Do nothing
                    otherwise
                        error('openCOSSAN:OptimizationProblem',...
                            'Models type %s not supported, yet!', class(Xobj.Xmodel))
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
            assert(~isempty(Xobj.Xinput.CnamesDesignVariable), ...
                'openCOSSAN:OptimizationProblem',...
                'The input object must contains at least 1 design variable')
            
            % Check if the output names are unique
            Cout=Xobj.CobjectiveFunctionNames;
            
            assert(length(Cout)==length(unique(Cout)),...
                'openCOSSAN:OptimizationProblem', ...
                'The name of the objective functions name must be unique!/n Outputnames: %s',...
                sprintf('\n* "%s"',Cout{:}))
            
            % Check if the output names are unique
            Cout=Xobj.CconstraintsNames;
            
            assert(length(Cout)==length(unique(Cout)),...
                'openCOSSAN:OptimizationProblem', ...
                'The name of the constraints output name must be unique!/n Outputnames: %s',...
                sprintf('\n* "%s"',Cout{:}))
            
            
            % Set default initial solution
            if isempty(Xobj.VinitialSolution)
                CdefaultValues=Xobj.Xinput.getDefaultValuesCell;
                Xobj.VinitialSolution= cell2mat(CdefaultValues( ...
                    ismember(Xobj.Xinput.Cnames,Xobj.CnamesDesignVariables)))';
            else
                assert(length(Xobj.Xinput.CnamesDesignVariable)==size(Xobj.VinitialSolution,2), ...
                    'openCOSSAN:OptimizationProblem',...
                    ['The length of VinitialSolution (' num2str(size(Xobj.VinitialSolution,2)) ...
                    ') must be equal to the number of design variables (' ...
                    num2str(length(Xobj.Xinput.CnamesDesignVariable)) ')' ] )
            end
            
            %% Check if the input object contains all the variables required by the optimization and contrains
            
            CprovidedInputs=Xobj.Xinput.Cnames;
            if ~isempty(Xobj.Xmodel)
                CprovidedInputs=[CprovidedInputs Xobj.Xmodel.Coutputnames];
            end
            
            assert(all(ismember(Xobj.Cinputnames,CprovidedInputs)), ...
                'openCOSSAN:OptimizationProblem',...
                ['The input object does not contain all the required inputs to ' ...
                'evaluate objective function and constraints. ' ...
                '\nRequired inputs: ' sprintf('\n* "%s"',Xobj.Cinputnames{:}) ...
                '\nDefined inputs: ' sprintf('\n* "%s"',CprovidedInputs{:}) ])
            
        end     %of constructor
        
        display(Xobj)                   % shows the summary of the Xobj
        
        Xoptimum=initializeOptimum(Xobj,varargin) % Initialize an empty Optimum object
        
        function Xobj=addConstraint(Xobj,Xconstraint) % add a new Constraint
            assert(isa(Xconstraint,'Constraint'), ...
                'openCOSSAN:OptimizationProblem:addConstraint',...
                'The object of type %s can not be used here, required a Constraint object',class(Xconstraint))
            if isempty(Xobj.Xconstraint)
                Xobj.Xconstraint=Xconstraint;
            else
                Xobj.Xconstraint(end+1)=Xconstraint;
            end
        end
        
        function Xobj=addObjectiveFunction(Xobj,XobjectiveFunction) % add a new Objective Function
            assert(isa(XobjectiveFunction,'ObjectiveFunction'), ...
                'openCOSSAN:OptimizationProblem:addObjectiveFunction',...
                'The object of type %s can not be used here, required an ObjectiveFunction object',class(XobjectiveFunction))
            
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
            NdesignVariables  = length(Xobj.CnamesDesignVariables);
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
        
        function CnamesDesignVariables = get.CnamesDesignVariables(Xobj)
            CnamesDesignVariables={};
            if ~isempty(Xobj.Xinput)
                CnamesDesignVariables  = Xobj.Xinput.CnamesDesignVariable;
            end
        end
        
        function Cinputnames = get.Cinputnames(Xobj)
            Cinputnames={};
            % Collect inputs required by the Objective function(s)
            for n=1:length(Xobj.XobjectiveFunction)
                Cinputnames=[Cinputnames Xobj.XobjectiveFunction(n).Cinputnames]; %#ok<AGROW>
            end
            % Collect inputs required by the Constraint(s)
            for n=1:length(Xobj.Xconstraint)
                Cinputnames=[Cinputnames Xobj.Xconstraint(n).Cinputnames]; %#ok<AGROW>
            end
            % Collect Inputs required by the model
            if ~isempty(Xobj.Xmodel)
                Cinputnames=[Cinputnames Xobj.Xmodel.Cinputnames];
            end
            % Remove duplicates
            Cinputnames= unique(Cinputnames);
            
        end
        
        function Coutputnames = get.Coutputnames(Xobj)
            Coutputnames=[Xobj.CobjectiveFunctionNames Xobj.CconstraintsNames];
            if ~isempty(Xobj.Xmodel)
                Coutputnames=[Coutputnames Xobj.Xmodel.Coutputnames];
            end
        end
        
        function CobjectiveFunctionNames = get.CobjectiveFunctionNames(Xobj)
            
            CobjectiveFunctionNames={};
            for n=1:length(Xobj.XobjectiveFunction)
                CobjectiveFunctionNames  = [CobjectiveFunctionNames Xobj.XobjectiveFunction(n).Coutputnames]; %#ok<AGROW>
            end
        end
        
        function CconstraintsNames = get.CconstraintsNames(Xobj)
            
            CconstraintsNames={};
            for n=1:length(Xobj.Xconstraint)
                CconstraintsNames  = [CconstraintsNames Xobj.Xconstraint(n).Coutputnames;]; %#ok<AGROW>
            end
        end
        
        function VlowerBounds = get.VlowerBounds(Xobj)
            CnamesDesignVariables=Xobj.CnamesDesignVariables;
            VlowerBounds=zeros(length(CnamesDesignVariables),1);
            for n=1:length(CnamesDesignVariables)
                VlowerBounds(n)=Xobj.Xinput.XdesignVariable.(CnamesDesignVariables{n}).lowerBound;
            end
        end
        
        function VupperBounds = get.VupperBounds(Xobj)
            CnamesDesignVariables=Xobj.CnamesDesignVariables;
            VupperBounds=zeros(length(CnamesDesignVariables),1);
            for n=1:length(CnamesDesignVariables)
                VupperBounds(n)=Xobj.Xinput.XdesignVariable.(CnamesDesignVariables{n}).upperBound;
            end
        end
        
    end     %of methods
    
end     %of classdef
