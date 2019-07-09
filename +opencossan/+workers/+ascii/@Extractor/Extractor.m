classdef Extractor
    % Class EXTRACTOR
    %
    % Object of class Extractor are used to extract quantities of interest
    % from an ASCII file containing the output of a FE code.
    % These objects create a "link" between an ASCII output file and the
    % COSSAN output objects, with the paradigm "one object, one file".
    % The informations on the quantities to be extracted are stored using
    % object of the class Response, that are passed to the constructor.
    
    properties
        Lverbose=false          % Display additional information
        Sdescription = ''       % Description of the connector
        Srelativepath = ''      % path of the output file
        Sfile                   % name of the output file     
        Sworkingdirectory = ''  % directory where the FE simulation is performed - set by Connector
        Xresponse               % Array of Response objects
    end
    
    properties (Dependent=true)
        Nresponse               % Number of responses extracted
        Coutputnames            % Names of the extracted quantities of interest
    end
    
    properties (Hidden,SetAccess=protected)
        Soutputname             % TODO write comment
    end
    
    methods
        function Xobj = Extractor(varargin)
            % Constructor Extractor object
            %
            %   Arguments:
            %   ==========
            %
            %   MANDATORY ARGUMENTS: -
            %                           if no arguments are passed to the extractor
            %                           constructor an empty object is created
            %
            %   OPTIONAL ARGUMENTS:
            %   - Sdescription: description of the Extractor
            %   - Srelativepath:        path of the ASCII output file
            %   - Sfile:        name of the ASCII output file
            %   - Xresponse:    array of response Objects
            %
            %   EXAMPLES:
            %   Usage:
            %
            %     Xresp = Response('Sname','X1',Sfieldformat,'%8e');
            %
            %     Xe  = extractor('Sdescription','extractor Object',  ...
            %                     'Sfile','output.txt','Srelativepath','./', ...
            %                     'Xresponse',Xresp);
            %
            % =====================================================
            % COSSAN - COmputational Stochastic Structural Analysis
            % IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
            % Copyright 1993-2008 IfM
            % =====================================================
            %
            %   see also: apply_evaluator, connector, injector
            
            %% 1. Processing Inputs
            
            % Process all the optional arguments and assign them the corresponding
            % default value if not passed as argument
            
            if rem(length(varargin),2)~=0 % TODO: error(identifier,messages)
                error('openCOSSAN:Extractor:Extractor','The optional parameters must be passed an pair (name,value)');
            end
            opencossan.OpenCossan.validateCossanInputs(varargin{:});
            
            %% Set options
            for iVopt=1:2:length(varargin)
                switch lower(varargin{iVopt})
                    case 'lverbose'
                        Xobj.Lverbose = varargin{iVopt + 1};
                    case 'sdescription'
                        Xobj.Sdescription = varargin{iVopt + 1};
                    case 'srelativepath'
                        Xobj.Srelativepath = varargin{iVopt + 1};
                    case 'sworkingdirectory'
                        Xobj.Sworkingdirectory = varargin{iVopt + 1};
                    case 'sfile'
                        Xobj.Sfile = varargin{iVopt + 1};
                    case 'xresponse'
                        Xobj.Xresponse = varargin{iVopt + 1};
                    case 'cxresponse'
                        for n=1:length(varargin{iVopt + 1})
                            if ~isa(varargin{iVopt + 1}{n},'opencossan.workers.ascii.Response')
                                error('openCOSSAN:Extractor','CXresponse must be a cell array contain Response objects only')
                            end
                            tmp(n) = varargin{iVopt + 1}{n};
                        end
                        Xobj.Xresponse=tmp;
                    case 'ccxresponse'
                        for n=1:length(varargin{iVopt + 1})
                            if (length(varargin{iVopt + 1}{n})~=1)
                                error('openCOSSAN:Extractor','CCXresponse must be a cell array contain 1x1 cellarrays, containing a Response objects only')
                            end
                            if ~isa(varargin{iVopt + 1}{n},'cell')
                                error('openCOSSAN:Extractor','CCXresponse must be a cell array contain 1x1 cellarrays, containing a Response objects only')
                            end
                            if ~isa(varargin{iVopt + 1}{n}{1},'opencossan.workers.ascii.Response')
                                error('openCOSSAN:Extractor','CCXresponse must be a cell array contain 1x1 cellarrays, containing a Response objects only')
                            end
                            tmp(n) = varargin{iVopt + 1}{n}{1};
                        end
                        Xobj.Xresponse=tmp;
                    case {'sname','sfieldformat','clookoutfor','svarname',...
                            'sregexpression','ncolnum','nrownum','nrepeat'}
                        error('openCOSSAN:Extractor','Passing response information to Extractor constructor is deprecated and has been discontinued.\n Please pass a Response object instead')
                    otherwise
                        error('openCOSSAN:Extractor',['Unknown property: ' varargin{iVopt}])
                end
            end
            
            % set Sworking directory to the cossan working directory if
            % empty
            
            % Check if an output is present more than once in the Extractor
            Lerror = false;
            Serrorstring = '';
            for i=1:Xobj.Nresponse
                for j=i+1:Xobj.Nresponse
                    if strcmpi(Xobj.Xresponse(j).Sname,Xobj.Xresponse(i).Sname)
                        Serrorstring = [Serrorstring ' -  ' Xobj.Xresponse(i).Sname ...
                            ' is present in response ' num2str(i) ' and ' num2str(j) '\n'];
                        Lerror = true;
                    end
                end
            end
            if Lerror
                error('openCOSSAN:Extractor:Extractor',['Duplicated output names defined in Extractor:\n' Serrorstring])
            end
            
            if ~isempty(Xobj.Srelativepath) 
                if~(strcmp(Xobj.Srelativepath(end),filesep)) % add / or \ at the end of the path
                    Xobj.Srelativepath  = [Xobj.Srelativepath filesep];
                end
            end
            
        end %end constructor
        
        
        Xextractor = remove(Xextractor,Svarname)
        [Tout, LsuccessfullExtract] = extract(Xe,varargin)
        disp(Xe)
        Xextractor = add(Xextractor,varargin)
        
        function Nresponse = get.Nresponse(Xobj)
            Nresponse = length(Xobj.Xresponse);
        end % Nresponse get method
        
        function Coutputnames = get.Coutputnames(Xobj)
            if isempty(Xobj.Soutputname)
                
                Coutputnames = cell(Xobj.Nresponse,1);
                for ires=1:Xobj.Nresponse
                    Coutputnames{ires}=Xobj.Xresponse(ires).Sname;
                end
            else
                Coutputnames={Xobj.Soutputname};
            end
        end % Coutputnames get method
        
        function Xobj = set.Soutputname(Xobj,Soutputname)
            Xobj.Soutputname = Soutputname;
        end % Coutputnames set method
        
    end
    
end

