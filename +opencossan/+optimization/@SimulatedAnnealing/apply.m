function [Xoptimum varargout] = apply(Xobj,varargin)
%   APPLY   This method applies the algorithm SimulatedAnnealing for
%   optimization
%
%   Simulated Annealing (SA) can be used to found a MINIMUM of a function.
%   It is intended for solving the problem
%
%                       min f_obj(x)
%                       x in R^n
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Apply@SimultatedAnnealing
%
% Copyright~1993-2011,COSSAN Working Group, University~of~Innsbruck, Austria
% Author: Edoardo Patelli 

%% Define global variable for the objective function and the constrains
global XoptGlobal XsimOutGlobal

LplotEvolution=false;

OpenCossan.validateCossanInputs(varargin{:});

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case {'xoptimizationproblem'},   %extract OptimizationProblem
            if isa(varargin{k+1},'OptimizationProblem'),    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('openCOSSAN:SimulatedAnnealing:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end
        case {'xoptimum'},   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum'),    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('openCOSSAN:SimulatedAnnealing:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case 'vinitialsolution'
            VinitialSolution=varargin{k+1};
        case 'lplotevolution'
            LplotEvolution=varargin{k+1};
        otherwise
            error('openCOSSAN:SimulatedAnnealing:apply',...
                'The PropertyName %s is not valid', varargin{k});
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'openCOSSAN:SimulatedAnnealing:apply',...
    'Optimization problem must be defined')

% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);

if ~isempty(Xop.Xconstraint)
    warning('openCOSSAN:SimulatedAnnealing:apply',...
        'SimulationAnnealing method is an unconstrained optimization method. Constrain defined in the OptimizationProblem are ignored')
end

%% Check initial solution
if exist('VinitialSolution','var')
    Xop.VinitialSolution=VinitialSolution;
end

assert(size(Xop.VinitialSolution,1)==1, ...
    'openCOSSAN:SimulatedAnnealing:apply',...
    'Only 1 initial setting point is allowed')

%% initialize Optimum
if ~exist('Xoptimum','var')
    XoptGlobal=Xop.initializeOptimum('LgradientObjectiveFunction',false,'LgradientConstraints',false,...
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


%% Check if the required functions exist
% Debugging compiled version only
%  which simulannealbnd
%  which saoptimset 
% feval(@simulannealbnd,'defaults')

Toptions = saoptimset(@simulannealbnd); % Default options for simulated anneling

if LplotEvolution
    	Toptions = saoptimset('PlotFcns',{@saplotbestx,...
                @saplotbestf,@saplotx,@saplotf});
end

Toptions.AnnealingFcn=str2func(Xobj.SannealingFunction); % Annealing function
Toptions.TemperatureFcn=str2func(Xobj.StemperatureFunction); % Temperature function
Toptions.TolFun=Xobj.toleranceObjectiveFunction;
Toptions.StallIterLimit=Xobj.Nmaxmoves;
Toptions.MaxFunEvals=Xobj.Nmax;
Toptions.Display='iter';
Toptions.TimeLimit=Xobj.timeout;
Toptions.MaxIter=Xobj.NmaxIterations;
Toptions.ObjectiveLimit=Xobj.objectiveLimit;
Toptions.InitialTemperature=Xobj.initialTemperature;
Toptions.ReannealInterval=Xobj.NreannealInterval;
Toptions.OutputFcns = @Xobj.outputFunction;

% Pass additional parameter using global variables since matlab does not allowed
% user defined parameters

global TuserDefinedParameters

TuserDefinedParameters.k1=Xobj.k1;
TuserDefinedParameters.k2=Xobj.k2;
TuserDefinedParameters.k3=Xobj.k3;

%% Here we go



%% Perform Real optimization

OpenCossan.setLaptime('description',['SA:' Xobj.Sdescription]);

OpenCossan.cossanDisp('Starting Simulated Annealikng',2)

[~,~,Nexitflag]  = simulannealbnd(hobjfun,... % ObjectiveFunction
    Xop.VinitialSolution,... & initial solution
    Xop.VlowerBounds,Xop.VupperBounds,... % Bounds
    Toptions);

OpenCossan.setLaptime('description','End SA optimization');

%% Output
% All the quantities of interest are automatically stored in the Optimum
% object.

% Prepare string with reason for termination of optimization algorithm
switch Nexitflag
    case{1}
        Sexitflag   = 'Average change in the value of the objective function over options.StallIterLimit iterations is less than options.TolFun';
    case{5}
        Sexitflag   = 'options  objectiveLimit limit reached.';
    case{0}
        Sexitflag   = 'Number of iterations exceeded options.MaxIter or number of function evaluations exceeded options.MaxFunEvals';
    case{-1}
        Sexitflag   = 'Algorithm was terminated by the output function';
    case{-2}
        Sexitflag   = 'No feasible point was found';
    case{-5}
        Sexitflag   = ' Time limit exceeded.';
end

XoptGlobal.Sexitflag=Sexitflag;

% Assign outputs
Xoptimum=XoptGlobal;

% Export Simulation Output
%varargout{1}    = [XsimOutGlobal; XoutConstrainsGlobal];
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
clear global XoptGlobal XsimOutGlobal XoutConstrainsGlobal TuserDefinedParameters

%%  Set random number generator to state prior to running simulation
if exist('XRandomNumberGenerator','var'),
    Simulations.restoreRandomNumberGenerator(XRandomNumberGenerator)
end

%% Record Time
OpenCossan.setLaptime('description','End apply@SimulatedAnnealing');

return

%**************************************************************************
%
%   Simulated Annealing - function coded by EP - 2007
%
%**************************************************************************

function [Toutput] = run(Xobj,TObjFun)

% SA    SIMULATED ANNEALING for COSSAN
%
%   SA  Simulated Annealing (SA) can be used to found a MINIMUM of a
%       function. It is intended for solving the problem
%
%           min f_obj(x)
%           x in R^n
%
%
%   MANDATORY ARGUMENTS:
%
%   Xoptim          : optimizer object (details on how to define this
%                       object can be found in "optimizer" and in
%                       "options").
%
%   TObjFun          : structure that contains the following fields:
%   |-> Af_obj      : objective function (mandatory) (can be the fucntion name or an
%   |                 anonymuous function)
%   |-> Vlb         : lower bound for x;
%   |-> Vub         : upper bound for x;
%   |-> Anonlineqcon: constraints function* (can be the function name or an
%   |                 anonymuous function)
%   |-> Vx0         : Initial solution
%
%   OPTIONAL ARGUMENTS:
%
%   OUTPUT ARGUMENTS:
%
%   Toutput          : structure that contains the following information
%   |-> Vx_opt      : optimal solution
%   |-> Sexitflag   : exit flag
%   |-> Nfunc_eval  : Number of function evaluations
%   |-> Ncputime    : CPU required to complete the simulation
%
%
%   * the constrains function shuould return >0 if the nonlineqcon are
%   verified and <0 otherwise;
%
%   ** The trial vaules of the SA are calucalated as follow:
%   X (new) = X (old) + rand(1,0)*var;
%
%   USAGE:
%   function SA(options,f_obj)
%   E.g.
%   output=SA(optim,@(x)x(1)^2+x(2)^2,[-5 -2],[5 2],[0 0])
%
%
% all the output of the SA are stored in the file 'savefilename'
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2007 IfM
% =========================================================================
% History:
% 06/08/2007 EP: Added gaussian neighbour search  -> v.1.4
% 02/08/2007 EP: Bug correction (initial energy)  -> v.1.3
% 28/06/2007 EP: Porting of SA into COSSAN -> v.0.1
% =========================================================================


%% 1.   Set parameter

% start monitornig cpu time
%tic;
Tsa.Tcputime.Ntot=0;
Tsa.Tcputime.Nfeval=0;
Tsa.Tcputime.Nnfeval=0;

%Constructing a Handle to the anonymous Objective Function and nonlineqcon
Amyfun=TObjFun.Af_obj;

if isfield(TObjFun,'Anonlineqcon')
    Amynonlineqcon=TObjFun.Anonlineqcon;
end

if length(Xobj.VsearchRadius)~=size(TObjFun.Vx0,2)
    TObjFun.Vvar=Xobj.VsearchRadius(1)*ones(1,size(TObjFun.Vx0,2));   % define search radium
    % around the actual value
end

% if Toptions.verbose>0
%     progressbar;                                    % draw progressbar
% end

% Store the correlation functions
Tsa.TObjFun.NE=Amyfun(TObjFun.Vx0);
% TODO: Add support for penality function
if isfield(TObjFun,'Anonlineqcon')
    Tsa.TObjFun.NE=Tsa.TObjFun.NE+Amynonlineqcon(TObjFun.Vx0)*Toptions.pfpar;
end
Tsa.TObjFun.VX=TObjFun.Vx0;
Tsa.Ttmp.NE=Tsa.TObjFun.NE;                               % compute initail energy
Tsa.Ttmp.X=Tsa.TObjFun.VX;                               % compute initail position

% initial variables
Tsa.Ttmp.Nt=0;                                        % total moves x T
Tsa.Ttmp.Ng=0;                                        % accepted moves x T
Tsa.Nmaxmoves=0;
NT=Xobj.t0;                                       % Initial Temperature
p=0;                                                % Intialization of parameter
old_dE=0;                                           % Intialization of parameter
Tsa.Ttmp.Vvar=Xobj.VsearchRadius;                   % Initial scattering

% initialize the tracker
Tsa.Tinput.Nistep=Xobj.NMaxIter;
itt=1;
Tsa.Ttracker(itt).NT=NT;
Tsa.Ttracker(itt).NE=Tsa.TObjFun.NE;
Tsa.Ttracker(itt).NCPU=toc;
Tsa.Ttracker(itt).VX=Tsa.TObjFun.VX;
Nexitflag=0;

% initialize best solution
Tsa.Tbest.NE=Tsa.TObjFun.NE;
Tsa.Tbest.VX=Tsa.TObjFun.VX;


%% 2.2  SA - main
% presample block of random numbers
VsampleE=random('unif',0,1,Xobj.NMaxIter,1);

% start search algorithm
for i=1:Xobj.NMaxIter
    
    Ldone=false;
    
    while ~Ldone
        % compute new coordinates
        switch Xobj.Smode
            case ('uniform')
                Tsa.Ttmp.VX=Tsa.TObjFun.VX+(-0.5*ones(1,length(TObjFun.Vx0)) ...
                    +rand(1,length(TObjFun.Vx0),1)).*Tsa.Ttmp.Vvar;
            case ('gaussian')
                Tsa.Ttmp.VX=Tsa.TObjFun.VX+randn(1,length(TObjFun.Vx0),1).*Tsa.Ttmp.Vvar;
        end
        
        % Check lower limits
        if isfield(TObjFun, 'Vlb')
            Tsa.Ttmp.VX=max(Tsa.Ttmp.VX,TObjFun.Vlb);
        end
        
        % Check upper limits
        if isfield(TObjFun, 'ub')
            Tsa.Ttmp.VX=min(Tsa.Rtmp.VX,TObjFun.Vub);
        end
        
        % Check nonlineqcon
        if isfield(TObjFun, 'Anonlineqcon')       % The nonlineqcon function
            Nres=Amynonlineqcon(Tsa.Ttmp.VX);        % should return a value > 0
            if Nres<=0                           % when the contraints are
                Npf=0;
                Ldone=true;                      % satisfied and < 0 when
            else                                % they are violated
                %                 if Toptions.pfpar~=0;            % consider the inequality constraints as a penality function
                %                     Npf=Nres*Toptions.pfpar;
                %                     Ldone=true;
                %                 end
            end
        else
            Npf=0;
            Ldone=true;
        end
    end
    
    % Evaluate Objective Function
    Tsa.Tcputime.Nnfeval=Tsa.Tcputime.Nnfeval+1;
    Nt_in = cputime;                              % keep track of the time spent
    % to evaluate the
    % Objective Function
    Tsa.Ttmp.NE=Amyfun(Tsa.Ttmp.VX)+Npf;
    Tsa.Tcputime.Nfeval=Tsa.Tcputime.Nfeval+cputime-Nt_in;
    
    % The objcective function should be a positive or a negative function
    dE=-(Tsa.TObjFun.NE-Tsa.Ttmp.NE);
    
    Tsa.Ttmp.Nt=Tsa.Ttmp.Nt+1;                      % Number of iterations
    Tsa.Nmaxmoves=Tsa.Nmaxmoves+1;                  % Number of moves without improvements
    
    
    if dE<0                                     % Accept move (new configuration) if dE <0
        
        if Toptions.verbose>2
            OpenCossan.cossanDisp(['Move accepted (dE=',num2str(dE),')']);
        end
        Tsa.TObjFun.NE=Tsa.Ttmp.NE;
        Tsa.TObjFun.VX=Tsa.Ttmp.VX;
        
        Tsa.Ttmp.Ng=Tsa.Ttmp.Ng+1;                  % Number of good moves
        
        % Updating best solution
        if Tsa.Ttmp.NE<Tsa.Tbest.NE
            if  Tsa.Ttmp.Vvar>Toptions.Vvar
                Tsa.Ttmp.Vvar=Toptions.Vvar; % restore the default value
            elseif Tsa.Ttmp.Vvar>(Toptions.Vvar_min)
                Tsa.Ttmp.Vvar=Tsa.Ttmp.Vvar*Toptions.Vvar_down;
            end
            
            Tsa.Nmaxmoves=0;
            Tsa.Tbest.NE=Tsa.Ttmp.NE;                 % Obj.Fun.
            Tsa.Tbest.VX=Tsa.TObjFun.VX;              % solution found
            Tsa.Tbest.Niteration=i;                % iteration number
            if Toptions.verbose>2
                OpenCossan.cossanDisp(['New best solution found  (E=',num2str(Tsa.Tbest.NE),')']);
            end
        end
    else                            %Maybe accept the move
        p=exp(-dE/NT);
        old_dE=dE;
        rn=VsampleE(i);
        
        if rn<p
            Tsa.TObjFun.NE=Tsa.Ttmp.NE;
            Tsa.TObjFun.VX=Tsa.Ttmp.VX;
            if Toptions.verbose>2
                OpenCossan.cossanDisp(['Move accepted (dE=',num2str(dE),')']);
            end
        end
    end
    
    % update Temperature
    if Tsa.Ttmp.Ng>=Toptions.Ng || Tsa.Ttmp.Nt>=Toptions.Nt
        
        
        NT=Toptions.K1*NT^(Toptions.K2)+Toptions.K3;
        
        if NT<0
            NT=0;
        end
        
        if Toptions.verbose>2
            OpenCossan.cossanDisp(['Updating temperature (T=',num2str(T),')']);
        end
        
        if Toptions.Ladaptive
            if Tsa.Ttmp.Ng<=Toptions.Ng && Tsa.Ttmp.Vvar<(Toptions.Vvar_max)
                %  INCREASE the scattering around the solution
                Tsa.Ttmp.Vvar=Tsa.Ttmp.Vvar*Toptions.Vvar_up;
            end
        end
        
        Tsa.Ttmp.Ng=0;
        Tsa.Ttmp.Nt=0;
        
    end
    
    %updating tracking
    if rem(i,Tsa.Tinput.Nistep)==0
        itt=itt+1;
        Tsa.Ttracker(itt).NT=NT;
        Tsa.Ttracker(itt).NE=Tsa.TObjFun.NE;
        Tsa.Ttracker(itt).NCPU=toc;
        Tsa.Ttracker(itt).VX=Tsa.TObjFun.VX;
        
        if Toptions.verbose>1
            OpenCossan.cossanDisp(strcat('Iterarion # ',num2str(i),...
                ' Energy = ',num2str(Tsa.Ttmp.NE), ...
                ' NT = ',num2str(NT), ...
                ' Last p=',num2str(p),...
                ' var=',num2str(Tsa.Ttmp.Vvar),...
                ' (dE=',num2str(old_dE),') - Best E= ',num2str(Tsa.Tbest.NE)));
        end
    end
    
    %exit form the iteration loop if the target configuration is found
    
    if Tsa.Nmaxmoves>Toptions.Nmaxmoves,
        Nexitflag=3;
        itt=itt+1;
        Tsa.Ttracker(itt).NT=NT;
        Tsa.Ttracker(itt).NE=Tsa.Ttmp.NE;
        Tsa.Ttracker(itt).CPU=toc;
        Tsa.Tcputime.Ntot=toc;
        Tsa.Ttracker(itt).VX=Tsa.Ttmp.VX;
        break
    elseif Tsa.Tbest.NE<Toptions.n_opt;
        Nexitflag=1;
        itt=itt+1;
        Tsa.Ttracker(itt).NT=NT;
        Tsa.Ttracker(itt).NE=Tsa.Ttmp.NE;
        Tsa.Tcputime.Ntot=toc;
        Tsa.Ttracker(itt).CPU=toc;
        Tsa.Ttracker(itt).VX=Tsa.Ttmp.VX;
        break
    end
    
end

if Nexitflag==0
    Nexitflag=2;
end

if Toptions.verbose>1
    OpenCossan.cossanDisp(strcat('Iterarion # ',num2str(i),' Energy = ',num2str(Tsa.Ttmp.NE)));
    OpenCossan.cossanDisp('');
    OpenCossan.cossanDisp(strcat('Best E= ',num2str(Tsa.Tbest.NE)));
    OpenCossan.cossanDisp(strcat('Best X= ',num2str(Tsa.Tbest.VX)));
    OpenCossan.cossanDisp('');
    Tsa.Tcputime.tot=toc;
    disp (strcat('Totat CPU time = ',num2str(Tsa.Tcputime.Ntot)));
    disp (strcat('Totat CPU time for evaluate objective function = ',num2str(Tsa.Tcputime.Nfeval)));
    disp (strcat('Totat number of  objective function evaluation = ',num2str(Tsa.Tcputime.Nnfeval)));
    disp ('');
    disp ('Servus');
end

% store SA results for future use (optional)
if isfield(Toptions, 'filename')
    save (Toptions.Sfilename,'SA');
end


%% 3.   Output
Toutput.Vx_opt        = Tsa.Tbest.VX;
Toutput.f_opt        = Tsa.Tbest.NE;
Toutput.Vfunc_eval    = Tsa.Tcputime.Nnfeval;
Toutput.Ncputime      = toc;

switch Nexitflag,
    case{1}
        Toutput.Sexitflag     = ['Optimal value found after ' num2str(Tsa.Tbest.Niteration) ' moves'];
    case{2}
        Toutput.Sexitflag     = 'Number of iterations exceeded options.NMaxIter';
    case{3}
        Toutput.Sexitflag     = ['No better solution found after ' num2str(Toptions.Nmaxmoves) ' moves '];
end

%close progressbar
% if Toptions.verbose>0
%         progressbar(1);
% end

return

function temperature = temperatureCossan(ToptimValues,Toptions)
%TEMPERATURECOSSAN Updates the temperature vector for annealing process
%   TEMPERATURE = TEMPERATURECOSSAN(optimValues,options) uses COSSAN
%   annealing by updating the current temperature based on 3 anneling factors.
%
%   TOPTIMVALUES is a structure containing the following information:
%              x: current point
%           fval: function value at x
%          bestx: best point found so far
%       bestfval: function value at bestx
%    temperature: current temperature
%      iteration: current iteration
%             t0: start time
%              k: annealing parameter
%
%   TOPTIONS: options structure created by using SAOPTIMSET.

global TuserDefinedParameters

temperature = TuserDefinedParameters.k1*ToptimValues.k(:).^(TuserDefinedParameters.k2)+TuserDefinedParameters.k3;



function newx = annealinguniform(ToptimValues,Tproblem)
%ANNEALINGUNIFORM Generates a point using uniform distribution.
%   NEWX = ANNEALINGBOLTZ(optimValues,problem) generates a point based
%   on the current point and the current temperature using uniform distribution.
%
%   OPTIMVALUES is a structure containing the following information:
%              x: current point
%           fval: function value at x
%          bestx: best point found so far
%       bestfval: function value at bestx
%    temperature: current temperature
%      iteration: current iteration
%             t0: start time
%              k: annealing parameter
%
%   PROBLEM is a structure containing the following information:
%      objective: function handle to the objective function
%             x0: the start point
%           nvar: number of decision variables
%             lb: lower bound on decision variables
%             ub: upper bound on decision variables
%

currentx = ToptimValues.x;
nvar = numel(currentx);
newx = currentx;
y = rand(nvar,1);
y = y./norm(y);


newx(:) = currentx(:).*(1+ 0.1*sqrt(ToptimValues.temperature).*y);

newx(:)=max(newx(:),Tproblem.lb);
newx(:)=min(newx(:),Tproblem.ub);
%newx = sahonorbounds(newx,ToptimValues,Tproblem);
