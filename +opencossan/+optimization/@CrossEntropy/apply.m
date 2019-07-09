function [Xoptimum,varargout]= apply(Xobj,varargin)
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
% See Also: http://cossan.cfd.liv.ac.uk/wiki/apply@CrossEntropy
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


%% Define global variable for the objective function and the constrains
global XoptGlobal XsimOutGlobal

OpenCossan.validateCossanInputs(varargin{:});

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case {'xoptimizationproblem'},   %extract OptimizationProblem
            assert(isa(varargin{k+1},'opencossan.optimization.OptimizationProblem'),...
                'openCOSSAN:Cobyla:apply:wrongOptimizationProblem',...
                ['The variable %s must be an opencossan.optimization.OptimizationProblem\n',...
                'Provided class: %s'],inputname(k),class(varargin{k+1}))
            % Load OptimizationProblem
            Xop     = varargin{k+1};
        case {'xoptimum'},   %extract OptimizationProblem
            %check that arguments is actually an OptimizationProblem object
            assert(isa(varargin{k+1},'opencossan.optimization.Optimum'),...
                'openCOSSAN:Cobyla:apply:wrongOptimum',...
                ['The variable %s must be an opencossan.optimization.Optimum\n',...
                'Provided class: %s'],inputname(k),class(varargin{k+1}))
            Xoptimum  = varargin{k+1};
        case 'minitialsolutions'
            MinitialSolution=varargin{k+1};
        otherwise
            error('openCOSSAN:CrossEntropy:apply',['the field ' varargin{k} ...
                ' is not valid']);
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'openCOSSAN:CrossEntropy:apply',...
    'Optimization problem must be defined')

assert(isempty(Xop.Xconstraint),'openCOSSAN:CrossEntropy:apply:contraintsNotAllowed',...
        'CrossEntropy method is an unconstrint optimization method. It is not possible to be used to solve a constrained problem')

% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);

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
    XoptGlobal=Xop.initializeOptimum('LgradientObjectiveFunction',false, ...
        'LgradientConstraints',false,...
        'Xoptimizer',Xobj);
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
assert(size(Msamples,1)>=Xobj.NUpdate, 'openCOSSAN:CrossEntropy:apply',...
    'At least %i initial solutions are required\nProvided initial solution %i',...
    Xobj.NUpdate,size(Msamples,1))

%% Here we go
Lstop=false;

while ~Lstop   
   % XoptGlobal.Ngenerations = XoptGlobal.Ngenerations+1; %increase counter
%     OpenCossan.cossanDisp(['[Status] Iteration #' num2str(Xobj.iIterations)],2)
%     OpenCossan.setLaptime('description',[' Iteration #' num2str(Xobj.iIterations)]);
    
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
        if max(Vsigma)<Xobj.tolSigma,  %in case convergence criterion has been achieved
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
OpenCossan.setLaptime('description',['End apply@' class(Xobj)]);
