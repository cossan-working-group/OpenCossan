function Cnames = getHosts(Xobj,varargin)
% Get the names of the queues from the system command used to query the
% available queues
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================


OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'squeuename'
            SqueueName = varargin{k+1};
        otherwise
            error('openCOSSAN:JobManagerInterface:getHosts',...
                ['PropertyName name (' varargin{k} ') not allowed']);
    end
end

if strcmpi(Xobj.Stype,'gridengine')
    %% GridEngine
    parserFactory = javaMethod('newInstance',...
        'javax.xml.parsers.DocumentBuilderFactory');
    
    javaMethod('setValidating',parserFactory,0);
    %javaMethod('setIgnoringElementContentWhitespace',parserFactory,1);
    %ignorable whitespace requires a validating parser and a content model
    p = javaMethod('newDocumentBuilder',parserFactory);
    
    inputSource = org.xml.sax.InputSource(java.io.StringReader(Xobj.SgridXML));
    
    Xdoc = p.parse(inputSource);
    
    XhostList = Xdoc.getElementsByTagName('host');
    
    Cnames=cell(XhostList.getLength,1);
    
    for n=0:XhostList.getLength-1
        % Remember that in all other languages the first element has index 0
        Cnames(n+1)=XhostList.item(n).getAttribute('name');
    end
    
    % The following matlab method change the order of the values!!!
    %Cnames=unique(Cnames);
    
    if exist('SqueueName','var')
        Lstatus=false(length(Cnames),1);
        
        
        for j=0:XhostList.getLength - 1; % loop over the hosts
            Xnode = XhostList.item(j).getElementsByTagName('queue');
            if Xnode.getLength>0
                Xqueue = JobManagerInterface.locGetElementWithName(Xnode, SqueueName);
                if ~isempty(Xqueue)
                    Lstatus(j+1)=true;
                end
            end
            
        end
        
        Cnames=Cnames(Lstatus);
    end
    
elseif strcmpi(Xobj.Stype,'lsf')
    %% LSF
    if ~exist('SqueueName','var') % query all the hosts
        [~,Cnames] = getLSFHostsInfo(Xobj);
    else % query the hosts of a specific queue
        % query the queues of the cluster
        if ~OpenCossan.hasSSHConnection
            [status,Sout] = system(Xobj.SqueryQueues);
        else
            [status,Sout] = OpenCossan.issueSSHcommand(Xobj.SqueryQueues);
        end
        
        assert(status == 0, 'openCOSSAN:JobManagerInterface:getHosts',...
            'Error querying the cluster queues status')
    
        Clines=strsplit(Sout,'\n');
        
        % find where the list of the proeprties of a queue begins
        queueline = find(~cellfun(@isempty,strfind(Clines,'QUEUE:')));
        
        Cqueuenames = Xobj.getQueues();
        % keep only the lines relevant to the selected queue name
        iselectedline = find(strcmp(Cqueuenames,SqueueName));
        assert(~isempty(iselectedline),'openCOSSAN:JobManagerInterface:getHosts',...
            ['Unknown queue name: ' SqueueName]);
        if iselectedline ~= length(Cqueuenames)
            Clines = Clines(queueline(iselectedline):queueline(iselectedline+1)-1);
        else
            Clines = Clines(queueline(iselectedline):end);
        end
        
        % find where the list of the proeprties of a queue begins
        hostline = find(~cellfun(@isempty,strfind(Clines,'HOSTS:')));
        
        Cnames = strsplit(strtrim(strrep(Clines{hostline},'HOSTS:','')))';
        
        if strcmp(Cnames{1},'all')
            [~,Cnames] = getLSFHostsInfo(Xobj);
        end
    end
end

end

