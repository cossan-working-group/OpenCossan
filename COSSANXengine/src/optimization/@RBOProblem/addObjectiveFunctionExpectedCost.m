function Xrbop    = addObjectiveFunctionExpectedCost(Xrbop,varargin)
%addObjectiveFunctionExpectedCost
% 
%   This method is specially designed for defining objective functions that
%   depend on probability terms of the form:
%       E[C] = c*P
%   where "E[.]" represents expectation, "C" is the cost function, "c" is
%   the unit cost and "P" is a probability.
%
%   It should be noted that if the objective function is composed by the
%   summation of two terms involving probability, i.e.:
%       E[C] = c1*P1 + c1*P1
%   it suffices invoking twice this method.
%
%   MANDATORY ARGUMENTS:
%   - Xrbop   : RBOProblem object
%   - ProbabilisticModel    : an object of the class ProbabilisticModel
%   that is associated with the target probability
%   - Simulations           : an object of the class Simulations that is
%   used for calculating the probability
%   - UnitCost              : unit cost associated with the occurrence of
%   the event associated with the definition of probability
%
%   OPTIONAL ARGUMENTS:
%
%   OUTPUT ARGUMENTS:
%   -  Xrbop  : RBOProblem object
%
%   EXAMPLE:
%   XRboProblem     = addObjectiveFunctionExpectedCost(XRboProblem,...
%       'ProbabilisticModel',XPM,'Simulations',XMC,'UnitCost',10);
%
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2010 IfM
% =====================================================

%% 1. Check Input
if rem(length(varargin),2)~=0
    error('openCOSSAN:RBOProblem:addObjectiveFunctionExpectedCost',...
        'The parameters must be passed as pair (name,value)');
end

%% 2.   Extract input
%2.1.   Define empty variables
Xpm     = [];   %empty variable to store probabilistic model
Xsim    = [];   %empty variable to store object of the class Simulations
Ncost   = [];   %empty variable to store unit cost
%2.2.   Extract values
for i=1:2:length(varargin),
    switch lower(varargin{i}),
        %probabilistic model
        case {'probabilisticmodel'},
            if isa(varargin{i+1},'ProbabilisticModel'),
                Xpm     = varargin{i+1};
            else
                error('openCOSSAN:RBOProblem:addObjectiveFunctionExpectedCost',...
                ['argument ' varargin{i} ' is not a ProbabilisticModel']);
            end
        %simulation method for assessing reliability    
        case {'simulations','simulationmethod','xsimulations'},
            if isa(varargin{i+1},'Simulations'),
                Xsim    = varargin{i+1};
            else
                error('openCOSSAN:RBOProblem:addObjectiveFunctionExpectedCost',...
                    ['argument ' varargin{i} ' is not a Simulations']);
            end
        %threshold of probability constraint    
        case {'nunitcost','ndeterministiccost','unitcost','deterministiccost'},
            if isscalar(varargin{i+1}) && isnumeric(varargin{i+1}),
                Ncost   = varargin{i+1};
            else
                error('openCOSSAN:RBOProblem:addObjectiveFunctionExpectedCost',...
                    ['argument ' varargin{i} ' is not a scalar number']);
            end
        otherwise
            warning('openCOSSAN:RBOProblem:addObjectiveFunctionExpectedCost',...
                ['argument ' varargin{i} ' has been ignored']);
    end
end

%% 3.   Check arguments
if isempty(Xpm) || isempty(Xsim) || isempty(Ncost),
    error('openCOSSAN:RBOProblem:addObjectiveFunctionExpectedCost',...
        'Mandatory parameters are missing');
end

%% 4.   Define Function object
XFunObjectiveFunc   = Function('Sdescription','objective function - expected cost',...
    'Sexpression',[num2str(Ncost,'%e') ...
    ' * (subsref(pf(<&Xpm&>,''Xsimulations'',<&Xsim&>),'...
    'struct(''type'',''.'',''subs'',''pfhat'')) )'],...
    'CUseObject',{'Xpm',Xpm},...
    'CUseObject',{'Xsim',Xsim});

%% 5.   Find out number of function
if ~isempty(Xrbop.TObjectiveFunctionExpectedCost),
    N   = length(Xrbop.TObjectiveFunctionExpectedCost)+1;
else
    N   = 1;
end

%% 6.   Add Objective function
Xrbop.TObjectiveFunctionExpectedCost(N).XFunObjectiveFuncExpCost    = XFunObjectiveFunc;
Xrbop.TObjectiveFunctionExpectedCost(N).XProbabilisticModel         = Xpm;
Xrbop.TObjectiveFunctionExpectedCost(N).XSimulation                 = Xsim;
Xrbop.TObjectiveFunctionExpectedCost(N).Ncost                       = Ncost;

return