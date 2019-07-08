function [Xoptimum,varargout] = apply(Xobj,varargin)
%APPLY   This method applies the algorithm
%           StochasticRanking for optimization
%
%
% See Also: https://cossan.co.uk/wiki/index.php/apply@StochasticRanking
%
% Author: Edoardo Patelli
% Website: http://www.cossan.co.uk

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
            if isa(varargin{k+1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1};
            else
                error('OpenCossan:StochasticRanking:apply',...
                    ['The variable %s must be an OptimizationProblem object,' ...
                    ' provided object of type %s'],...
                    inputname(k),class(varargin{k+1}));
            end
        case {'cxoptimizationproblem'}   %extract OptimizationProblem
            if isa(varargin{k+1}{1},'OptimizationProblem')    %check that arguments is actually an OptimizationProblem object
                Xop     = varargin{k+1}{1};
            else
                error('OpenCossan:StochasticRanking:apply',...
                     ['the variable  ' inputname(k) ' must be an OptimizationProblem object']);
            end  
        case {'xoptimum'}   %extract OptimizationProblem
            if isa(varargin{k+1},'Optimum')    %check that arguments is actually an OptimizationProblem object
                Xoptimum  = varargin{k+1};
            else
                error('OpenCossan:StochasticRanking:apply',...
                    ['the variable  ' inputname(k) ' must be an Optimum object']);
            end
        case 'vsigma'
            Xobj.Vsigma=varargin{k+1};
        otherwise
            error('OpenCossan:StochasticRanking:apply',...
                'the Property Name %s is not valid',varargin{k});
    end
end

%% Check Optimization problem
assert(logical(exist('Xop','var')), 'OpenCossan:StochasticRanking:apply',...
    'Optimization problem must be defined')

assert(all([Xop.Xconstraint.Linequality]), 'OpenCossan:StochasticRanking:apply',...
    'StochasticRanking can perform optimization with inequality constraint only.')

% Check inputs and initialize variables
Xobj = initializeOptimizer(Xobj);

% retrieve lower and upper bounds of the design variables
Mlowerupper = zeros(2,Xop.Xinput.NdesignVariables);
CnameDV=Xop.Xinput.CnamesDesignVariable;
for ndv=1:Xop.Xinput.NdesignVariables
    if isinf(Xop.Xinput.XdesignVariable.(CnameDV{ndv}).lowerBound)
        error('OpenCossan:StochasticRanking',...
            'The design variables must be bounded. The lower bound of %s is -Infinity',CnameDV{ndv})
    elseif isinf(Xop.Xinput.XdesignVariable.(CnameDV{ndv}).upperBound)
        error('OpenCossan:StochasticRanking',...
            'The design variables must be bounded. The upper bound of %s is Infinity',CnameDV{ndv})
    else
        Mlowerupper(1,ndv)=Xop.Xinput.XdesignVariable.(CnameDV{ndv}).lowerBound;
        Mlowerupper(2,ndv)=Xop.Xinput.XdesignVariable.(CnameDV{ndv}).upperBound;
    end
end

assert(~isempty(Xop.Xconstraint),...
    'OpenCossan:StochasticRanking:apply',...
    strcat('It is not possible to apply StochasticRanking to solve UNCONSTRAINED problem\n'),...
    'Use unconstrained EvolutionStrategy instead.')

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
    % Create handle of the objective function
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor);
else
    hobjfun=@(x)evaluate(Xop.XobjectiveFunction,'Xoptimizationproblem',Xop,...
        'MreferencePoints',x,'Lgradient',false,...
        'scaling',Xobj.scalingFactor,'Xmodel',Xop.Xmodel);
end

% Create handle for the constrains
hconstraint=@(x)evaluate(Xop.Xconstraint,'Xoptimizationproblem',Xop,...
    'MreferencePoints',x,'Lgradient',false,...
    'scaling',Xobj.scalingFactor);

%% Perfom the optimization
OpenCossan.setLaptime('Sdescription',['SRES:' Xobj.Sdescription]);

[XoptGlobal.VoptimalDesign,Stats,Gm] = Xobj.sres(hobjfun,hconstraint,'min',Mlowerupper,Xobj.Nlambda,Xobj.Nmax,Xobj.Nmu,Xobj.probWin,1);
%%
XoptGlobal.VoptimalScores=Stats(Gm,1);

% Other terminations to be implemented! Need modification of sres.m
OpenCossan.cossanDisp(['Exit Flag: ' XoptGlobal.Sexitflag],2)


OpenCossan.setLaptime('Sdescription','End SRES optimization');


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

%% Export results and clean up
% Export Optimum
Xoptimum    = XoptGlobal;
% Export Simulation Output
varargout{1}    = XsimOutGlobal;
% Delete global variables
clear global XoptGlobal XsimOutGlobal

%% Record Time
OpenCossan.setLaptime('Sdescription',['End apply@' class(Xobj)]);

end