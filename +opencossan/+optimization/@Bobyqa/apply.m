function [Xoptimum,varargout] = apply(Xobj,varargin)
%   APPLY   This method applies the algorithm BOBYQA (Bounded
%           Optimization by Quadratic Approximations) for optimization
%
%   APPLY This method applies the algorithm BOBYQA.
%
%   min f_obj(x)
%   subject to
%       lower(x) <= x <= upper(x)
%
%
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
                error('OpenCossan:Bobyqa:apply',...
                    ['the variable  ' inputname(k) ...
                    ' must be an OptimizationProblem object']);
            end
         case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:Bobyqa:apply',...
                    ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
        case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('OpenCossan:Bobyqa:apply',...
                    ['the variable  ' inputname(k) ...
                    ' must be an Optimum object']);
            end
        case 'vinitialsolution'
            VinitialSolution=varargin{k+1};
        otherwise
            error('OpenCossan:Bobyqa:apply', ...
                'The PropertyName %s is not valid',varargin{k});
    end
end


%% Check Optimization problem
if ~exist('Xop','var')
    error('OpenCossan:optimization:bobyqa:apply',...
        'Optimization problem must be defined')
end

%% Add bounds to the constraints
Ndv     = Xop.NdesignVariables;  % number of design variables

Vdx     = Xobj.stepSize*ones(1,Ndv);

CnameDV=Xop.Xinput.CnamesDesignVariable;

VxLowerBounds = Xop.VlowerBounds;
VxUpperBounds = Xop.VupperBounds;

for jdv=1:Ndv
    
    assert(isfinite(VxLowerBounds(jdv)),...
        'OpenCossan:optimization:bobyqa:apply',...
        ['BOBYQA operates with bounded design variables, \n',...
        'please provide a LOWER BOUND for (%n)'],CnameDV{jdv});
    
    assert(isfinite(VxUpperBounds(jdv)),...
        'OpenCossan:optimization:bobyqa:apply',...
        ['BOBYQA operates with bounded design variables, \n',...
        'please provide an UPPER BOUND for (%n)'],CnameDV{jdv});
end

%% Check initial solution
if isempty(Xop.VinitialSolution)
    if exist('VinitialSolution','var')
        Xop.VinitialSolution=VinitialSolution;
    else
        error('OpenCossan:optimization:bobyqa:apply',...
            'Please provide a reference point to start the optimization with');
    end
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
    objective_function_bobyqa=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
    'MreferencePoints',x','Lgradient',false,...
    'scaling',Xobj.scalingFactor); %#ok<NASGU>
else
    objective_function_bobyqa=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
    'MreferencePoints',x','Lgradient',false,'Xmodel',Xop.Xmodel,...
    'scaling',Xobj.scalingFactor); %#ok<NASGU>
end


%% Perform optimization using Bobyqa

OpenCossan.setLaptime('Sdescription',['BOBYQA:' Xobj.Sdescription]);

%[Vopt,Nexitflag,Neval]
[XoptGlobal.VoptimalDesign,Nexitflag,~]    = bobyqa_matlab(Ndv,Xobj.npt,Xop.VinitialSolution,...
    VxLowerBounds,VxUpperBounds,Vdx,Xobj.rhoEnd,Xobj.xtolRel,...
    Xobj.minfMax,Xobj.ftolRel,Xobj.ftolAbs,Xobj.maxeval,Xobj.verbose);


OpenCossan.setLaptime('Sdescription','End BOBYQA analysis');

% Prepare string with reason for termination of optimization algorithm
switch Nexitflag
    case{-4}
        Sexitflag   = 'failure';
    case{-1}
        Sexitflag   = 'invalid argument';
    case{-2}
        Sexitflag   = 'out of memory';
    case{-3}
        Sexitflag   = 'round-off limited';
    case{0}
        Sexitflag   = 'success';
    case{1}
        Sexitflag   = 'requested function value reached';
    case{2}
        Sexitflag   = 'function value tolerance reached';
    case{5}
        Sexitflag   = 'relative function value tolerance reached';
    case{6}
        Sexitflag   = 'absolute function value tolerance reached';
    case{3}
        Sexitflag   = 'parameter tolerance reached';
    case{4}
        Sexitflag   = 'maximum number of function evaluations reached';
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


