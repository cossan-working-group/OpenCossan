function [MobjectiveFunction,MgradientObjFun] = evaluate(Xobj,varargin)
%EVALUATE The method evaluates the ObjectiveFunction
%
% The candidate solutions (i.e. Design Variables) are stored in the matrix
% Minput (Ncandidates,NdesignVariable)
%
% The objective functions are stored in Mfobj(Ncandidates,NobjectiveFunctions)
% The gradient of the objective function is store in Mdfobj(NdesignVariable,NobjectiveFunctions)
%
% See Also: https://cossan.co.uk/wiki/evaluate@ObjectiveFunction
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

% Define global variable to store the optimum
global XoptGlobal XsimOutGlobal

% Process inputs
OpenCossan.validateCossanInputs(varargin{:})
Lgradient=false;
scaling=1;
perturbation=1;

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xmodel'
            Xmodel=varargin{k+1};
        case 'xoptimizationproblem'
            XoptProb=varargin{k+1};
        case 'lgradient'
            Lgradient=varargin{k+1};
        case 'mreferencepoints'
            Minput=varargin{k+1};
        case 'finitedifferenceperturbation'
            perturbation=varargin{k+1};
        case 'scaling'
            scaling=varargin{k+1};
        case 'cxobjects'
            Xobj.Cxobjects=varargin{k+1};
        case 'xoptimum'
            XoptGlobal=varargin{k+1};
        otherwise
            error('OpenCossan:ObjectiveFunction:evaluate:wrongInputArgument',...
                'PropertyName %s not valid', varargin{k});
    end
end

% Collect quantities
Coutputnames=[Xobj.Coutputnames];

%% Check inputs
assert(logical(exist('XoptProb','var')),...
    'OpenCossan:ObjectiveFunction:evaluate',...
    'An optimizationProblem object must be defined');

if exist('Minput','var')
    NdesignVariables = size(Minput,2); %number of design variables
    Ncandidates=size(Minput,1); % Number of candidate solutions
    
    assert(XoptProb.NdesignVariables==NdesignVariables, ...
        'OpenCossan:ObjectiveFunction:evaluate',...
        'Number of design Variables %i does not match with the dimension of the referece point (%i)', ...
        XoptProb.NdesignVariables,NdesignVariables);
else
    NdesignVariables=0;
end

%% Prepare input considering perturbations
if Lgradient
    %checks whether or not the gradient can be retrieved
    assert(~XoptProb.Xinput.LdiscreteDesignVariables,...
        'OpenCossan:ObjectiveFunction:evaluate',...
        'It is not possible to use gradient based optimization methods with discrete Design Variable(s)');
    
    assert(Ncandidates==1, ...
        'OpenCossan:ObjectiveFunction:evaluate',...
        'Gradient supported only with 1 candidate solution');
    
    % Minimum perturbation is defined by the perturbation parameter.
    MxPerturbation=repmat(Minput,NdesignVariables,1)+diag(max(perturbation*Minput,perturbation));
    Minput=[Minput; MxPerturbation];
end

%% Prepare input values
Xinput=XoptProb.Xinput.setDesignVariable('CSnames',XoptProb.CnamesDesignVariables,'Mvalues',Minput);
Tinput=Xinput.getStructure;

%MobjectiveFunction=zeros(length(Tinput),length(Xobj));

%% Evaluate Model
if exist('Xmodel','var')
    % If a model should be evaluate then check first if the solution has been
    % already computed during the evaluation of the constraints
    
    if isa(XoptGlobal.XOptimizer,'GeneticAlgorithms')
        if ~isempty(XsimOutGlobal)
            NsamplesSimOut=XsimOutGlobal.Nsamples;
        else
            NsamplesSimOut=0;
        end
        
        if Ncandidates<=NsamplesSimOut
            % Check the consistency of the XsimOutGlobal with Minput
            Mvalues=XsimOutGlobal.getValues('Cnames',XoptProb.CnamesDesignVariables);
            
            Vpos=false(NsamplesSimOut,1);
            
            for iCandidates=1:Ncandidates
                Vindex=false(NsamplesSimOut,1);
                for iSamples=1:NsamplesSimOut
                    if abs(max(Minput(iCandidates,:)-Mvalues(iSamples,:)))<1e-6
                        Vindex(iSamples)=true;
                    end
                end
                
                if sum(Vindex)>0
                    Vpos(iCandidates)=true;
                end
            end
            
            OpenCossan.cossanDisp(['[OpenCossan:ObjectiveFunction:evaluate] Ri-evaluating model (' ...
                num2str(Ncandidates-sum(Vpos))   '/' num2str(Ncandidates) ')'],4)
            
            % Remove Samples not present anymore in the candidate solutions
            if Ncandidates==sum(Vpos)
                XsimOutGlobal.Tvalues=XsimOutGlobal.Tvalues(Vpos);
            else
                XsimOutGlobal = apply(Xmodel,Tinput);
                % Update counter
                XoptGlobal.NevaluationsModel=XoptGlobal.NevaluationsModel+length(Tinput);
            end
        else
            OpenCossan.cossanDisp('[OpenCossan:ObjectiveFunction:evaluate] Ri-evaluating all samples',4)
            XsimOutGlobal = apply(Xmodel,Tinput);
        end
    else
        % Evaluate the model
        OpenCossan.cossanDisp('[OpenCossan:ObjectiveFunction:evaluate] Ri-evaluating all samples',4)
        XsimOutGlobal = apply(Xmodel,Tinput);
        
        % Update counter
        XoptGlobal.NevaluationsModel=XoptGlobal.NevaluationsModel+length(Tinput);
    end
end


for iobj=1:length(Xobj)
    % Prepare Input structure
    TinputSolver=Evaluator.addField2Structure(Xobj(iobj),XsimOutGlobal,Tinput);
    
    % Evalutate Obj.Function
    XoutObjective = run(Xobj(iobj),TinputSolver);
    
    % keep only the variables defined in the Coutputnames
    Mout(:,iobj)=XoutObjective.getValues('Cnames',Xobj(iobj).Coutputnames);
end

%% Process data - gradient of objective function
% Add check of the number of output arguments, Use Sensitivity analysis to
% compute the gradient (e.g. doFiniteDifference)
if Lgradient
    MgradientObjFun=zeros(NdesignVariables,length(Coutputnames));
    for n=2:length(Tinput)
        % compute gradient (only 1 candidate solution at time is allowed
        % when the gradient is computed, i.e. MX(1,NdesignVariables)
        MgradientObjFun(n-1,:)  =(Mout(n,:)-Mout(1,:))./(Minput(n,n-1)-Minput(1,n-1));
    end
else
    MgradientObjFun=[];
end
%%   Apply scaling constant
MobjectiveFunction  = Mout(1:Ncandidates,:)/scaling;

%% Update function counter of the Optimisers
XoptGlobal.NevaluationsObjectiveFunctions = XoptGlobal.NevaluationsObjectiveFunctions+length(Tinput);  % Number of objective function evaluations

% check if you are running "HRLF" (special kind of optimization with no
% optimizer)
Tstack = dbstack;
if isempty(XoptGlobal.XOptimizer) && ismember("HLRF",convertCharsToStrings({Tstack.name}))
    % if it is HLRF, increase the counter
    XoptGlobal.Niterations=XoptGlobal.Niterations+1;
end

switch class(XoptGlobal.XOptimizer)
    case {'Cobyla' 'Bobyqa'}
        %% Update Optimum object
        XoptGlobal.Niterations=XoptGlobal.Niterations+1;
        
        XoptGlobal=XoptGlobal.addIteration('MdesignVariables',Minput,...
            'MobjectiveFunction',Mout,...
            'Niteration',XoptGlobal.Niterations);
        
    case {'CrossEntropy'}
        
        %   XoptGlobal.Niterations=XoptGlobal.Niterations+1;
        
        XoptGlobal=XoptGlobal.addIteration('MdesignVariables',Minput,...
            'MobjectiveFunction',Mout,...
            'Viterations',repmat(XoptGlobal.Niterations,size(Minput,1),1));
        
    case {'EvolutionStrategy'}
        XoptGlobal=XoptGlobal.addIteration('MdesignVariables',Minput,...
            'MobjectiveFunction',Mout,...
            'Viterations',repmat(XoptGlobal.Niterations,size(Minput,1),1));
    otherwise
        % Default behaviour
        % Values of the design variables and objective function stored by
        % the outputFunctionOptimise function
        
        % XoptGlobal.Niterations=XoptGlobal.Niterations+1;
        
        XoptGlobal=XoptGlobal.addIteration('MdesignVariables',Minput,...
            'MobjectiveFunction',Mout,...
            'Viterations',repmat(max(0,XoptGlobal.Niterations),size(Minput,1),1));
end

