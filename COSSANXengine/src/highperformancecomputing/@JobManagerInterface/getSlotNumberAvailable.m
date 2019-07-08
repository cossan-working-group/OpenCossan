function NslotsAvailable = getSlotNumberAvailable(Xobj,varargin)
% Get the names of available hosts from the required host or queue
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

Nslots=Xobj.getSlotNumber(varargin{:});
NslotsUsed=0;

if strcmpi(Xobj.Stype,'gridengine')
    [XdocGrid, ~] = Xobj.getXmlObject;
    
    XhostList = XdocGrid.getElementsByTagName('host');
    
    if exist('ShostName','var')
        % get the number of used slots for the specific host
        Ohost = JobManagerInterface.locGetElementWithName(XhostList, ShostName);
        Xnode = Ohost.getElementsByTagName('queue');
        if Xnode.getLength>0
            Xqueue = JobManagerInterface.locGetElementWithName(Xnode, SqueueName);
            if ~isempty(Xqueue)
                Jslot=JobManagerInterface.locGetElementWithName(Xqueue.getElementsByTagName('queuevalue'), 'state_string');
                if length(Jslot.getTextContent())==0 %#ok<*ISMT> % isempty does not work with Java objects
                    JslotUsed=JobManagerInterface.locGetElementWithName(Xqueue.getElementsByTagName('queuevalue'), 'slots_used');
                else
                    JslotUsed=JobManagerInterface.locGetElementWithName(Xqueue.getElementsByTagName('queuevalue'), 'slots');
                end
                
                Sslots=JslotUsed.getTextContent();
                NslotsUsed=NslotsUsed+str2double(Sslots);
            end
        end
        
    else
        % get the number of used slots in the selected queue
        for j=0:XhostList.getLength - 1; % loop over the hosts
            Xnode = XhostList.item(j).getElementsByTagName('queue');
            if Xnode.getLength>0
                Xqueue = JobManagerInterface.locGetElementWithName(Xnode, SqueueName);
                if ~isempty(Xqueue)
                    Jslot=JobManagerInterface.locGetElementWithName(Xqueue.getElementsByTagName('queuevalue'), 'state_string');
                    if length(Jslot.getTextContent())==0 % isempty does not work with Java objects
                        JslotUsed=JobManagerInterface.locGetElementWithName(Xqueue.getElementsByTagName('queuevalue'), 'slots_used');
                    else
                        JslotUsed=JobManagerInterface.locGetElementWithName(Xqueue.getElementsByTagName('queuevalue'), 'slots');
                    end
                    
                    Sslots=JslotUsed.getTextContent();
                    NslotsUsed=NslotsUsed+str2double(Sslots);
                end
            end
        end
        
    end
elseif strcmpi(Xobj.Stype,'lsf')
    Chosts = Xobj.getHosts('SqueueName',SqueueName);
    Thosts = Xobj.getLSFHostsInfo();
    if exist('ShostName','var')
        % get the number of used slots for the specific host
        selected_host = strcmpi({Thosts.HOSTNAME},ShostName);
        NslotsUsed = str2double(Thosts(selected_host).NJOBS);
    else
        % get the number of used slots in the selected queue
        for ihost = 1:length(Chosts)
            selected_host = strcmpi({Thosts.HOSTNAME},Chosts{ihost});
            NslotsUsed = NslotsUsed + str2double(Thosts(selected_host).NJOBS);
        end
    end
end

NslotsAvailable=Nslots-NslotsUsed;

return

