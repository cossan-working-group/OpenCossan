function [Vin,Veq,MinGrad,MeqGrad] =evaluate(Xobj,varargin)
% EVALUATE This method evaluates the non linear inequality constraint and
% the linear equality constraint
%
% The candidate solutions (i.e. Design Variables) are stored in the matrix
% Minput (Ncandidates,NdesignVariable)
%
% The constraint functions are stored in Mconstraints(Ncandidates,Nconstraints)
% The gradients of the contraint functions are store in
% MconstraintsGradient(NdesignVariable,NobjectiveFunctions) 
%
% Finally the values the design variables and the constraints are stored in
% the Optimum object
%
% See Also: https://cossan.co.uk/wiki/evaluate@Constraint
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

global XoptGlobal XsimOutGlobal

OpenCossan.validateCossanInputs(varargin{:})
Lgradient=false;
scaling=1;
% TODO: Reduce the default value for the perturbation
perturbation=0.1;

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
            Minput=varargin{k+1};
        case 'finitedifferenceperturbation'
            perturbation=varargin{k+1};
        case 'scaling'
            scaling=varargin{k+1};
        otherwise
            error('OpenCossan:constraint:Evaluate',...
                'PropertyName %s is not a valid input',varargin{k});
    end
end
 

assert(logical(exist('XoptProb','var')), ...
    'OpenCossan:optimization:constraint:evaluate',...
    'An OptimizationProblem must be passed using the PropertyName XoptimizationProblem');

assert(~isempty(XoptGlobal), ...
    'OpenCossan:optimization:constraint:evaluate:emptyOptimum',...
    'It is necessary to initialize a Optimum object before evaluating the Constraint');

% Collect quantities

Linequality=[Xobj.Linequality];
Coutputnames=[Xobj.Coutputnames];

assert(logical(exist('Minput','var')),'OpenCossan:Constraint:evaluate',...
    'Evaluation points (Design Variables) not defined');

NdesignVariables = size(Minput,2); %number of design variables
Ncandidates=size(Minput,1); % Number of candidate solutions

assert(XoptProb.NdesignVariables==NdesignVariables, ...
    'OpenCossan:optimization:constraint:evaluate',...
    'Number of design Variables not correct');

if ~exist('XoptProb','var')
    error('OpenCossan:Constraint:evaluate',...
        'An optimizationProblem object must be defined');
end

%% Prepare input considering perturbations
if Lgradient    %checks whether or not gradient can be retrieved
    
    assert(~XoptProb.Xinput.LdiscreteDesignVariables,...
        'OpenCossan:Constraint:evaluate',...
        'It is not possible to use gradient based optimization method with discrete DesignVariable');
    
    
    assert(Ncandidates==1, ...
        'OpenCossan:Constraint:evaluate',...
        'Evaluation of the Constraints gradients is available only with 1 candidate solution');
    
    % 
    MxPerturbation=repmat(Minput,NdesignVariables,1)+diag(max(perturbation*Minput,perturbation));

    Minput=[Minput; MxPerturbation];
end

% Prepare input object
Xinput=XoptProb.Xinput.setDesignVariable('CSnames',XoptProb.CnamesDesignVariables,'Mvalues',Minput);
Tinput=Xinput.getStructure;

% Extract required information from the SimulationData object (evaluated in
% the Objective Function) if available

% Evaluate the model if required by the constraints
if exist('Xmodel','var')
    XsimOutGlobal = apply(Xmodel,Tinput);    
    % Update counter
    XoptGlobal.NevaluationsModel=XoptGlobal.NevaluationsModel+length(Tinput);
end

MoutConstrains=[];
for icon=1:length(Xobj)
    TinputSolver=Evaluator.addField2Structure(Xobj(icon),XsimOutGlobal,Tinput);
    
    %% Evaluate function
    XoutConstrains = run(Xobj(icon),TinputSolver);
    
    % keep only the variables defined in the Coutputnames
    XoutConstrains=XoutConstrains.split('Cnames',Xobj(icon).Coutputnames);
    
    % Collect perturbation values
    Mtmp=XoutConstrains.getValues('Cnames',Xobj(icon).Coutputnames);
    
    MoutConstrains=[MoutConstrains Mtmp]; %#ok<AGROW>
end

%% Process data - gradient of the constrains
if Lgradient
    % Compute gradient
    Vdfcon=zeros(NdesignVariables,length(Coutputnames));
    for n=2:length(Tinput)
        %compute gradient for each variable
        Vdfcon(n-1,:)  =(MoutConstrains(n,:)-MoutConstrains(1,:))./(Minput(n,n-1)-Minput(1,n-1));   
    end
    
    Mgradient  = Vdfcon/scaling;
    MinGrad=Mgradient(:,Linequality);
    MeqGrad=Mgradient(:,~Linequality);
end

%%   Apply scaling constant
Mout  = MoutConstrains(1:Ncandidates,:)/scaling;

% Assign output to the inequality and equality constrains
Vin=Mout(:,Linequality);
Veq=Mout(:,~Linequality);

%% Update function counter of the Optimiser
XoptGlobal.NevaluationsConstraints = XoptGlobal.NevaluationsConstraints+length(Tinput);  % Number of objective function evaluations

switch class(XoptGlobal.XOptimizer)
    case 'Cobyla'
        %% Update Optimum object
        % Remove the sign changing for the constraints
        XoptGlobal=XoptGlobal.addIteration('MconstraintFunction',-MoutConstrains,...
            'Niteration',XoptGlobal.Niterations,'Mdesignvariables',Minput);
    case 'GeneticAlgorithms'
%        XoptGlobal.Niterations=XoptGlobal.Niterations+1;
        if size(Mout,1)==XoptGlobal.XOptimizer.NPopulationSize
            XoptGlobal=XoptGlobal.addIteration('MconstraintFunction',MoutConstrains,...
                'Mdesignvariables',Minput,...
                'Viterations',repmat(max(0,XoptGlobal.Niterations),size(Minput,1),1));
        end
    case 'StochasticRanking'
        if size(Mout,1)==XoptGlobal.XOptimizer.Nlambda
            XoptGlobal=XoptGlobal.addIteration('MconstraintFunction',MoutConstrains,...
                'Mdesignvariables',Minput,...
                'Viterations',repmat(max(0,XoptGlobal.Niterations),size(Minput,1),1));
        end
     case {'SequentialQuadraticProgramming'} 
         XoptGlobal=XoptGlobal.addIteration(...
              'Viterations',repmat(max(0,XoptGlobal.Niterations),size(Minput,1),1),...
             'Mdesignvariables',Minput,...
             'MconstraintFunction',MoutConstrains);
end

