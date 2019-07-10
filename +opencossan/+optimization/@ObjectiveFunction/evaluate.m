function [MobjectiveFunction,MgradientObjFun] = evaluate(Xobj,varargin)
%EVALUATE The method of a OpjectiveFunction object evaluates the
%ObjectiveFunction
%
% The candidate solutions (i.e. Design Variables) are stored in the matrix
% MX(Ncandidates,NdesignVariable)
%
% The objective functions are stored in Mfobj(Ncandidates,NobjectiveFunctions)
% The gradient of the objective function is store in Mdfobj(NdesignVariable,NobjectiveFunctions)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/evaluate@ObjectiveFunction
%
% Author: Edoardo Patelli
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

import opencossan.workers.Evaluator

% Define global variable to store the optimum
global XoptGlobal XsimOutGlobal

% Process inputs
opencossan.OpenCossan.validateCossanInputs(varargin{:})
Lgradient=false;
scaling=1;
perturbation=1;

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xmodel'
            Xmodel=varargin{k+1};
            %         case 'xsimulationoutput'
            %             XsimOutGlobal=varargin{k+1};
        case 'xoptimizationproblem'
            XoptProb=varargin{k+1};
            %         case 'xoptimum'
            %             XoptGlobal=varargin{k+1};
        case 'lgradient'
            Lgradient=varargin{k+1};
        case 'mreferencepoints'
            Mx=varargin{k+1};
        case 'finitedifferenceperturbation'
            perturbation=varargin{k+1};
        case 'scaling'
            scaling=varargin{k+1};
        case 'tinput' % for testing only
            Tinput=varargin{k+1};
        case 'cxobjects'
            Xobj.Cxobjects=varargin{k+1};
        otherwise
            error('openCOSSAN:ObjectiveFunction:evaluate',...
                'PropertyName %s not valid', varargin{k});
    end
end

% Collect quantities
Coutputnames=Xobj(1).OutputNames;
for n=2:length(Xobj)
    Coutputnames=[Coutputnames Xobj(n).OutputNames]; %#ok<AGROW>
end


%% Check inputs
assert(logical(exist('XoptProb','var')),...
    'CossanX:ObjectiveFunction:evaluate',...
    'An optimizationProblem object must be defined');

if exist('Mx','var')
    NdesignVariables = size(Mx,2); %number of design variables
    Ncandidates=size(Mx,1); % Number of candidate solutions
    
    assert(XoptProb.NdesignVariables==NdesignVariables, ...
        'openCOSSAN:ObjectiveFunction:evaluate',...
        'Number of design Variables %i does not match with the dimension of the referece point (%i)', ...
        XoptProb.NdesignVariables,NdesignVariables);
else
    NdesignVariables=0;
end

%% Prepare input values
if ~exist('Tinput','var')
    Xinput=XoptProb.Xinput.setDesignVariable('CSnames',XoptProb.DesignVariableNames,'Mvalues',Mx);
    TableInput=Xinput.getTable;
else
    % Copy the candidate solution into the input structure
    % TODO: is this code still valid???
    for nsol=1:Ncandidates
        for n=1:NdesignVariables
            Tinput(nsol).(XoptProb.DesignVariableNames{n}) = Mx(nsol,n);     %prepare Input object with design "x"
        end
        % Add values of all the other quantities (i.e. Parameters etc)
    end
end

%% Prepare input considering perturbations
if Lgradient    %checks whether or not gradient can be retrieved
    assert(~XoptProb.Xinput.LdiscreteDesignVariables,...
        'openCOSSAN:ObjectiveFunction:evaluate',...
        'It is not possible to use gradient based optimization methods with discrete Design Variable(s)');
    
    assert(Ncandidates==1, ...
        'openCOSSAN:ObjectiveFunction:evaluate',...
        'Gradient supported only with 1 candidate solution');
    
    MxPerturbation=repmat(Mx,NdesignVariables,1)+diag(perturbation*Mx);
    Xinput=XoptProb.Xinput.setDesignVariable('CSnames',XoptProb.CnamesDesignVariables,'Mvalues',[Mx; MxPerturbation]);
    TableInput=Xinput.getTable;
end

MobjectiveFunction=zeros(height(TableInput),length(Xobj));

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
            % Check the consistency of the XsimOutGlobal with Mx
            Mvalues=XsimOutGlobal.getValues('Cnames',XoptProb.CnamesDesignVariables);
            
            Vpos=false(NsamplesSimOut,1);
            
            for iCandidates=1:Ncandidates
                Vindex=false(NsamplesSimOut,1);
                for iSamples=1:NsamplesSimOut
                    if abs(max(Mx(iCandidates,:)-Mvalues(iSamples,:)))<1e-6
                        Vindex(iSamples)=true;
                    end
                end
                
                if sum(Vindex)>0
                    Vpos(iCandidates)=true;
                end
            end
            
            OpenCossan.cossanDisp(['[openCOSSAN:ObjectiveFunction:evaluate] Ri-evaluating model (' ...
                num2str(Ncandidates-sum(Vpos))   '/' num2str(Ncandidates) ')'],4)
            
            % Remove Samples not present anymore in the candidate solutions
            if Ncandidates==sum(Vpos)
                XsimOutGlobal.Tvalues=XsimOutGlobal.Tvalues(Vpos);
            else
                XsimOutGlobal = apply(Xmodel,TableInput);
                % Update counter
                XoptGlobal.NevaluationsModel=XoptGlobal.NevaluationsModel+height(TableInput);
            end
        else
            OpenCossan.cossanDisp('[openCOSSAN:ObjectiveFunction:evaluate] Ri-evaluating all samples',4)
            XsimOutGlobal = apply(Xmodel,TableInput);
        end
    else
        % Evaluate the model
        OpenCossan.cossanDisp('[openCOSSAN:ObjectiveFunction:evaluate] Ri-evaluating all samples',4)
        XsimOutGlobal = apply(Xmodel,TableInput);
        
        % Update counter
        XoptGlobal.NevaluationsModel=XoptGlobal.NevaluationsModel+height(TableInput);
    end
end


for iobj=1:length(Xobj)
    % Prepare Input structure
    TableInputSolver=Evaluator.addField2Table(Xobj(iobj),XsimOutGlobal,TableInput);
    
    % Evalutate Obj.Function
    TableOutObjective = evaluate@opencossan.workers.Mio(Xobj(iobj),TableInputSolver);
    
    % keep only the variables defined in the Coutputnames
    MobjectiveFunction(:,iobj)=TableOutObjective.(Xobj(iobj).OutputNames{1});
end

%% Process data - gradient of objective function
% Add check of the number of output arguments, Use Sensitivity analysis to
% compute the gradient (e.g. doFiniteDifference)
if Lgradient
    MgradientObjFun=zeros(NdesignVariables,length(Coutputnames));
    for n=2:height(TableInput)
        % compute gradient (only 1 candidate solution at time is allowed
        % when the gradient is computed, i.e. MX(1,NdesignVariables)
        MgradientObjFun(n-1,:)  =(MobjectiveFunction(n,:)-MobjectiveFunction(1,:))/(perturbation*Mx(n-1));
    end
    %%   Apply scaling constant
    MobjectiveFunction  = MobjectiveFunction(1,:)/scaling;
else
    %%   Apply scaling constant
    MobjectiveFunction  = MobjectiveFunction/scaling;
    MgradientObjFun=[];
end

%% Update function counter of the Optimisers
XoptGlobal.NevaluationsObjectiveFunctions = XoptGlobal.NevaluationsObjectiveFunctions+height(TableInput);  % Number of objective function evaluations

switch class(XoptGlobal.XOptimizer)
    case {'optimization.Cobyla' 'opencossan.optimization.Bobyqa','optimization.CrossEntropy'}
        %% Update Optimum object
        if isempty(XoptGlobal.Niterations)
            XoptGlobal.Niterations=0;
        else
            XoptGlobal.Niterations=XoptGlobal.Niterations+1;
        end
        
        XoptGlobal=XoptGlobal.addIteration('MdesignVariables',Mx,'MobjectiveFunction',MobjectiveFunction);
    case {'opencossan.optimization.EvolutionStrategy'}
        if XoptGlobal.Niterations>0
            XoptGlobal=XoptGlobal.addIteration('MdesignVariables',Mx,'MobjectiveFunction',MobjectiveFunction);
        end
    case {'opencossan.optimization.MiniMax'} 
        XoptGlobal=XoptGlobal.addIteration('MdesignVariables',Mx,'MobjectiveFunction',MobjectiveFunction);
        % Store the gradients of ALL objective function
%     case {'SequentialQuadraticProgramming'} 
%         if isempty(XoptGlobal.Niterations)
%             XoptGlobal.Niterations=0;
%         else
%             XoptGlobal.Niterations=XoptGlobal.Niterations+1;
%         end
%         XoptGlobal=XoptGlobal.addIteration('MdesignVariables',Mx,...
%             'MobjectiveFunction',MobjectiveFunction,'Mobjectivefunctiongradient',MgradientObjFun);
end

return
