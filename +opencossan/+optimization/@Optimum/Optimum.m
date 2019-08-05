classdef Optimum
    %OPTIMUM   Constructor of Optimum object; this object contains the
    %solutions of an optimization problem.
    %
    % See Also: TutorialOptimum OptimisationProblem
    %
    % Author: Edoardo Patelli
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

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
    
    
    %% Properties of the object
    properties
        Sdescription                    % Description of the object
        Sexitflag                       % exit flag of optimization algorithm
        totalTime                       % time required to solve problem
        XOptimizationProblem            % assosiated optimization problem
        XOptimizer                      % optimizer used to solve the problem
        Niterations=0;                 % number of iteration/generation
        VoptimalDesign=[];              % design variables values at the optimal solution
        VoptimalScores=[];              % objective function values at the optimal solution
        VoptimalConstraints=[];         % constraint values at the optimal solution
        TablesValues = table();                 % tables containing all the values
        % creared during the optimisation process
        NevaluationsModel=0              % number of model evaluations
        NevaluationsObjectiveFunctions=0 % number of evaluations of the objective function
        NevaluationsConstraints=0        % number of evaluations of the constraints
        NcandidateSolutions=0            % number of candidate solutions
    end
    
    properties (Dependent=true)
        CconstraintsNames              % names of the Constraints
        CobjectiveFunctionNames        % names of the ObjectiveFunctions
        CdesignVariableNames           % names of the Design Variables
    end
    
    %% Methods of the class
    methods
        display(Xobj)  % shows the summary of the Optimum object
        
        varargout=plotOptimum(Xobj,varargin); % Main function used to plot values stored in the Optimum object
        
        varargout=plotObjectiveFunction(Xobj,varargin) % Display the evolution of the
        % ObjectiveFunction
        
        varargout=plotConstraint(Xobj,varargin) % Display the evolution of the
        % Constraint
        varargout=plotDesignVariable(Xobj,varargin) % Display the evolution of the
        % DesignVariables
        
        Xobj=merge(Xobj,Xoptimum) % Merge 2 Optimum objects
        
        Xobj=compactTable(Xobj,varargin) % Remove duplicate entry in the table
        
        function Xobj  = Optimum(varargin)
            %% Constructor
            % OPTIMUM   Constructor of Optimum object; this object contains the
            % solution of an optimization problem. Whenever an optimization
            % method is run using the method "apply", the output will be an
            % Optimum object.
            % The constructor takes a variable number of optional tokens of
            % PropertyName and values pairs.
            % Valid PropertyName are:
            %
            %
            % See Also: OptimisationProblem Optimizer
            %
            % Copyright 2006-2018 COSSAN Working Group,
            % Author: Edoardo Patelli
            
            %% Validate input arguments
            vararginTable={};
            LaddIteration=false;

            %%  Set values passed by the user
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case 'totaltime'
                        Xobj.totalTime=varargin{k+1};
                    case 'sexitflag'
                        Xobj.Sexitflag=varargin{k+1};
                    case {'vdesignvariable', 'mdesignvariable','mdesignvariables' ...
                          'vobjectivefunction','mobjectivefunction', 'mobjectivefunctions',...
                          'vobjectivefunctiongradient','mobjectivefunctiongradient', ...
                          'vconstraintgradient', 'mconstraintgradient', ...
                          'vvaluesconstraint','viterations','niteration'}
                        vararginTable{end+1}=varargin{k};   %#ok<AGROW>
                        vararginTable{end+1}=varargin{k+1}; %#ok<AGROW>
                        LaddIteration=true;
                    case 'xoptimizationproblem'
                        assert(ismember(class(varargin{k+1}),...
                            {'opencossan.optimization.OptimizationProblem',...
                             'opencossan.optimization.RBOProblem',...
                             'opencossan.optimization.RobustDesign',...
                             'opencossan.optimization.ExtremeCase'}), ...
                            'OpenCossan:Optimum:Optimum', ...
                            'A object of type %s is not valid after the PropertyName %s',...
                            class(varargin{k+1}),varargin{k});
                        Xobj.XOptimizationProblem=varargin{k+1};
                    case 'xoptimizer'
                        mc=metaclass(varargin{k+1});
                        if isempty(mc.SuperClasses)
                            error('OpenCossan:Optimum:wrongOptimizer', ...
                                ['An Optimizer is expected after the PropertyName ' varargin{k}]);
                        else
                            assert(strcmp(mc.SuperClasses{1}.Name,'opencossan.optimization.Optimizer'),...
                                'OpenCossan:Optimum:wrongOptimizer', ...
                                ['An Optimizer is expected after the PropertyName ' varargin{k}]);
                        end
                        Xobj.XOptimizer=varargin{k+1};
                    otherwise
                        error('OpenCossan:Optimum:wrongPropertyName', ...
                            'The PropertyName %s is not valid. ', varargin{k});
                end
            end
       
            
            if LaddIteration               
                Xobj.TablesValues=initialaseTable(Xobj,vararginTable{:});                
            else
                %% No iterations
                % Initialise the Optimum object with an empty table
                Xobj.TablesValues=table;
            end
  

        end     %of constructor
        
        function NcandidateSolutions=get.NcandidateSolutions(Xobj)       % number of evaluations of the constraints
            NcandidateSolutions=Xobj.XdesignVariable(1).VdataLength;
        end
        
        % Ger names of the design variables
        function CdesignVariableNames=get.CdesignVariableNames(Xobj)
            if isempty(Xobj.XOptimizationProblem)
                CdesignVariableNames={};
            else
                CdesignVariableNames=Xobj.XOptimizationProblem.DesignVariableNames;
            end
        end
        
        
        function CconstraintsNames=get.CconstraintsNames(Xobj)       % number of evaluations of the constraints
            if isempty(Xobj.XOptimizationProblem)
                CconstraintsNames={};
            else
                CconstraintsNames=Xobj.XOptimizationProblem.ConstraintNames;
            end
        end
        
        function CobjectiveFunctionNames=get.CobjectiveFunctionNames(Xobj)       % number of evaluations of the constraints
            if isempty(Xobj.XOptimizationProblem)
                CobjectiveFunctionNames={};
            else
                CobjectiveFunctionNames=Xobj.XOptimizationProblem.ObjectiveFunctionNames;
            end
        end
        
        Xobj=addIteration(Xobj,varargin);
        obj = recordObjectiveFunction(obj, varargin);
    end     %of methods
    
    methods (Access = private)
        TablesValues=initialaseTable(Xobj,varargin)
    end        
    
end     %of classdef
