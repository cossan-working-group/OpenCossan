function varargout = deleteJob(Xobj,varargin)
%
%   submit a job to a job manager
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================


%% Process optional inputs
% NOTE: all the optional input parameters are properties of the jobmanager
% object
%

OpenCossan.validateCossanInputs(varargin{:})

for iopt=1:2:length(varargin)
    switch lower(varargin{iopt})
        case {'csjobid'}
            CSjobID = varargin{iopt+1};                   
        otherwise
            error('openCOSSAN:JobManager:deleteJob',...
                ['PropertyName ' varargin{iopt} ' not allowed']);
    end
end

for n=1:length(CSjobID)
    if ~isempty(CSjobID{n})
        if ~OpenCossan.hasSSHConnection
            [~,CSstatus{n}]=system([Xobj.Xjobmanagerinterface.SdeleteJob ' ' CSjobID{n}]); %#ok<AGROW>
        else
            [~,CSstatus{n}]=OpenCossan.issueSSHcommand([Xobj.Xjobmanagerinterface.SdeleteJob ' ' CSjobID{n}]); %#ok<AGROW>
        end
        OpenCossan.cossanDisp(['Job ' CSjobID{n} ' canceled: ' CSstatus{n}],1)
    end
end



if nargout>0
    varargout{1}=CSstatus;
end

end

