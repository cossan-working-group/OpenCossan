function Xoutput    = add(Xoutput,varargin)
%ADD  Update fields of the object Optimum
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================



%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Add fields
for ivar=1:2:length(varargin),
    switch lower(varargin{ivar}),
        %2.1.   Add description of object Optimum
        case {'sdescription','description'}
            if ischar(varargin{ivar+1}),    %check whether or not argument is a string
                Xoutput.Sdescription     = varargin{ivar+1};
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with Sdescription must contain a string');
            end
            %2.2.   Set optimal solution
        case {'toptimalsolution','optimalsolution','solution'},
            if isstruct(varargin{ivar+1}),  %check whether or not argument is a structure
                TOptimalSolution    = varargin{ivar+1};
                Cdesvar             = fieldnames(TOptimalSolution);
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with TOptimalSolution must contain a structure');
            end
            Xoutput.TOptimalSolution    = TOptimalSolution;     %assign values
            %2.3.   Value of objective function at optimum design
        case {'valueobjectivefunction','objectivefunction'},
            if isnumeric(varargin{ivar+1}) ,     %check whether or not argument is a scalar number
                Xoutput.ValueObjectiveFunction  = varargin{ivar+1};
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with ValueObjectiveFunction must contain a number');
            end
            %2.4.   Number of evaluations of objective function
        case {'nevaluationsobjectivefunction'},
            if isnumeric(varargin{ivar+1}) && ...
                    isscalar(varargin{ivar+1}) &&...
                    (varargin{ivar+1}==round(varargin{ivar+1})),     %check whether or not argument is a scalar number
                Xoutput.NEvaluationsObjectiveFunction  = varargin{ivar+1};
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with NEvaluationsObjectiveFunction must contain a scalar, integer number');
            end
            %2.5.   Reason for finishing optimization
        case{'sexitflag'},
            if ischar(varargin{ivar+1}),    %check whether or not argument is a string
                Xoutput.Sexitflag   = varargin{ivar+1};
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with Sexitflag must contain a string');
            end
            %2.6.   Time required to perform optimization
        case {'cputime'},
            if isnumeric(varargin{ivar+1}) && ...
                    isscalar(varargin{ivar+1}),     %check whether or not argument is a scalar number
                Xoutput.cputime  = varargin{ivar+1};
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with cputime must contain a scalar number');
            end
            %2.7.   Optimization Problem that was solved
        case{'xoptimizationproblem','optimizationproblem'},
            if ~isa(varargin{ivar+1},'OptimizationProblem'),    %check whether or not argument is an object of the class OptimizationProblem
                error('openCOSSAN:Optimum:add',...
                    'the field associated with XOptimizationProblem must contain an OptimizationProblem object');
            end
            Xoutput.XOptimizationProblem    = varargin{ivar+1};     %assign values
            %2.8.   Optimizer used to solved optimization problem
        case{'xoptimizer'},
            if isa(varargin{ivar+1},'Optimizer'),   %check whether or not object is an Optimizer
                Xoutput.XOptimizer  = varargin{ivar+1};
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with XOptimizer must contain and Optimizer object');
            end
            %2.9.   Inequality constraints
        case{'tinequalityconstraints','inequalityconstraints'},
            if isstruct(varargin{ivar+1}),  %check whether or not argument is a structure
                TInequalityConstraints  = varargin{ivar+1};
                Cineqconst              = fieldnames(TInequalityConstraints);
                if isempty(Cineqconst),
                    Cineqconst  = 'null';   %in case it is empty, assign null value
                end
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with TInequalityConstraints must contain a structure');
            end
            if ~isempty(Xoutput.XOptimizationProblem),  %check whether or not the optimization problem has been defined
                if ~all(ismember(get(Xoutput.XOptimizationProblem,'inequality_name'),...
                        Cineqconst)),  %check that design variables in optimization problem and input structure coincide
                    error('openCOSSAN:Optimum:add',...
                        'the fields of TInequalityConstraints do not coincide with the fields of XOptimizationProblem (inequality constraints)');
                end
            end
            Xoutput.TInequalityConstraints  = TInequalityConstraints;     %assign values
            %2.10.  Equality constraints
        case{'tequalityconstraints','equalityconstraints'},
            if isstruct(varargin{ivar+1}),  %check whether or not argument is a structure
                TEqualityConstraints    = varargin{ivar+1};
                Ceqconst                = fieldnames(TEqualityConstraints);
                if isempty(Ceqconst),
                    Ceqconst    = 'null';   %in case it is empty, assign null value
                end
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with TEqualityConstraints must contain a structure');
            end
            if ~isempty(Xoutput.XOptimizationProblem),  %check whether or not the optimization problem has been defined
                if ~all(ismember(get(Xoutput.XOptimizationProblem,'equality_name'),...
                        Ceqconst)),  %check that design variables in optimization problem and input structure coincide
                    error('openCOSSAN:Optimum:add',...
                        'the fields of TEqualityConstraints do not coincide with the fields of XOptimizationProblem (equality constraints)');
                end
            end
            Xoutput.TEqualityConstraints    = TEqualityConstraints;     %assign values
            %2.11.  Number of evaluations of constraints
        case {'nevaluationsconstraints'},
            if isnumeric(varargin{ivar+1}) && ...
                    isscalar(varargin{ivar+1}) &&...
                    (varargin{ivar+1}==round(varargin{ivar+1})),     %check whether or not argument is a scalar number
                Xoutput.NEvaluationsConstraints     = varargin{ivar+1};
            else
                error('openCOSSAN:Optimum:add',...
                    'the field associated with NEvaluationsConstraints must contain a scalar, integer number');
            end
    end
end



%% 3.   Check that design variables in optimal solution match the ones in
%% the optimization problem
if ~isempty(Xoutput.TOptimalSolution) && ~isempty(Xoutput.XOptimizationProblem),
    Calldesvar  = {};
    if ~isempty(Xoutput.XOptimizationProblem.Cdesvar),
        N                       = length(Xoutput.XOptimizationProblem.Cdesvar);
        Calldesvar(end+1:end+N) = Xoutput.XOptimizationProblem.Cdesvar(:)';
    end
    if ~isempty(Xoutput.XOptimizationProblem.Cdiscdesvar),
        N                       = length(Xoutput.XOptimizationProblem.Cdiscdesvar);
        Calldesvar(end+1:end+N) = Xoutput.XOptimizationProblem.Cdiscdesvar(:)';
    end
    if ~isempty(setxor(Calldesvar,fieldnames(Xoutput.TOptimalSolution))),
        error('openCOSSAN:OptimizationProblem:checkConsistency',...
            'the design variables defined by the user are not contained in the Input object');
    end
end

return
