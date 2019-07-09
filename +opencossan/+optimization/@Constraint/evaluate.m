function [Vin,Veq,MinGrad,MeqGrad] =evaluate(Xobj,varargin)
% EVALUATE This method evaluate the non linear inequality constraint and
% the linear equality constraint
%
% The candidate solutions (i.e. Design Variables) are stored in the matrix
% MX(Ncandidates,NdesignVariable)
%
% The constraint functions are stored in Mconstraints(Ncandidates,Nconstraints)
% The gradients of the contraint functions are store in MconstraintsGradient(NdesignVariable,NobjectiveFunctions)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/evaluate@Constraint
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

% Define global variable to store the optimum

import opencossan.workers.Evaluator

global XoptGlobal XsimOutGlobal

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
        case 'xoptimum'
            XoptGlobal=varargin{k+1};
        case 'lgradient'
            Lgradient=varargin{k+1};
        case 'mreferencepoints'
            Mx=varargin{k+1};
        case 'finitedifferenceperturbation'
            perturbation=varargin{k+1};
        case 'scaling'
            scaling=varargin{k+1};
        otherwise
            error('openCOSSAN:constraint:Evaluate',...
                'PropertyName %s is not a valid input',varargin{k});
    end
end
 

assert(logical(exist('XoptProb','var')), ...
    'openCOSSAN:optimization:constraint:evaluate',...
    'An OptimizationProblem must be passed using the PropertyName XoptimizationProblem');

assert(~isempty(XoptGlobal), ...
    'openCOSSAN:optimization:constraint:evaluate:emptyOptimum',...
    'It is necessary to initialize a Optimum object before evaluating the Constraint');

% Collect quantities

Linequality=Xobj(1).Linequality;
Coutputnames=Xobj(1).Coutputnames;

for n=2:length(Xobj)
    Linequality=[Linequality; Xobj(n).Linequality]; %#ok<AGROW>
    Coutputnames=[Coutputnames Xobj(n).Coutputnames]; %#ok<AGROW>
end


assert(logical(exist('Mx','var')),'cossanx:optimization:constraint:evaluate',...
    'Evaluation points (Design Variables) not defined');

NdesignVariables = size(Mx,2); %number of design variables
Ncandidates=size(Mx,1); % Number of candidate solutions

assert(XoptProb.NdesignVariables==NdesignVariables, ...
    'openCOSSAN:optimization:constraint:evaluate',...
    'Number of design Variables not correct');

if ~exist('XoptProb','var')
    error('openCOSSAN:Constraint:evaluate',...
        'An optimizationProblem object must be defined');
end

%% Prepare input values
if ~exist('Tinput','var')
    Xinput=XoptProb.Xinput.setDesignVariable('CSnames',XoptProb.CnamesDesignVariables,'Mvalues',Mx);
    TableInput=Xinput.getTable;
else
    % Copy the candidate solution into the input structure
    % TODO: this procedure will not work anymore beause we use tables now!
    warning('openCOSSAN:Constraint:evaluate','EXPERIMENTAL procedure, not tested')
    for nsol=1:Ncandidates
        for n=1:NdesignVariables
            Tinput(nsol).(XoptProb.CnamesDesignVariables{n}) = Mx(nsol,n);     %prepare Input object with design "x"
        end
        % Add values of all the other quantities (i.e. Parameters etc)
    end
end

%% Prepare input considering perturbations
if Lgradient    %checks whether or not gradient can be retrieved
    
    assert(~XoptProb.Xinput.LdiscreteDesignVariables,...
        'openCOSSAN:Constraint:evaluate',...
        'It is not possible to use gradient based optimization method with discrete DesignVariable');
    
    
    assert(Ncandidates==1, ...
        'openCOSSAN:Constraint:evaluate',...
        'Evaluation of the Constraints gradients is available only with 1 candidate solution');
    
    MxPerturbation=repmat(Mx,NdesignVariables,1)+diag(perturbation*Mx);
    Xinput=XoptProb.Xinput.setDesignVariable('CSnames',XoptProb.CnamesDesignVariables,'Mvalues',[Mx; MxPerturbation]);
    TableInput=Xinput.getTable;
end

% Extract required information from the SimulationData object (evaluated in the Objective Function)

% Evaluate the model if required by the constraints
if exist('Xmodel','var')
    XsimOutGlobal = apply(Xmodel,TableInput);
    
    % Update counter
    XoptGlobal.NevaluationsModel=XoptGlobal.NevaluationsModel+height(TableInput);
end

for icon=1:length(Xobj)
    TableInputSolver=Evaluator.addField2Table(Xobj(icon),XsimOutGlobal,TableInput);
    
    %% Evaluate function
    TableOutConstrains = evaluate@opencossan.workers.Mio(Xobj(icon),TableInputSolver);
    
    % keep only the variables defined in the Coutputnames
    Vkeep = ismember(TableOutConstrains.Properties.VariableNames,Xobj(icon).Coutputnames);
    
    % Collect perturbation values
    MoutConstrain=table2array(TableOutConstrains(:,Vkeep));
    
    % Store results in a global variables
    if icon==1
        % XoutConstrainsGlobal=XoutConstrains;
        Mout=MoutConstrain;
    else
        % XoutConstrainsGlobal=XoutConstrainsGlobal.merge(XoutConstrains);
        Mout=[Mout MoutConstrain]; %#ok<AGROW>
    end
end

%% Process data - gradient of the constrains
if Lgradient
    
    Vdfcon=zeros(NdesignVariables,length(Coutputnames));
    for n=2:height(TableInput)
        Vdfcon(n-1,:)  =(Mout(n,:)-Mout(1,:))/(perturbation*Mx(n-1));    %compute gradient
    end
    
    Mgradient  = Vdfcon/scaling;
    MinGrad=Mgradient(:,Linequality);
    MeqGrad=Mgradient(:,~Linequality);
    
    Mout=Mout(1,:);
else
    Mgradient = [];
end

%%   Apply scaling constant
Mout  = Mout/scaling;

% Assign output to the inequality and equality constrains
Vin=Mout(:,Linequality);
Veq=Mout(:,~Linequality);

%% Update function counter of the Optimiser
XoptGlobal.NevaluationsConstraints = XoptGlobal.NevaluationsConstraints+height(TableInput);  % Number of objective function evaluations

switch class(XoptGlobal.XOptimizer)
    case 'opencossan.optimization.Cobyla'
        %% Update Optimum object
        % Remove the sign changing for the constraints
        XoptGlobal=XoptGlobal.addIteration('MconstraintFunction',-Mout);
    case 'opencossan.optimization.GeneticAlgorithms'
        if size(Mout,1)==XoptGlobal.XOptimizer.NPopulationSize
            XoptGlobal=XoptGlobal.addIteration('MconstraintFunction',Mout);
        end
    case 'opencossan.optimization.StochasticRanking'
        if size(Mout,1)==XoptGlobal.XOptimizer.Nlambda
            XoptGlobal=XoptGlobal.addIteration('MconstraintFunction',Mout);
        end
     case {'opencossan.optimization.SequentialQuadraticProgramming'} 
         XoptGlobal=XoptGlobal.addIteration('Niteration',XoptGlobal.Niterations+1,...
             'MconstraintFunction',Mout,...
             'MconstraintFunctiongradient',Mgradient);
end



end

