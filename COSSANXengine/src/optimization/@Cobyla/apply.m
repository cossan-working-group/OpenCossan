function [Xoptimum,varargout] = apply(Xobj,varargin)
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
%   See also: https://cossan.co.uk/wiki/index.php/Apply@Cobyla 
% http://www.damtp.cam.ac.uk/user/na/NA_papers/NA1998_04.ps.gz
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

%%   Argument Check
OpenCossan.validateCossanInputs(varargin{:})

%  Check whether or not required arguments have been passed
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('OpenCossan:Cobyla:apply',...
                    ['the variable  ' inputname(k) ...
                    ' must be an OptimizationProblem object']);
            end
        case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:Cobyla:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
       case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('OpenCossan:Cobyla:apply',...
                    ['the variable  ' inputname(k) ...
                    ' must be an Optimum object']);
            end
        case 'vinitialsolution'
            VinitialSolution=varargin{k+1};
        otherwise
            error('OpenCossan:Cobyla:apply:wrongInputArgument', ...
                'The PropertyName %s is not valid',varargin{k});
    end
end


%% Check Optimization problem
if ~exist('Xop','var')
    error('OpenCossan:Cobyla:apply:NoOptimizationProblemDefined',...
        'Optimization problem must be defined')
end

%% Add bounds to the constraints
CnameDV=Xop.Xinput.CnamesDesignVariable;

for ndv=1:Xop.Xinput.NdesignVariables
    
    if isfinite(Xop.Xinput.XdesignVariable.(CnameDV{ndv}).lowerBound)
        SdesignVariableName=[CnameDV{ndv} '_lowerBound'];
        
        OpenCossan.cossanDisp(['DesignVariable ' SdesignVariableName ' added to constraint object!'],3)
        
        Sscript=['for n=1:length(Tinput), Toutput(n).' SdesignVariableName ' = ' ...
            num2str(Xop.Xinput.XdesignVariable.(CnameDV{ndv}).lowerBound) ...
            ' - Tinput(n).' CnameDV{ndv} '; end'];
        
         XconstraintDV= Constraint('Sdescription',['lower bound - current value of ' CnameDV{ndv}], ...
        'Sscript',Sscript, 'SoutputName',SdesignVariableName,...
        'CinputNames',CnameDV(ndv),'Linequality',true,'Liostructure',true); 
        
        Xop=Xop.addConstraint(XconstraintDV); 

    end
    
    if isfinite(Xop.Xinput.XdesignVariable.(CnameDV{ndv}).upperBound)
        SdesignVariableName=[CnameDV{ndv} '_upperBound'];
        
        OpenCossan.cossanDisp(['DesignVariable ' SdesignVariableName ' added to constraint object!'],3)
        
        Sscript=['for n=1:length(Tinput), Toutput(n).' SdesignVariableName ' = ' ...
            ' + Tinput(n).' CnameDV{ndv} '- ' ...
            num2str(Xop.Xinput.XdesignVariable.(CnameDV{ndv}).upperBound) '; end'];
        
        XconstraintDV= Constraint('Sdescription',['current value of ' CnameDV{ndv} ' - upper bound'], ...
        'Sscript',Sscript, 'SoutputName',SdesignVariableName,...
        'CinputNames',CnameDV(ndv),'Linequality',true,'Liostructure',true); 
        
        Xop=Xop.addConstraint(XconstraintDV); 

    end
end

assert(~isempty(Xop.Xconstraint),...
    'OpenCossan:cobyla:apply',...
    'It is not possible to apply COBYLA to solve UNCONSTRAINED problem')

Ndv     = Xop.NdesignVariables;  % number of design variables
N_ineq =  Xop.Nconstraints;       % Number of constrains

%% Check initial solution
if exist('VinitialSolution','var')
    Xop.VinitialSolution=VinitialSolution;  
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

OpenCossan.setLaptime('Sdescription',['COBYLA:' Xobj.Sdescription]);

[VoptimalDesign,Nexitflag,XoptGlobal.VoptimalScores]    = cobyla_matlab(Xobj,...
    Xop.VinitialSolution,Xobj.Nmax,Xobj.rho_ini,Xobj.rho_end,Ndv,N_ineq);

XoptGlobal.VoptimalDesign=VoptimalDesign';

% Retrieve values of constraints from the Optimum
VoptimalConstraint=XoptGlobal.TablesValues.Constraints ...
    (all(XoptGlobal.TablesValues.DesignVariables==VoptimalDesign,2),:);

% Remove NaN
XoptGlobal.VoptimalConstraints=VoptimalConstraint(~isnan(VoptimalConstraint))';

OpenCossan.setLaptime('Sdescription','End of the COBYLA analysis');

%6.3.   Prepare string with reason for termination of optimization algorithm
switch Nexitflag
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
OpenCossan.setLaptime('Sdescription',['End apply@' class(Xobj)]);

