function [Vfobj,Vdfobj] = evaluateObjectiveFunctions(XoptProb,varargin)
% evaluateObjectiveFunctions. This method evaluate all the objective function defined in the optimization problem. The function to be minimized. evaluate method accepts a vector x
% and returns a vector Vfobj, the objective functions evaluated at x.

% Define global variable to store the optimum
global XoptGlobal XsimOutGlobal



if exist('Mx','var')
    NdesignVariables = size(Mx,2); %number of design variables
    Ncandidates=size(Mx,1); % Number of candidate solutions
    
    if length(XoptProb.CdesignVariable)~=NdesignVariables;
        error('cossanx:optimization:objectivefunction:evaluate',...
            'Number of design Variables not correct');
    end
    
else
    NdesignVariables=0;
end


if ~isempty(XoptGlobal)
    % Add candidate point to the Optimum object
    if isempty(XoptGlobal.XdesignVariable.Vindex)
        Vindex=0:size(Mx,1)-1;
    else
        Vindex=XoptGlobal.XdesignVariable.Vindex(end)+(1:size(Mx,1));
    end
    % Mindex=repmat(Vindex',1,length(Xobj.Cinputnames));
    % Dataseries object requies samples columwise
    XoptGlobal.XdesignVariable=XoptGlobal.XdesignVariable.addData ...
    ('Vdata',Mx','Mcoord',Vindex);
end

%% Prepare input values
if ~exist('Tinput','var')
    Cnames=XoptProb.Xinput.Cnames;
    Tinput=cell2struct(cell(length(Cnames),1),Cnames);
end

% Copy the candidate solution into the input structure
for nsol=1:Ncandidates
    for n=1:NdesignVariables
        Tinput(nsol).(XoptProb.CdesignVariable{n}) = Mx(nsol,n);     %prepare Input object with design "x"
    end
end


%% Prepare input considering perturbations
if Xobj.Lgradient    %checks whether or not gradient can be retrieved
    if Ncandidates>1
        error('cossanx:optimization:objectivefunction:evaluate',...
            'Gradient supported only with 1 candidate solution');
    end
    Tinput = repmat(Tinput,NdesignVariables+1,1);                  %replicate input
    for n=1:NdesignVariables
        Tinput(n+1).(XoptProb.CdesignVariable{n})   = Tinput(n+1).(XoptProb.CdesignVariable{n})+Xobj.perturbation;
    end
end


%% Evaluate function
XsimOut = run(Xobj,Tinput);

% keep only the variables defined in the Coutputnames
XsimOut=XsimOut.split('Cnames',Xobj.Coutputnames);

if isempty(XsimOutGlobal)
    XsimOutGlobal=XsimOut;
else
    XsimOutGlobal=XsimOutGlobal.merge(XsimOut);
end

%% Extract values of the objective function
% The objective function should contain only 1 value in the field
% Coutputnames
Vfobj=XsimOut.Mvalues;

if isempty(Vfobj)
    Vfobj=XsimOut.getValues('Sname',Xobj.Coutputnames);
end


%% Process data - gradient of objective function
if Xobj.Lgradient
    Vdfobj  = (Vfobj(2:end)-Vfobj(1))/Xobj.perturbation;     %compute gradient
    
    if ~isrow(Vdfobj)
        XoptGlobal.XobjectiveFunctionGradient=XoptGlobal.XobjectiveFunctionGradient.addData('Vdata',Vdfobj,'Mcoord',Vindex);
    else
        XoptGlobal.XobjectiveFunctionGradient=XoptGlobal.XobjectiveFunctionGradient.addData('Vdata',Vdfobj','Mcoord',Vindex);
    end
    
    % Only the first value contains actually the objective function
    Vfobj=Vfobj(1);
    
end

%% Update Optimum object
if ~isempty(XoptGlobal)
    if isempty(XoptGlobal.XobjectiveFunction.Vindex)
        Vindex=1:size(Vfobj,1);
    else
        Vindex=XoptGlobal.XobjectiveFunction.Vindex(end)+(1:size(Vfobj,1));
    end
    if ~isrow(Vfobj)
        XoptGlobal.XobjectiveFunction=XoptGlobal.XobjectiveFunction.addData('Vdata',Vfobj','Mcoord',Vindex);
    else
        XoptGlobal.XobjectiveFunction=XoptGlobal.XobjectiveFunction.addData('Vdata',Vfobj,'Mcoord',Vindex);
    end
    
end


%%   Apply scaling constant
Vfobj  = Vfobj/Xobj.scaling;

if Xobj.Lgradient
    Vdfobj  = Vdfobj/Xobj.scaling;
end

return
