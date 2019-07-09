classdef Optimum
    %OPTIMUM   Constructor of Optimum object; this object contains the
    %solutions of an optimization problem.
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Optimum
    %
    % Author: Edoardo Patelli and Matteo Broggi and Marco de Angelis
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
    
    
    %% Properties of the object
    properties
        Sdescription                    % Description of the object
        Sexitflag                       % exit flag of optimization algorithm
        totalTime                       % time required to solve problem
        CdesignVariableNames            % names of the Design Variables
        XdesignVariable                 % values design variables
        XobjectiveFunction              % values of the ObjectiveFunction
        XobjectiveFunctionGradient      % values of the Gradient of the ObjectiveFunction
        Xconstrains                     % values of the constraints
        XconstrainsGradient             % values of the constrains'gradient
        XOptimizationProblem            % assosiated optimization problem
        XOptimizer                      % optimizer used to solve the problem
        NevaluationsModel=0             % number of model evaluations 
        NevaluationsObjectiveFunctions=0  % number of evaluations of the objective function
        NevaluationsConstraints=0         % number of evaluations of the constraints
        Niterations=-1;                  % number of iteration/generation
        VoptimalDesign=[];               % design variables values at the optimal solution
        VoptimalScores=[];               % objective function values at the optimal solution
    end
    
    properties (Dependent=true)
        NcandidateSolutions           % Number of candidate solutions
        CconstraintsNames             % Names of the constraints
        CobjectiveFunctionNames       % Names of the objectiveFunctions
    end
    
    %% Methods of the class
    methods
        display(Xobj)  % shows the summary of the Optimum object
        
        varargout=plotObjectiveFunction(Xobj,varargin) % Display the evolution of the
        % ObjectiveFunction
        
        varargout=plotConstraint(Xobj,varargin) % Display the evolution of the
        % Constraint
        varargout=plotDesignVariable(Xobj,varargin) % Display the evolution of the
        % DesignVariables
        
        Xobj=merge(Xobj,Xoptimum) % Merge 2 Optimum objects
        
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
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Optimum
            %
            % Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo Patelli
            
            %% Validate input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            
            %%  Set values passed by the user
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case 'totaltime'
                        Xobj.totalTime=varargin{k+1};
                    case 'sexitflag'
                        Xobj.Sexitflag=varargin{k+1};
                    case 'cdesignvariablenames'
                        Xobj.CdesignVariableNames=varargin{k+1};
                    case 'xdesignvariabledataseries'
                        Xobj.XdesignVariable=varargin{k+1};
                    case 'xobjectivefunctiondataseries'
                        Xobj.XobjectiveFunction=varargin{k+1};
                    case 'xobjectivefunctiongradientdataseries'
                        Xobj.XobjectiveFunctionGradient=varargin{k+1};
                    case {'xconstrainsdataseries' 'xconstraintdataseries'}
                        Xobj.Xconstrains=varargin{k+1};
                    case {'xconstrainsgradientdataseries' 'xconstraintgradientdataseries'}
                        Xobj.XconstrainsGradient=varargin{k+1};
                    case 'xoptimizationproblem'
                        assert(ismember(class(varargin{k+1}),...
                            {'opencossan.optimization.OptimizationProblem',...
                            'opencossan.optimization.RBOProblem',...
                            'opencossan.optimization.RobustDesign',...
                            'opencossan.intervals.ExtremeCase'}), ...
                            'openCOSSAN:Optimum:Optimum', ...
                            'A object of type %s is not valid after the PropertyName %s',...
                            class(varargin{k+1}),varargin{k});
                        Xobj.XOptimizationProblem=varargin{k+1};
                    case 'xoptimizer'
                        mc=metaclass(varargin{k+1});
                        if isempty(mc.SuperClasses)
                            error('openCOSSAN:Optimum:Optimum', ...
                                ['A OptimizarionProblem is expected after the PropertyName ' varargin{k}]);
                        else
                            assert(strcmp(mc.SuperClasses{1}.Name,'Optimizer'),...
                                'openCOSSAN:Optimum:Optimum', ...
                                ['A OptimizarionProblem is expected after the PropertyName ' varargin{k}]);
                        end
                        Xobj.XOptimizer=varargin{k+1};
                    otherwise
                        error('openCOSSAN:Optimum:Optimum', ...
                            ['The PropertyName ' varargin{k} ' is not valid']);
                end
            end
            
            
        end     %of constructor
        
        
%         function NevaluationsObjectiveFunction=get.NevaluationsObjectiveFunction(Xobj)
%             if isempty(Xobj.XobjectiveFunction)
%                 NevaluationsObjectiveFunction=0;
%             elseif isempty(Xobj.XobjectiveFunctionGradient)
%                 NevaluationsObjectiveFunction=Xobj.XobjectiveFunction(1).VdataLength*size(Xobj.XobjectiveFunction,2);
%             else
%                 NevaluationsObjectiveFunction=Xobj.XobjectiveFunction(1).VdataLength*(Xobj.XobjectiveFunctionGradient(1).Nsamples+1);
%             end
%         end
        
%         function NevaluationsConstraints=get.NevaluationsConstraints(Xobj)       % number of evaluations of the constraints
%               if isempty(Xobj.Xconstrains)
%                 NevaluationsConstraints=0;
%               elseif isempty(Xobj.XconstrainsGradient)
%                   NevaluationsConstraints=Xobj.Xconstrains(1).VdataLength*size(Xobj.Xconstrains,2);
%               else
%                   NevaluationsConstraints=Xobj.Xconstrains(1).VdataLength*(Xobj.XconstrainsGradient(1).Nsamples+1);
%               end
%         end
        
        function NcandidateSolutions=get.NcandidateSolutions(Xobj)       % number of evaluations of the constraints
            NcandidateSolutions=Xobj.XdesignVariable(1).VdataLength;
        end
        
        function CconstraintsNames=get.CconstraintsNames(Xobj)       % number of evaluations of the constraints
            if isempty(Xobj.XOptimizationProblem)
                CconstraintsNames={};
            else
                CconstraintsNames=Xobj.XOptimizationProblem.CconstraintsNames;
            end
        end
        
        function CobjectiveFunctionNames=get.CobjectiveFunctionNames(Xobj)       % number of evaluations of the constraints
            if isempty(Xobj.XOptimizationProblem)
                CobjectiveFunctionNames={};
            else
                CobjectiveFunctionNames=Xobj.XOptimizationProblem.CobjectiveFunctionNames;
            end
        end
        
        % Values of the design variable at the optimum
        function VdesignVariables=getOptimalDesign(Xobj)
            VdesignVariables=[];
            for n=1:size(Xobj.XdesignVariable,2)
                Xds = Xobj.XdesignVariable(n);
                Mdata = cell2mat({Xds.Vdata}');
                VdesignVariables(n)=Mdata(1,end); %#ok<AGROW>
            end
        end
        
        % Values of the objective function at the optimum
        function Vobjective=getOptimalObjective(Xobj)
            Vobjective=[];
            for n=1:size(Xobj.XobjectiveFunction,2)
                Xds = Xobj.XobjectiveFunction(n);
                Mdata = cell2mat({Xds.Vdata}');
                Vobjective(n)=Mdata(1,end); %#ok<AGROW>
            end
        end
        
        % Values of the constraints at the optimum
        function Vconstraint=getOptimalConstraint(Xobj)
            Vconstraint=[];
            for n=1:size(Xobj.Xconstrains,2)
                Mdata = Xobj.Xconstrains(n).Vdata;
                if ~isempty(Mdata)
                Vconstraint(n)=Mdata(1,end); %#ok<AGROW>
                end
            end
        end
        
        Xobj=addIteration(Xobj,varargin);
        
    end     %of methods
    
    
    
end     %of classdef
