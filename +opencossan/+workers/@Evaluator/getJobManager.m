function Xjm = getJobManager(Xobj,varargin)
% GETJobManager  Returns the JobManager object for a specific Solver
%
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================


% Argument Check
OpenCossan.validateCossanInputs(varargin{:})

assert(nargin>1,'openCOSSAN:Evaluator:getJobManager',...
    'It is necessary to specify either the solver name (SsolverName) or the solver ID (NsolverID)')
    

% Set parameters defined by the user
for k=1:2:length(varargin),
    switch lower(varargin{k})
        case {'sname','ssolvername'}
            Ssolvername = varargin{k+1};
        case {'nsolverid'}
            NsolverID = varargin{k+1};
        otherwise
            error('openCOSSAN:Evaluator:getJobManager',...
                'PropertyName %s not valid',varargin{k});
    end
end

if ~exist('NsolverID','var')
   
    if ismember(Ssolvername,Xobj.CSnames)
        NsolverID=find(ismember(Xobj.CSnames,Ssolvername));
        
    else
        Xjm=[];
        return
    end
    
end

% Setting the JobManager
if ~isempty(Xobj.CSqueues{NsolverID})
    % Setting the connector
    Xjm=JobManager('XjobManagerInterface',Xobj.XjobInterface, ...
        'Squeue',Xobj.CSqueues{NsolverID},'Shostname',Xobj.CShostnames{NsolverID}, ...
        'SparallelEnvironment',Xobj.CSparallelEnvironments{NsolverID},...
        'Nslots',Xobj.Vslots(NsolverID),...
        'Nconcurrent',Xobj.Vconcurrent(NsolverID),...
        'Sdescription','JobManager created by Evaluator.apply');
    
else
    Xjm=[];
end



