function  Nslots = getSlotNumber(Xobj,varargin)
% Get the names of the host from the system command used to query the
% available queues
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'shostname'
            ShostName = varargin{k+1};
        case 'squeuename'
            SqueueName = varargin{k+1};
        otherwise
            error('openCOSSAN:JobManagerInterface:checkHost',...
                ['PropertyName name (' varargin{k} ') not allowed']);
    end
end

assert(logical(exist('SqueueName','var')), 'openCOSSAN:JobManagerInterface:getSlotNumber',...
    'It is mandatory to specify SqueueName')

Nslots=0;

if strcmpi(Xobj.Stype,'gridengine')
    [XdocGrid ~] = Xobj.getXmlObject;
    
    XhostList = XdocGrid.getElementsByTagName('host');
    
    % check that the specified host is available in the selected queue
    if exist('ShostName','var')
        Ohost = JobManagerInterface.locGetElementWithName(XhostList, ShostName);
        
        assert(~isempty(Ohost),'openCOSSAN:JobManagerInterface:getSlotNumber',...
            'The hostname "%s" does not exist in the queue "%s"',ShostName,SqueueName)
        
        Xnode = Ohost.getElementsByTagName('queue');
        if Xnode.getLength>0
            Xqueue = JobManagerInterface.locGetElementWithName(Xnode, SqueueName);
            if ~isempty(Xqueue)
                Xslot=JobManagerInterface.locGetElementWithName(Xqueue.getElementsByTagName('queuevalue'), 'slots');
                Sslots=Xslot.getTextContent();
                Nslots=Nslots+str2double(Sslots);
            end
        end
        
    else
        % retrieve all the slots available in the queue
        for j=0:XhostList.getLength - 1; % loop over the hosts
            Xnode = XhostList.item(j).getElementsByTagName('queue');
            if Xnode.getLength>0
                Xqueue = JobManagerInterface.locGetElementWithName(Xnode, SqueueName);
                
                if ~isempty(Xqueue)
                    Xslot=JobManagerInterface.locGetElementWithName(Xqueue.getElementsByTagName('queuevalue'), 'slots');
                    Sslots=Xslot.getTextContent();
                    Nslots=Nslots+str2double(Sslots);
                end
            end
        end
    end
    
elseif strcmpi(Xobj.Stype,'lsf')
    % check that the specified host is available in the selected queue
    Chosts = Xobj.getHosts('SqueueName',SqueueName);
    Thosts = Xobj.getLSFHostsInfo();
    if exist('ShostName','var')
        assert(any(strcmpi(Chosts,ShostName)),'openCOSSAN:JobManagerInterface:getSlotNumber',...
            'The hostname "%s" does not exist in the queue "%s"',ShostName,SqueueName)
        selected_host = strcmpi({Thosts.HOSTNAME},ShostName);
        Nslots = str2double(Thosts(selected_host).MAX);
    else
        % retrieve all the slots available in the queue
        for ihost = 1:length(Chosts)
            selected_host = strcmpi({Thosts.HOSTNAME},Chosts{ihost});
            Nslots = Nslots + str2double(Thosts(selected_host).MAX);
        end
    end
end

return
