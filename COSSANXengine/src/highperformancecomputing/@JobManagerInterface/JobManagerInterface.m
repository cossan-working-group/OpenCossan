classdef JobManagerInterface
    %JobManagerInterface  Class JobManagerInterface
    % This class provides a interface between COSSAN-X and JobScheduling
    % managers
    
    properties
        Sdescription    % Description of the JobManagerInterface
        SsubmitJob      % Submit job command
        SdeleteJob      % Delete job command
        SqueryJob       % Query the get job status (in XML format for GridEngine)
        SqueryGrid      % Query the cluster status (in XML format for GridEngine)
        SqueryQueues    % Query the queues status (in XML format for GridEngine)
        SqueryPE        % Query the parallel environment list
        SMCRpreexec     % Preexecution commands for Matlab Component Runtime
        SMCRpostexec    % Postexecution commands for Matlab Component Runtime
        SMCRpath        % Path of the MCR (Used by remote machines)
    end
    
    
    properties (Dependent)
        SjobsXML    % XML data of job status
        SgridXML    % XML data of grid configuration
        Stype       % Type of job manager program 
    end
    
    
    methods
        %% constructor
        function Xobj=JobManagerInterface(varargin)
            %  The JobManagerInterface constructor create a JobManagerInterface object.
            %   The method takes a variable number of token value pairs.  These
            %   pairs set the fields of the JobManagerInterface object.
            %
            %  The constructor returns the JobManagerInterface object.
            %
            % ==================================================================
            % COSSAN-X - The next generation of the computational stochastic analysis
            % University of Innsbruck, Copyright 1993-2011 IfM
            % ==================================================================
            
            if nargin==0
                return
            end
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'stype'
                        % Use predefined configuration
                        Stype = varargin{k+1};
                    case 'sdescription'
                        Xobj.Sdescription = varargin{k+1};
                    case 'ssubmitjob'
                        Xobj.SsubmitJob = varargin{k+1};
                    case 'sdeletejob'
                        Xobj.SdeleteJob = varargin{k+1};
                    case 'squeryjob'
                        Xobj.SqueryJob = varargin{k+1};
                    case 'squerygrid'
                        Xobj.SqueryGrid = varargin{k+1};
                    case 'squeryqueues'
                        Xobj.SqueryQueues = varargin{k+1};
                    case 'squerype'
                        Xobj.SqueryPE = varargin{k+1};
                    case 'smcrpreexec'
                        Xobj.SMCRpreexec = varargin{k+1};
                    case 'smcrpostexec'
                        Xobj.SMCRpostexec = varargin{k+1};
                    case 'smcrpath'
                        Xobj.SMCRpath = varargin{k+1};
                    otherwise
                        error('openCOSSAN:JobManagerInterface',...
                            ['PropertyName name (' varargin{k} ') not allowed']);
                end
            end
            
            %% Set the properties for the selected Stype
            if exist('Stype','var')
                
                switch lower(Stype)
                    case ('gridengine')
                        Xobj = gridengine(Xobj);
                    case {'gridengine_matlab'}
                        Xobj = gridengine_matlab(Xobj);
                    case {'lsf','openlava'}
                        Xobj = lsf(Xobj);
                    case {'lsf_matlab','openlava_matlab'}
                        Xobj = lsf_matlab(Xobj);
                    otherwise
                        error('openCOSSAN:JobManagerInterface:JobManagerInterface',  ...
                            ['Pre-defined jobManagerInterface configuration ('  Stype ') not available']);
                end
            end
 		
	    if isempty(Xobj.SqueryQueues) && strcmpi(Xobj.SsubmitJob,'bsub') 
                % quick fix to have lsf working, to be removed after gui fix
                Xobj.SqueryQueues = 'bqueues -l';
            end

%             if isempty(Xobj.SqueryQueues) && strcmpi(Xobj.SsubmitJob,'bsub') 
%                 % quick fix to have lsf working, to be removed after gui fix
%                 Xobj.SqueryQueues = 'bqueues -l';
%             end
        end
        
        display(Xobj)
        
        % Methods to retrieve information from grid
        Cmembers = getQueues(Xobj); % Get Queues names
        Cmembers = getHosts(Xobj,varargin);  % Get Hosts names
        Cmembers = getParallelEnvironments(Xobj); % Get available PE configurations
        
        % Methods to check the status of the gris
        [Lavailable, Sstatus] = checkHost(Xobj,varargin)
        Cstatus = getJobStatus(Xobj,varargin) % Get Job ID and status
        Nslot = getSlotNumber(Xobj,varargin)
        Nslot = getSlotNumberAvailable(Xobj,varargin)
        
        function SjobsXML = get.SjobsXML(Xobj)
            
            if ~OpenCossan.hasSSHConnection
                [status,SjobsXML] = system(Xobj.SqueryJob);
            else
                [status,SjobsXML] = OpenCossan.issueSSHcommand(Xobj.SqueryJob);
            end
            SjobsXML(1:strfind(SjobsXML,'<?')-1)=[];  
            
            assert(status==0, 'openCOSSAN:JobManagerInterface', ...
                'Error retrieving job status from the job manager');
        end
        
        function SgridXML = get.SgridXML(Xobj)
            
            if ~OpenCossan.hasSSHConnection
                [status,SgridXML] = system(Xobj.SqueryGrid);
            else
                [status,SgridXML] = OpenCossan.issueSSHcommand(Xobj.SqueryGrid);
            end
            SgridXML(1:strfind(SgridXML,'<?')-1)=[];  
   
            assert(status==0, 'openCOSSAN:JobManagerInterface', ...
                'Error retrieving grid configuration from the job manager');
        end
        
        function Stype = get.Stype(Xobj)
            if strcmpi(Xobj.SsubmitJob,'qsub')
                Stype = 'GridEngine';
            elseif strcmpi(Xobj.SsubmitJob,'bsub')
                Stype = 'LSF';
            else
                % this error should never be reached, but is kept in case the user
                % manually alter the property SsubmitJob of JobManagerInterface
                error('openCOSSAN:JobManagerInterface',...
                    ['Unsupported submission command: ' Xobj.SsubmitJob]) 
            end
        end
        
    end
    
    methods (Access=private)
        function Xobj = gridengine(Xobj)
            if isempty(Xobj.Sdescription)
                Xobj.Sdescription='Oracle Grid Engine ';
            end
            Xobj.SsubmitJob='qsub';
            Xobj.SdeleteJob='qdel';
            Xobj.SqueryJob=  'qstat -s a  -xml';
            Xobj.SqueryGrid= 'qhost -q -xml';
            Xobj.SqueryQueues= 'qhost -q -xml';
            Xobj.SqueryPE= 'qconf -spl';
            
        end
                
        function Xobj = lsf(Xobj)
            if isempty(Xobj.Sdescription)
                Xobj.Sdescription='LSF/OpenLava';
            end
            Xobj.SsubmitJob='bsub'; % this is the way LSF takes input from a script file!
            Xobj.SdeleteJob='bkill';
            Xobj.SqueryJob=  'bjobs -adw'; % this command must return all the recent jobs
            Xobj.SqueryGrid= 'bhosts -l;';
            Xobj.SqueryQueues= 'bqueues -l';
            Xobj.SqueryPE= ''; % there are no PE in LSF
            
        end
        
        function Xobj = gridengine_matlab(Xobj)
            Xobj = gridengine(Xobj);
            Xobj = getMCRproperties(Xobj);
        end
        
        function Xobj = lsf_matlab(Xobj)
            Xobj = lsf(Xobj);
            Xobj = getMCRproperties(Xobj);
        end
        
        function Xobj = getMCRproperties(Xobj)
            [Nmajor, Nminor]=mcrversion;
            Xobj.SMCRpath=['/usr/software/matlab/MATLAB_Compiler_Runtime/v' ...
                num2str(Nmajor) num2str(Nminor)];
            
            % define the location, unique to job and create the cache space for the
            % MATLAB Compiler Runtime (MCR)
            Xobj.SMCRpreexec='export MCR_CACHE_ROOT=/tmp/mcr_cache_$JOB_ID; mkdir -p $MCR_CACHE_ROOT; ';
            Xobj.SMCRpostexec='rm $MCR_CACHE_ROOT -Rf';
        end
        
        function [XdocGrid, XdocJobs] = getXmlObject(Xobj)
            % Move to private function
            parserFactory = javaMethod('newInstance',...
                'javax.xml.parsers.DocumentBuilderFactory');
            
            javaMethod('setValidating',parserFactory,0);
            %javaMethod('setIgnoringElementContentWhitespace',parserFactory,1);
            %ignorable whitespace requires a validating parser and a content model
            p = javaMethod('newDocumentBuilder',parserFactory);
            
            % Get Grid Configuration
            % preprocess the XML string. Because of a bug of GridEngine, the string
            % sometimes start with an empty line instead of starting with "<?xml version='1.0'?>"
            % This causes a crash in the parser, so everything before "<?" should
            % just be ignored
            SXMLstring  = Xobj.SgridXML;
            SXMLstring(1:strfind(SXMLstring,'<?')-1)=[];            
            inputSource = org.xml.sax.InputSource(java.io.StringReader(SXMLstring));
            XdocGrid = p.parse(inputSource);
            
            % Get Jobs status
            SXMLstring  = Xobj.SjobsXML;
            SXMLstring(1:strfind(SXMLstring,'<?')-1)=[];
            inputSource = org.xml.sax.InputSource(java.io.StringReader(SXMLstring));
            XdocJobs = p.parse(inputSource);
        end
        
        [Thosts, Cnames] = getLSFHostsInfo(Xobj)
        
    end
    
    methods (Access=private,Static)
        function element=locGetElementWithName(nodelist, Sname)
            element=[];
            size = nodelist.getLength - 1;
            for n=0:size
                if (strcmp(nodelist.item(n).getAttribute('name'), Sname))
                    element = nodelist.item(n);
                end
            end
        end
        
    end
end
