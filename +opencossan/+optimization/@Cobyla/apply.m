function [Xoptimum, varargout] = apply(Xobj,varargin)
%   APPLY   This method applies the algorithm COBYLA (Costrained
%           Optimization by Linear Approximations) for optimization
%
%   APPLY This method applies the algorithm COBYLA. COBYLA was proposed by
%   M.J.D. Powell, 1994. It is a gradient-free optimization algorithm
%   capable of handling inequality constraints.
%   It solves the problem:
%
%   min f_obj(x)
%   subject to
%       cineq(x)    <= 0
%
%
%   See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Apply@Cobyla 
%             http://www.damtp.cam.ac.uk/user/na/NA_papers/NA1998_04.ps.gz
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

import opencossan.optimization.*

%% Define global variable for the objective function and the constrains
global XoptGlobal XsimOutGlobal

%%   Argument Check
%TODO: Update input parser

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
        case 'vinitialsolution'
            VinitialSolution=varargin{k+1};
        otherwise
            error('openCOSSAN:Cobyla:apply:wrongArgument', ...
                'The PropertyName %s is not valid',varargin{k});
    end
end


%% Check Optimization problem
if ~exist('Xop','var')
    error('openCOSSAN:optimization:cobyla:apply',...
        'Optimization problem must be defined')
end

%% Add bounds to the constraints
CnameDV=Xop.Xinput.DesignVariableNames;

for ndv=1:Xop.Xinput.NdesignVariables
    
    if isfinite(Xop.Xinput.DesignVariables.(CnameDV{ndv}).lowerBound)
        SdesignVariableName=[CnameDV{ndv} '_lowerBound'];
        
        OpenCossan.cossanDisp(['DesignVariable ' SdesignVariableName ' added to constraint object!'],3)
        
        Sscript=['for n=1:height(TableInput), TableOutput.' SdesignVariableName '(n) = ' ...
            num2str(Xop.Xinput.DesignVariables.(CnameDV{ndv}).lowerBound) ...
            ' - TableInput.' CnameDV{ndv} '(n); end'];
        
         XconstraintDV= Constraint('Sdescription',['lower bound - current value of ' CnameDV{ndv}], ...
        'Sscript',Sscript, 'SoutputName',SdesignVariableName,...
        'CinputNames',CnameDV(ndv),'Linequality',true); 
        
        Xop=Xop.addConstraint(XconstraintDV); 

    end
    
    if isfinite(Xop.Xinput.DesignVariables.(CnameDV{ndv}).upperBound)
        SdesignVariableName=[CnameDV{ndv} '_upperBound'];
        
        OpenCossan.cossanDisp(['DesignVariable ' SdesignVariableName ' added to constraint object!'],3)
        
        Sscript=['for n=1:height(TableInput), TableOutput.' SdesignVariableName '(n) = ' ...
            ' + TableInput.' CnameDV{ndv} '(n) - ' ...
            num2str(Xop.Xinput.DesignVariables.(CnameDV{ndv}).upperBound) '; end'];
        
        XconstraintDV= Constraint('Sdescription',['current value of ' CnameDV{ndv} ' - upper bound'], ...
        'Sscript',Sscript, 'SoutputName',SdesignVariableName,...
        'CinputNames',CnameDV(ndv),'Linequality',true); 
        
        Xop=Xop.addConstraint(XconstraintDV); 

    end
end

assert(~isempty(Xop.Xconstraint),...
    'openCOSSAN:optimization:cobyla:apply',...
    'It is not possible to apply COBYLA to solve UNCONSTRAINED problem')

Ndv     = Xop.NdesignVariables;  % number of design variables
N_ineq =  Xop.Nconstraints;       % Number of constrains

%% Check initial solution
if exist('VinitialSolution','var')
    Xop.VinitialSolution=VinitialSolution;  
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

% initialize global variable
XsimOutGlobal=[];

% Create handle of the objective function
% This variable is retrieved by mex file by name.
if isempty(Xop.Xmodel)
    objective_function_cobyla=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
    'MreferencePoints',x','Lgradient',false,...
    'scaling',Xobj.scalingFactor); %#ok<NASGU>
else
    objective_function_cobyla=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
    'MreferencePoints',x','Lgradient',false,'Xmodel',Xop.Xmodel,...
    'scaling',Xobj.scalingFactor); %#ok<NASGU>
end

% Create handle for the constrains
constraint_cobyla=@(x)evaluate(Xop.Xconstraint,'Xoptimizationproblem',Xop,...
    'MreferencePoints',x','Lgradient',false,...
    'scaling',Xobj.scalingFactorConstraints); %#ok<NASGU>

%% Perform optimization using Cobyla

OpenCossan.setLaptime('description',['COBYLA:' Xobj.Sdescription]);

[~,Nexitflag,~]    = cobyla_matlab(Xobj,...
    Xop.VinitialSolution,Xobj.Nmax,Xobj.rho_ini,Xobj.rho_end,Ndv,N_ineq);

OpenCossan.setLaptime('description','End COBYLA analysis');

%6.3.   Prepare string with reason for termination of optimization algorithm
switch Nexitflag,
    case{-2}
        Sexitflag   = 'No. optimization variables <0 or No. constraints <0';
    case{-1}
        Sexitflag   = 'Memory allocation failed';
    case{0}
        Sexitflag   = 'Normal return from cobyla';
    case{1}
        Sexitflag   = 'Maximum number of function evaluations reached';
    case{2}
        Sexitflag   = 'Rounding errors are becoming damaging';
    case{3}
        Sexitflag   = 'User requested end of minimization';
end


% Assign outputs
Xoptimum=XoptGlobal;
Xoptimum.Sexitflag=Sexitflag;

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

