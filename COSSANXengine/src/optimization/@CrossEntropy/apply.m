function [Xoptimum, varargout]= apply(Xobj,varargin)
%   APPLY   This method applies the algorithm
%           CrossEntropy for optimization
%
%       Gradient-free unconstrained optimization algorithm based in stochastic
%       search; if parameters of the model are tuned correctly, the solution
%       provided by CE may correspond to the global optimum. This algorithm
%       solves the problem:
%
%           min f_obj(x)
%                x in R^n
%
% See Also: https://cossan.co.uk/wiki/@CrossEntropy
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

%% Define global variable for the objective function and the constrains
global XoptGlobal XsimOutGlobal

OpenCossan.validateCossanInputs(varargin{:});

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1},'OptimizationProblem')   %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('OpenCossan:CrossEntropy:apply',...
                    'the variable %s must be an OptimizationProblem object',...
                    inputname(k));
            end
         case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:CrossEntropy:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
        case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('OpenCossan:CrossEntropy:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case 'minitialsolutions'
            MinitialSolution=varargin{k+1};
        otherwise
            error('OpenCossan:CrossEntropy:apply',['the field ' varargin{k} ...
                ' is not valid']);
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'OpenCossan:CrossEntropy:apply',...
    'Optimization problem must be defined')

assert(isempty(Xop.Xconstraint),'OpenCossan:CrossEntropy:apply:contraintsNotAllowed',...
        'CrossEntropy method is an unconstrint optimization method. It is not possible to be used to solve a constrained problem')


%% Check initial solution
if exist('MinitialSolution','var')
    Xop.VinitialSolution=MinitialSolution;
else
    if size(Xop.VinitialSolution,1)<Xobj.NUpdate
        OpenCossan.cossanDisp('Generate initial solutions for Cross Entropy',4)
        % Initialize vector for additional initial solutions
        MinitialSolution = zeros(Xobj.NUpdate-1,size(Xop.VinitialSolution,2));
        Cdvnames=Xop.Xinput.CnamesDesignVariable;
        for n=1:Xop.NdesignVariables
            Xdv=Xop.Xinput.XdesignVariable.(Cdvnames{n});
            MinitialSolution(:,n)=Xdv.sample('Nsamples',Xobj.NUpdate-1,'perturbation',2);
        end
    else
        OpenCossan.cossanDisp('Initial solutions defined in the optimization problem',4)
        MinitialSolution = [];
    end
end

%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=Optimum('XoptimizationProblem',Xop,'Xoptimizer',Xobj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end

% Create handle of the objective function
if isempty(Xop.Xmodel)
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor);
else
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor,'Xmodel',Xop.Xmodel);
end

%% Evaluation of initial population
Msamples=[Xop.VinitialSolution; MinitialSolution];
assert(size(Msamples,1)>=Xobj.NUpdate, 'OpenCossan:CrossEntropy:apply',...
    'At least %i initial solutions are required\nProvided initial solution %i',...
    Xobj.NUpdate,size(Msamples,1))

%% Here we go
Lstop=false;

%% Initialise optimiser
Xobj = initializeOptimizer(Xobj);

while ~Lstop   
    %  Evaluate objective function
    VF_obj_iter     = hobjfun(Msamples);  %Objective function evaluation
    
    % Sort values and calculate mean and standard deviation
    [~,F_obj_sort]  = sort(VF_obj_iter);        %Sort values of objective functions generated at current stage
    %Update mean according to promising samples
    Vmu   = mean( Msamples( F_obj_sort(1:Xobj.NUpdate),: ) );
    %Covariance Matrix of the Samples
    Mcov  = cov( Msamples( F_obj_sort(1:Xobj.NUpdate),: ) );
    
    Vsigma = std( Msamples( F_obj_sort(1:Xobj.NUpdate),: ));    %Update std according to promising samples

    % check termination criteria
    [Lstop,SexitFlag]=Xobj.checkTermination(XoptGlobal);
    
    
    if isempty(SexitFlag)
        if max(Vsigma)<Xobj.tolSigma  %in case convergence criterion has been achieved
            SexitFlag    = 'Standard deviation of associated stochastic problem smaller than tolerance';
            Lstop=true;
        end
    end
    
    %% Create new samples
    % Induce correlation in samples
    [Mfi,Mlambda]   = eig(Mcov);      %Decomposition of Covariance Matrix
    Vlambda         = diag(Mlambda);    %Eigenvalues of covariance matrix
    Veigvl_g0       = find(Vlambda>0);  %determine Eigenvalues larger than zero
    MB              = Mfi(:,Veigvl_g0) * sqrt(Mlambda(:,Veigvl_g0));    %Matrix to generate correlated rv's
    
    % Generate NEW random samples
    Msamples      = repmat(Vmu,Xobj.NFunEvalsIter,1) + ...
        (MB*randn(length(Veigvl_g0),Xobj.NFunEvalsIter))';     %Samples of the optimization variables
    % Evaluate objective function
    
end
OpenCossan.cossanDisp(['Exit Flag: ' SexitFlag],2)

% Assign outputs
XoptGlobal.VoptimalDesign=Msamples(F_obj_sort(1),:);
XoptGlobal.VoptimalScores=VF_obj_iter(F_obj_sort(1));
Xoptimum=XoptGlobal;
Xoptimum.Sexitflag=SexitFlag;

% Export Simulation Output
varargout{1}    = XsimOutGlobal;

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',{Xoptimum},...
            'CcossanObjectsNames',{'Xoptimum'});
    end
end
%% Delete global variables
clear global XoptGlobal XsimOutGlobal

%% Record Time
OpenCossan.setLaptime('Sdescription',['End apply@' class(Xobj)]);