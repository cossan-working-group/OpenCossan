function Cnames = getQueues(Xobj)
% Get the names of the queues from the system command used to query the
% available queues
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

if strcmpi(Xobj.Stype,'gridengine')
    parserFactory = javaMethod('newInstance',...
        'javax.xml.parsers.DocumentBuilderFactory');
    
    javaMethod('setValidating',parserFactory,0);
    %javaMethod('setIgnoringElementContentWhitespace',parserFactory,1);
    %ignorable whitespace requires a validating parser and a content model
    p = javaMethod('newDocumentBuilder',parserFactory);
    
    % preprocess the XML string. Because of a bug of GridEngine, the string
    % sometimes start with an empty line instead of starting with "<?xml version='1.0'?>"
    % This causes a crash in the parser, so everything before "<?" should
    % just be ignored
    try 
        SXMLstring  = Xobj.SgridXML;
    catch me
        baseException = MException('openCOSSAN:JobManagerInterface:getQueues',...
            'Error querying the cluster queues status');
        baseException=baseException.addCause(me);
        throw(baseException)
    end
        
    SXMLstring(1:strfind(SXMLstring,'<?')-1)=[];
    inputSource = org.xml.sax.InputSource(java.io.StringReader(SXMLstring));
    
    Xdoc = p.parse(inputSource);
    
    Xqueues = Xdoc.getElementsByTagName('queue');
    
    Cnames=cell(Xqueues.getLength,1);
    
    for n=1:Xqueues.getLength
        % Remember that in all other languages the first element has index 0
        Cnames(n)=Xqueues.item(n-1).getAttribute('name');
    end
    
    Cnames=unique(Cnames);
    
elseif strcmpi(Xobj.Stype,'lsf')
    %% query the queues of the cluster
    if ~OpenCossan.hasSSHConnection
        [status,Sout] = system(Xobj.SqueryQueues);
    else
        [status,Sout] = OpenCossan.issueSSHcommand(Xobj.SqueryQueues);
    end
    
    assert(status == 0, 'openCOSSAN:JobManagerInterface:getQueues',...
        'Error querying the cluster queues status')
    
    %% process the output 
    % split at the new line
    Clines=strsplit(Sout,'\n');
    % find where the list of the properties of a queue begins
    queueline = find(~cellfun(@isempty,strfind(Clines,'QUEUE:')));
    % retrieve the name of the queue
    Cnames = cell(length(queueline),1);
    for iqueue = 1:length(queueline)
        Cnames{iqueue} = strtrim(strrep(Clines{queueline(iqueue)},'QUEUE:',''));
    end
    
end

return