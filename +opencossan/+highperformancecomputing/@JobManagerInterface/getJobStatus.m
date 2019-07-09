function Cstatus = getJobStatus(Xobj,varargin)
%GETJOBSTATUS This method retrieve the status of the jobs.
%
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
            CjobNumber = varargin{iopt+1};
        otherwise
            error('openCOSSAN:JobManagerInterface:getJobStatus',...
                ['PropertyName ' varargin{iopt} ' not allowed']);
    end
end

Sresults = '';

if strcmpi(Xobj.Stype,'gridengine')
    % Convert job ID
    [~, XdocJob] = Xobj.getXmlObject;
    
    Xhosts = XdocJob.getElementsByTagName('job_list');
    
    if Xhosts.getLength==0 % All job finished
        if exist('CjobNumber','var')
            Cstatus(:,2)=CjobNumber;
            % initialize variable
            Vstate=zeros(length(CjobNumber),1);
        else
            Cstatus=cell(1,2);
            return
        end
    else
        Njobs=Xhosts.getLength;
        Cstate=cell(Njobs,1);
        CjobID=cell(Njobs,1);
        
        for n=0:Njobs -1
            
            Cstate(n+1)=Xhosts.item(n).getAttribute('state');
            
            if strcmpi(Cstate{n+1},'pending')
                % if pending check that it is not in error!
                Xid=Xhosts.item(n).getElementsByTagName('state');
                Sstate = Xid.item(0).getTextContent;
                if strcmpi(Sstate,'Eqw')
                    Cstate{n+1}='Error at submission';
                end
            end
            
            Xid=Xhosts.item(n).getElementsByTagName('JB_job_number');
            CjobID(n+1)=Xid.item(0).getTextContent;
        end
        
        % Compare results with required
        if exist('CjobNumber','var')
            NrequiredJobs=length(CjobNumber);
            Cstatus=cell(NrequiredJobs,2);
            Vstate=ismember(CjobNumber,CjobID);
            VstateRP=ismember(CjobID,CjobNumber);
            if OpenCossan.getVerbosityLevel>3 && isdeployed
                disp('[openCOSSAN.JobManagerInterface.getJobStatus] Debug variables:')
                CjobNumber
                CjobID
                Vstate
                VstateRP
                Cstate
            end
            % If some jobs are already running and have been submitted from
            % somewhere else, and all the required jobs are finished, the
            % vectors Vstate and  VstateRP will be all zeros.
            % In this case, the instructions in the if block will fail. However
            % it is safe to simply move on with the check of the required jobs
            % status
            if any(VstateRP)
                Cstatus(Vstate,1)=Cstate(VstateRP);
                Cstatus(Vstate,2)=CjobID(VstateRP);
            end
        else
            % Return all pending and running jobs
            Cstatus(:,1)=Cstate;
            Cstatus(:,2)=CjobID;
            return
        end
    end
    
    %% Check status of required jobs
    for n=1:length(Vstate)
        if ~Vstate(n)
            if ~isempty(CjobNumber{n})
                if OpenCossan.hasSSHConnection
                    [~, Sresults]=OpenCossan.issueSSHcommand(['qacct -j ' CjobNumber{n}]);
                else
                    [~, Sresults]=system(['qacct -j ' CjobNumber{n}]);
                end
                % Extract status
                
                Ctoken=regexp(Sresults,'failed(.*)exit_status(.*)ru_wallclock','tokens');
                if isempty(Ctoken)
                    if strcmpi(Sresults,['error: job id ' CjobNumber{n} ' not found' 10])
                        Cstatus(n,1)={'killed'};
                    else
                        Cstatus(n,1)={Sresults};
                    end
                else
                    Nfailure=str2double(Ctoken{1}{1});
                    NexitStatus=str2double(Ctoken{1}{2});
                    if NexitStatus==0 && Nfailure==0
                        Cstatus(n,1)={'completed'};
                    else
                        Cstatus(n,1)={['Failed with status ' Ctoken{1}{2}]};
                    end
                end
                Cstatus(n,2)=CjobNumber(n);
            else
                Cstatus(n,1)={'NO job ID'};
            end
        end
    end
    
elseif strcmpi(Xobj.Stype,'lsf')
    if OpenCossan.hasSSHConnection
        [status, Sresults]=OpenCossan.issueSSHcommand(Xobj.SqueryJob);
    else
        [status, Sresults]=system(Xobj.SqueryJob);
    end
        
    if ~isempty(Sresults)
        % remove last extra new line
        Sresults(end) = '';
    end
    
    assert(status == 0, 'openCOSSAN:JobManagerInterface:getJobStatus',...
        'Error querying the cluster job status.\nError message:\n\n%s', Sresults)

    % get only ID and status from the output of the command
    Ctemp=strsplit(Sresults,'\n');
    [start_idx,~,~,Ctitles]=regexp(Ctemp{1},'\w*');
    indID = find(strcmpi(Ctitles,'JOBID'));
    indstate = find(strcmpi(Ctitles,'STAT'));
    for i=1:length(Ctemp)-1,
        CjobID{i} = strtrim(Ctemp{i+1}(start_idx(indID):start_idx(indID+1)-1));
        Cstate{i} = strtrim(Ctemp{i+1}(start_idx(indstate):start_idx(indstate+1)-1));
    end
    % LSF returns the running and pending jobs before the completed one.
    % Ensure that the returned job are ordered by the job id number.
    [~,isort]=sort(CjobID);
    CjobID = CjobID(isort);
    Cstate = Cstate(isort);
    
    % TODO: restructure the code to avoid code replication
    % Compare results with required
    if exist('CjobNumber','var')
        NrequiredJobs=length(CjobNumber);
        Cstatus=cell(NrequiredJobs,2);
        Vstate=ismember(CjobNumber,CjobID);
        VstateRP=ismember(CjobID,CjobNumber);
        if OpenCossan.getVerbosityLevel>3 && isdeployed
            disp('[openCOSSAN.JobManagerInterface.getJobStatus] Debug variables:')
            CjobNumber
            CjobID
            Vstate
            VstateRP
            Cstate
        end
        % If some jobs are already running and have been submitted from
        % somewhere else, and all the required jobs are finished, the
        % vectors Vstate and  VstateRP will be all zeros.
        % In this case, the instructions in the if block will fail. However
        % it is safe to simply move on with the check of the required jobs
        % status
        if any(VstateRP)
            Cstatus(Vstate,1)=Cstate(VstateRP);
            Cstatus(Vstate,2)=CjobID(VstateRP);
        end
    else
        % Return all pending and running jobs
        Cstatus(:,1)=Cstate;
        Cstatus(:,2)=CjobID;
        return
    end
    
end

return
