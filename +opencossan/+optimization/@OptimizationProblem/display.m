function display(Xop)
%DISPLAY  Displays the object OptimizationProblem
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

%% Name and description
opencossan.OpenCossan.cossanDisp('===================================================================',3);
opencossan.OpenCossan.cossanDisp([ class(Xop) ' object  -  Description: ' Xop.Sdescription ],1);
opencossan.OpenCossan.cossanDisp('===================================================================',3);

if isempty(Xop.Xinput)
    opencossan.OpenCossan.cossanDisp('* Empty object',1);
    return
end

if isempty(Xop.Xmodel)
    opencossan.OpenCossan.cossanDisp('* No Model to be evaluated',3);
else
   opencossan.OpenCossan.cossanDisp(['* Model to be evaluated'],3);
   opencossan.OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xop.Xmodel.Cinputnames{:})],3);
   opencossan.OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xop.Xmodel.Coutputnames{:})],3);

end


% Show Design Paremeter
opencossan.OpenCossan.cossanDisp(['* Design Parameters: ' sprintf('%s; ',Xop.CnamesDesignVariables{:})],2);

%% Objective function
if isempty(Xop.XobjectiveFunction)
    opencossan.OpenCossan.cossanDisp('* No objective function defined',3);
else
    for n=1:length(Xop.XobjectiveFunction)
        opencossan.OpenCossan.cossanDisp(['* Objective Function #' num2str(n)],3);
        opencossan.OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xop.XobjectiveFunction(n).Cinputnames{:})],3);
        opencossan.OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xop.XobjectiveFunction(n).Coutputnames{:})],3);
    end
end

%% constraint
if isempty(Xop.Xconstraint)
    opencossan.OpenCossan.cossanDisp('* No constraints defined',3);
else
    for n=1:length(Xop.Xconstraint)
        opencossan.OpenCossan.cossanDisp(['* Constraint #' num2str(n)],3);
        opencossan.OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xop.Xconstraint(n).Cinputnames{:})],3);
        opencossan.OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xop.Xconstraint(n).Coutputnames{:})],3);
    end
end






