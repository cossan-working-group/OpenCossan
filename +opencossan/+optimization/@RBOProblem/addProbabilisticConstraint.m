function Xrbop    = addProbabilisticConstraint(Xrbop,varargin)
%addProbabilisticConstraint  add probabilistic contraint to the object 
%
%   This method is specially design for defining constraints that
%   depend on probability terms of the form:
%       P <= P_threshold
%   where "P" is the probability of occurrence of a certain event and
%   "P_threshold" is the maximum tolerable failure probability.
%
%
%   MANDATORY ARGUMENTS:
%   - Xrbop   : RBOProblem object
%   - ProbabilisticModel    : an object of the class ProbabilisticModel
%   that is associated with the target probability
%   - Simulations           : an object of the class Simulations that is
%   used for calculating the probability
%   - TolerableProbability  : tolerable probability of occurrence
%
%   OPTIONAL ARGUMENTS:
%
%   OUTPUT ARGUMENTS:
%   -  Xrbop  : RBOProblem object
%
%   EXAMPLE:
%   XRboProblem     = addProbabilisticConstraint(XRboProblem,...
%       'ProbabilisticModel',XPM,'Simulations',XMC,...
%       'TolerableProbability',1e-3);
%
% 
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2010 IfM
% =====================================================

%% 1. Check Input
if rem(length(varargin),2)~=0
    error('openCOSSAN:RBOProblem:addProbabilisticConstraint',...
        'The parameters must be passed as pair (name,value)');
end

%% 2.   Extract input
%2.1.   Define empty variables
Xpm     = [];   %empty variable to store probabilistic model
Xsim    = [];   %empty variable to store object of the class Simulations
Nthresh = [];   %thresholod level for probability
%2.2.   Extract values
for i=1:2:length(varargin),
    switch lower(varargin{i}),
        %probabilistic model
        case {'probabilisticmodel'},
            if isa(varargin{i+1},'ProbabilisticModel'),
                Xpm     = varargin{i+1};
            else
                error('openCOSSAN:RBOProblem:addProbabilisticConstraint',...
                ['argument ' varargin{i} ' is not a ProbabilisticModel']);
            end
        %simulation method for assessing reliability    
        case {'simulations','simulationmethod','xsimulations'},
            if isa(varargin{i+1},'Simulations'),
                Xsim    = varargin{i+1};
            else
                error('openCOSSAN:RBOProblem:addProbabilisticConstraint',...
                    ['argument ' varargin{i} ' is not a Simulations']);
            end
        %threshold of probability constraint    
        case {'nthreshold','threshold','tolerableprobability'},
            if isscalar(varargin{i+1}) && isnumeric(varargin{i+1}),
                Nthresh = varargin{i+1};
            else
                error('openCOSSAN:RBOProblem:addProbabilisticConstraint',...
                    ['argument ' varargin{i} ' is not a scalar number']);
            end
        otherwise
            warning('openCOSSAN:RBOProblem:addProbabilisticConstraint',...
                ['argument ' varargin{i} ' has been ignored']);
    end
end

%% 3.   Check arguments
if isempty(Xpm) || isempty(Xsim) || isempty(Nthresh),
    error('openCOSSAN:RBOProblem:addProbabilisticConstraint',...
        'mandatory parameters are missing');
end

%% 4.   Define Function object
XFunProbCon     = Function('Sdescription','probabilistic constraint',...
    'Sexpression',[' log(subsref(pf(<&Xpm&>,''Xsimulations'',<&Xsim&>),'...
    'struct(''type'',''.'',''subs'',''pfhat''))) - '   num2str(log(Nthresh),'%e')],...
    'CUseObject',{'Xpm',Xpm},...
    'CUseObject',{'Xsim',Xsim});

%% 5.   Find out number of function
if ~isempty(Xrbop.TProbabilisticConstraint),
    N   = length(Xrbop.TProbabilisticConstraint)+1;
else
    N   = 1;
end

%% 6.   Add Objective function
Xrbop.TProbabilisticConstraint(N).XFunProbabilisticConstraint   = XFunProbCon;
Xrbop.TProbabilisticConstraint(N).XProbabilisticModel       = Xpm;
Xrbop.TProbabilisticConstraint(N).XSimulation               = Xsim;
Xrbop.TProbabilisticConstraint(N).Nthresh                   = Nthresh;

return