function TablesValues=initializeTable(Xobj,varargin)
% INITIALISETABLE assumes that there is one entry for each iteration.
% In case of stochastic optimization multiple entries for the same
% iteration number should be used.

% Initialise variables
if ~isempty(Xobj.XOptimizationProblem)
    MvaluesDesignVariables=NaN(1,Xobj.XOptimizationProblem.NdesignVariables);
    MvaluesObjectiveFunction=NaN(1,Xobj.XOptimizationProblem.NobjectiveFunctions);
    
        
    if isempty(Xobj.XOptimizationProblem.Xconstraint)
        MvaluesConstraintGradient=NaN;
        MvaluesConstraint=NaN;
    else
        MvaluesConstraint=NaN(1,length(Xobj.CconstraintsNames));
    end
else
   MvaluesDesignVariables=NaN;
   MvaluesObjectiveFunction=NaN;
   MvaluesConstraint=NaN;
end

%%  Set values passed by the user
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'vdesignvariable', 'mdesignvariables','designvariable'}
            MvaluesDesignVariables=varargin{k+1};
        case {'vobjectivefunction','mobjectivefunction','objectivefunction'}
            MvaluesObjectiveFunction=varargin{k+1};
        case {'vvaluesconstraint','mconstraintfunction','constraintfunction'}
            MvaluesConstraint=varargin{k+1};
        case {'viterations','niteration','iteration'}
            Viterations=varargin{k+1};
            if isrow(Viterations)
                Viterations=Viterations';
            end
        otherwise
            error('Optimum:initialiseTable:wrongPropertyName', ...
                'The PropertyName %s is not valid. ', varargin{k});
    end
end

Nrows=length(Viterations);

%% Check data
if ~isempty(Xobj.XOptimizationProblem)
    assert(size(MvaluesDesignVariables,2)==Xobj.XOptimizationProblem.NdesignVariables,...
        'OpenCossan:Optimum:wrongDesignVariableSize',...
        'The number of colums of the DesignVariables (%i) must be equal to the number of design variables (%i)', ...
        size(MvaluesDesignVariables,2),Xobj.XOptimizationProblem.NdesignVariables)
    
    assert(size(MvaluesObjectiveFunction,2)==Xobj.XOptimizationProblem.NobjectiveFunctions,...
        'OpenCossan:Optimum:wrongObjectiveFunctionsSize',...
        'The number of colums of the ObjectiveFunction (%i) must be equal to the number of Objective functions (%i)', ...
        size(MvaluesObjectiveFunction,2),Xobj.XOptimizationProblem.NobjectiveFunctions)
    
    
    if Xobj.XOptimizationProblem.Nconstraints>0
        
        assert(size(MvaluesConstraint,2)==Xobj.XOptimizationProblem.Nconstraints,...
            'OpenCossan:Optimum:wrongConstraintSize',...
            'The number of colums of the Constraints (%i) must be equal to the number of constraints (%i)', ...
            size(MvaluesConstraint,2),Xobj.XOptimizationProblem.Nconstraints)
        
    else
        assert(isnan(MvaluesConstraint),...
            'OpenCossan:Optimum:wrongObjectiveFunctionSize',...
            'Expecting a NaN for MvaluesObjectiveFunction');
    end
    
end

% Fill unused values with NaN
MvaluesDesignVariables(size(MvaluesDesignVariables,1)+1:Nrows,:)=NaN;
MvaluesObjectiveFunction(size(MvaluesObjectiveFunction,1)+1:Nrows,:)=NaN;
MvaluesConstraint(size(MvaluesConstraint,1)+1:Nrows,:)=NaN;

TablesValues=table(Viterations,...
    MvaluesDesignVariables, ...
    MvaluesObjectiveFunction,...
    MvaluesConstraint);


TablesValues.Properties.VariableNames={...
    'Iteration','DesignVariables',...
    'ObjectiveFnc', 'Constraints'};