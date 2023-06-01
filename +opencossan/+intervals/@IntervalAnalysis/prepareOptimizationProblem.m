function Xobj=prepareOptimizationProblem(Xobj)
% PREPAREOPTIMIZATIONPROBLEM prepares the optimization for
% the Interval Analysis. Note that in the majority of cases two
% optimization problems are needed to both minimize and maximize the
% objective funciton


XobjectiveFunction=Xobj.XobjectiveFunction;

% Extract special character from the script
Sscript=XobjectiveFunction.Sscript;
startIndex= regexp(Sscript,{'#','~','&','@'});
startIndex=cell2mat(startIndex);
assert(length(startIndex)==1,...
    'openCOSSAN:IntervalAnalysis:IntervalAnalysis',...
    'Please provide a valid token for the objective function \nAvailable tokens are: ''#'', ''~'', ''&'', ''?'' and ''@'' ');
% Modify the sign of objective function accordingly
% Minimization
SobjScriptMin=Sscript;
SobjScriptMin(startIndex)='+';
% Objective function for the minimization problem
XobjectiveFunctionMinimum=ObjectiveFunction('Sdescription','objective function', ...
    'Sscript',SobjScriptMin,...
    'CoutputNames',Xobj.XobjectiveFunction.Coutputnames,...
    'CinputNames',Xobj.XobjectiveFunction.Cinputnames);
% Minimization problem
% if ~isempty(Xobj.Xmodel)
%     XoptimizationProblemMin = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
%         'VinitialSolution',Xobj.VinitialSolution,...
%         'XobjectiveFunction',XobjectiveFunctionMinimum,...
%         'Xmodel',Xobj.XmodelSS);
% else
    XoptimizationProblemMin = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
        'VinitialSolution',Xobj.VinitialSolution,...
        'XobjectiveFunction',XobjectiveFunctionMinimum,...
        'Xmodel',Xobj.Xmodel);
% end

% Maximization
SobjScriptMax=Sscript;
SobjScriptMax(startIndex)='-';
% Objective function for the minimization problem
XobjectiveFunctionMaximum=ObjectiveFunction('Sdescription','objective function', ...
    'Sscript',SobjScriptMax,...
    'CoutputNames',Xobj.XobjectiveFunction.Coutputnames,...
    'CinputNames',Xobj.XobjectiveFunction.Cinputnames);
% Maximization problem
% if ~isempty(Xobj.Xmodel)
%     XoptimizationProblemMax = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
%         'VinitialSolution',Xobj.VinitialSolution,...
%         'XobjectiveFunction',XobjectiveFunctionMaximum,...
%         'Xmodel',Xobj.Xmodel);
% else
    XoptimizationProblemMax = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
        'VinitialSolution',Xobj.VinitialSolution,...
        'XobjectiveFunction',XobjectiveFunctionMaximum,...
        'Xmodel',Xobj.Xmodel);
% end

%Xobj.CXMinMaxObjFunctions={XobjectiveFunctionMinimum,XobjectiveFunctionMaximum};
Xobj.CXMinMaxOptProblems={XoptimizationProblemMin,XoptimizationProblemMax};





































% if Xobj.LsearchByGA
%     if Xobj.NmaxIterations
%         Xobj.XgeneticAlgorithms.NmaxFunctions=Xobj.NmaxIterations;
%     end
%     if Xobj.LminMax
%         % check if the ga_minmax algorithm is used
%         XobjFun = ObjectiveFunction('Sdescription','Bounds of the failure probability',...
%             'Sscript',['for n=1:length(Tinput), Toutput(n).fobj=log10(Tinput(n).',...
%             Xobj.SfailureProbabilityName,'); end'],...
%             'Cinputnames',{Xobj.SfailureProbabilityName},...
%             'Coutputnames',{'fobj'});
%         
%         XoptimizationProblem = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
%             'MinitialSolutions',Xobj.VinitialRealization,...
%             'XobjectiveFunction',XobjFun,...
%             'Xmodel',Xobj.Xmodel);
%         
%         Xobj.CXMinMaxOptProblems={XoptimizationProblem};
%     else
%         % The objective function targets the Failure Probability.
%         % The bounds of the failure probability are of interest in this analysis.
%         % Always use the logarithm of the failure probability during the optimization
%         XobjFun = ObjectiveFunction('Sdescription','Bounds of the failure probability',...
%             'Sscript',['for n=1:length(Tinput), Toutput(n).fobj=#log10(Tinput(n).',...
%             Xobj.SfailureProbabilityName,'); end'],...
%             'Cinputnames',{Xobj.SfailureProbabilityName},...
%             'Coutputnames',{'fobj'});
%         
%         % Extract special character from the script
%         Sscript=XobjFun.Sscript;
%         startIndex= regexp(Sscript,{'#','~','&','@'});
%         startIndex=cell2mat(startIndex);
%         assert(length(startIndex)==1,...
%             'openCOSSAN:IntervalAnalysis:UncertaintyQuantification',...
%             'Please provide a valid token for the objective function \nAvailable tokens are: ''#'', ''~'', ''&'', and ''@'' ');
%         % Modify the sign of objective function accordingly
%         
%         % Minimization
%         SobjScriptMin=Sscript;
%         SobjScriptMin(startIndex)='+';
%         % Objective function for the minimization problem
%         XobjectiveFunctionMinimum=ObjectiveFunction('Sdescription','objective function', ...
%             'Sscript',SobjScriptMin,...
%             'CoutputNames',XobjFun.Coutputnames,...
%             'CinputNames',XobjFun.Cinputnames);
%         % Minimization problem
%         XoptimizationProblemMin = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
%             'MinitialSolutions',Xobj.VinitialRealization,...
%             'XobjectiveFunction',XobjectiveFunctionMinimum,...
%             'Xmodel',Xobj.Xmodel);
%         
%         % Maximization
%         SobjScriptMax=Sscript;
%         SobjScriptMax(startIndex)='-';
%         % Objective function for the minimization problem
%         XobjectiveFunctionMaximum=ObjectiveFunction('Sdescription','objective function', ...
%             'Sscript',SobjScriptMax,...
%             'CoutputNames',XobjFun.Coutputnames,...
%             'CinputNames',XobjFun.Cinputnames);
%         % Maximization problem
%         XoptimizationProblemMax = OptimizationProblem('Sdescription','Optimization problem for the interval analysis',...
%             'MinitialSolutions',Xobj.VinitialRealization,...
%             'XobjectiveFunction',XobjectiveFunctionMaximum,...
%             'Xmodel',Xobj.Xmodel);
%         
%         %                Xobj.CXMinMaxObjFunctions={XobjectiveFunctionMinimum,XobjectiveFunctionMaximum};
%         CXMinMaxOptProbl={XoptimizationProblemMin,XoptimizationProblemMax};
%         Xobj.CXMinMaxOptProblems=CXMinMaxOptProbl;
%     end
% end


return