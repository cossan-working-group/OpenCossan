function [Lavailable, Sstatus] = checkHost(Xobj,varargin)
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

Lavailable=true;
Sstatus='';

[XdocGrid ~] = Xobj.getXmlObject;


Xhosts = XdocGrid.getElementsByTagName('host');


Ehost = JobManagerInterface.locGetElementWithName(Xhosts, ShostName);

if isempty(Ehost)
    Lavailable=false;
    Sstatus=['The hostname ' ShostName ' is not present in the grid'];
    return
end

% Check if the host is present in the specified the queue

if exist('SqueueName','var')
    Xqueues = Ehost.getElementsByTagName('queue');
    
    
    Equeue = JobManagerInterface.locGetElementWithName(Xqueues, SqueueName);
    
    if isempty(Equeue)
        Lavailable=false;
        Sstatus=['The queue ' SqueueName ' is not available on host ' ShostName];
    end
    
    
end
end





