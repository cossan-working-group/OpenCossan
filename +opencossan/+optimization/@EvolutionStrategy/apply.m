function [Xoptimum,varargout] = apply(Xobj,varargin)
%   APPLY   This method applies the algorithm
%           EvolutionStrategy for optimization
%
%   Evolution Strategies is a gradient-free optimization algorithm that
%   performs a stochastic search in the space of the design variables.
%   Evolution Strategies solves the problem
%
%           min f_obj(x)
%           x in R^n
%
%   [Xoutput_ES]   = apply(Xobj,'OptimizationProblem'Xop)
%
% See also: https://cossan.co.uk/wiki/index.php/Apply@EvolutionStrategy
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
        case {'xoptimizationproblem'}  %extract OptimizationProblem
            if isa(varargin{k+1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('OpenCossan:EvolutionStrategy:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end
        case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:EvolutionStrategy:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
        case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('OpenCossan:EvolutionStrategy:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case 'minitialsolutions'
            MinitialSolution=varargin{k+1};
        case 'vsigma'
            Xobj.Vsigma=varargin{k+1};
        otherwise
            error('OpenCossan:EvolutionStrategy:apply',...
                'the Property Name %s is not valid',varargin{k});
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'OpenCossan:EvolutionStrategy:apply',...
    'Optimization problem must be defined')

assert(isempty(Xop.Xconstraint),'OpenCossan:EvolutionStrategy:apply:contraintsNotAllowed',...
        'EvolutionStrategy method is an unconstrint optimization method. It is not possible to be used to solve a constrained problem')


% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);
NdesignVariable=length(Xop.CnamesDesignVariables);

%% Check initial solution
if exist('MinitialSolution','var')
    assert(size(MinitialSolution,1)==Xobj.Nmu,'OpenCossan:EvolutionStrategy:apply',...
        ['EvolutionStrategy requires ' num2str(Xobj.Nmu) ' initial solutions'])
else
    if size(Xop.VinitialSolution,1)==Xobj.Nmu
        MinitialSolution=Xop.VinitialSolution;
    else
        MinitialSolution=randn(Xobj.Nmu,NdesignVariable);
        
        if length(Xobj.Vsigma)==NdesignVariable
            for n=1:NdesignVariable
                MinitialSolution(:,n)= Xobj.Vsigma(n).*MinitialSolution(:,n);
            end
        else
            MinitialSolution=Xobj.Vsigma.*MinitialSolution;
        end
    end
end

%% Check initial solution
if exist('MinitialSolution','var')
    Xop.VinitialSolution=MinitialSolution;
end

%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=Optimum('XoptimizationProblem',Xop,'Xoptimizer',Xobj);
else
    %TODO: Check Optimum
    XoptGlobal=Xoptimum;
end

% initialize global variable
XsimOutGlobal=[];


% Create handle of the objective function
if isempty(Xop.Xmodel)
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor);
else
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor,'Xmodel',Xop.Xmodel);
end

%% Evaluation of initial population
Mparents=Xop.VinitialSolution;

if isempty(Xobj.Vsigma)
    Msigma=ones(Xobj.Nlambda,NdesignVariable);
elseif length(Xobj.Vsigma)==1
    Msigma  = repmat(Xobj.Vsigma,Xobj.Nmu,NdesignVariable);
else
    assert(length(Xobj.Vsigma)==NdesignVariable,...
        'OpenCossan:EvolutionStrategy:apply',...
        ['Vsigma must be of length ' num2str(NdesignVariable)])
    Msigma  = repmat(Xobj.Vsigma(:)',Xobj.Nmu,1);
end

%% Here we go

%% Initialize Parent Population
% Xobj.iIterations=0;
% OpenCossan.cossanDisp(['Iteration #' num2str(Xobj.iIterations)],2)
% Create initial population

% Evaluate objective function
XoptGlobal.Niterations=0;
Vfitness_parents    = hobjfun(Mparents);       %Objective function evaluation
mean_fitness_new    = mean(Vfitness_parents);  %calculates mean fitness
% Prepare values for iteration MV coding style
Mfullparents         = [Mparents,Msigma,Vfitness_parents];    %creates matrix containing parents, vector of std. deviation and fitnesses

Lstop=false;
while ~Lstop
    XoptGlobal.Niterations=XoptGlobal.Niterations+1;
    MparentsOld=Mfullparents(1:Xobj.Nmu,:);
    mean_fitness_old    = mean_fitness_new;     %save value of mean fitness
    
    %% 2. Generate Lambda offspring
    %recombination step
    Mfullint_parents        = recombination(Xobj,Mfullparents);
    %mutation step
    Mfulloffspring          = mutation(Xobj,Mfullint_parents);
    %Objective function evaluation
    Mfulloffspring(:,end)   = hobjfun(Mfulloffspring(:,1:NdesignVariable));
    
    %% 3. Select new parent population
    Mfullparents            = selection(Xobj,Mfullparents,Mfulloffspring);
    
    %calculate mean fitness
    mean_fitness_new    = mean(Mfullparents(:,end));
    
    % check global termination criteria
    [Lstop,SexitFlag]=Xobj.checkTermination(XoptGlobal);

    
    %% check object specific termination criteria
    % Check tolerance Objective Function
    if ~isempty(Xobj.toleranceObjectiveFunction)
        if abs(mean_fitness_new-mean_fitness_old)<Xobj.toleranceObjectiveFunction  %in case convergence criterion has been achieved
            SexitFlag    = ['deltaObjectiveFunction termination criteria archived (' num2str(abs(mean_fitness_new-mean_fitness_old)) ')'];
            Lstop=true;
        end
    end
    
    %check tolerance Design Variable
    if ~isempty(Xobj.toleranceDesignVariables)
        deltaDV=sum(sum(abs(Mfullparents(1:Xobj.Nmu,:)-MparentsOld)));
        if deltaDV<Xobj.toleranceDesignVariables  %in case convergence criterion has been achieved
            SexitFlag    = ['Termination criteria for the Design Variable archived (' num2str(deltaDV) ')'];
            Lstop=true;
        end
    end
    
end
%OpenCossan.cossanDisp(['Exit Flag: ' SexitFlag],2)

% Assign outputs


%XoptGlobal.TabblesValues.
[XoptGlobal.VoptimalScores,pos]=min(XoptGlobal.TablesValues.ObjectiveFnc);
XoptGlobal.VoptimalDesign=XoptGlobal.TablesValues.DesignVariables(pos,:);
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
