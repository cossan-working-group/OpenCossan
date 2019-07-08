function Xobj=prepareOptimizationProblem(Xobj)
% PREPAREOPTIMIZATIONPROBLEM  is a method that sets up the optimization for
% the ExtremeCase analysis. Note that in some cases two optimization
% problems may be needed to both minimize and maximize the objective
% funciton


if strcmpi(superclasses(Xobj.Xsolver),'Optimizer')
    
%     if Xobj.NmaxIterations
%         Xobj.Xsolver.NmaxFunctions=Xobj.NmaxIterations;
%     end
    
    if strcmpi(class(Xobj.Xsolver),'GeneticAlgorithms') && Xobj.LminMax
        % check if the ga_minmax algorithm is used
        XobjFun = ObjectiveFunction('Sdescription','Bounds of the failure probability',...
            'Sscript',['for n=1:length(Tinput), Toutput(n).fobj=log10(Tinput(n).pf); end'],...
            'Cinputnames',{'pf'},...
            'Coutputnames',{'fobj'});
        
        XoptimProblem = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
            'MinitialSolutions',Xobj.VinitialSolution,...
            'XobjectiveFunction',XobjFun,...
            'Xmodel',Xobj.Xmodel);
        
        Xobj.XoptimizationProblem=XoptimProblem;
        
    end
    
    % The objective function targets the Failure Probability.
    % In fact the bounds of the failure probability are of interest in this analysis.
    % Always work with the logarithm of the failure
    % probability during the optimization
    XobjFun = ObjectiveFunction('Sdescription','Bounds of the failure probability',...
        'Sscript',['for n=1:length(Tinput), Toutput(n).fobj=#log10(Tinput(n).pf); end'],...
        'Cinputnames',{'pf'},...
        'Coutputnames',{'fobj'});
    
    % Extract special character from the script
    Sscript=XobjFun.Sscript;
    startIndex= regexp(Sscript,{'#','~','&','@'});
    startIndex=cell2mat(startIndex);
    assert(length(startIndex)==1,...
        'openCOSSAN:IntervalAnalysis:UncertaintyQuantification',...
        'Please provide a valid token for the objective function \nAvailable tokens are: ''#'', ''~'', ''&'', and ''@'' ');
    % Modify the sign of objective function accordingly
    % Minimization
    SobjScriptMin=Sscript;
    SobjScriptMin(startIndex)='+';
    % Objective function for the minimization problem
    XobjectiveFunctionMinimum=ObjectiveFunction('Sdescription','objective function', ...
        'Sscript',SobjScriptMin,...
        'CoutputNames',XobjFun.Coutputnames,...
        'CinputNames',XobjFun.Cinputnames);
    % Minimization problem
    XoptimizationProblemMin = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
        'MinitialSolutions',Xobj.VinitialSolution,...
        'XobjectiveFunction',XobjectiveFunctionMinimum,...
        'Xmodel',Xobj.Xmodel);
    
    % Maximization
    SobjScriptMax=Sscript;
    SobjScriptMax(startIndex)='-';
    % Objective function for the minimization problem
    XobjectiveFunctionMaximum=ObjectiveFunction('Sdescription','objective function', ...
        'Sscript',SobjScriptMax,...
        'CoutputNames',XobjFun.Coutputnames,...
        'CinputNames',XobjFun.Cinputnames);
    % Maximization problem
    XoptimizationProblemMax = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
        'MinitialSolutions',Xobj.VinitialSolution,...
        'XobjectiveFunction',XobjectiveFunctionMaximum,...
        'Xmodel',Xobj.Xmodel);
    
    %                Xobj.CXMinMaxObjFunctions={XobjectiveFunctionMinimum,XobjectiveFunctionMaximum};
    Xobj.CXMinMaxOptProblems={XoptimizationProblemMin,XoptimizationProblemMax};
    
else
    % do nothing
end

return