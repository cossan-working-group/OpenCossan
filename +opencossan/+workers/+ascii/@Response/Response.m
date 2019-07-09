classdef Response
    % Class RESPONSE
    %
    % Objects of this class contain information for Extractor to find data
    % to extract inside an ASCII output file. Each Response object
    % identifies a COSSAN output.
    
    properties
        Sdescription           % Description of the object
        Sname = ''             % Name of the associate COSSAN output
        Sfieldformat = '%e'  % Format string '%' +  Maximum field width + conversion character (see fscanf for more information)
        Clookoutfor = {}       % if present define the string to be searched inside the ASCII file in order to define the relative position
        Svarname = ''          % if present Vcolnum and Vrownum are relative respect to the variable present in Svarname
        Sregexpression = ''    % Regular expression
        Ncolnum= 1             % Colum position in the ASCII file of the variables (length(Vcolnum)=Nresponse)
        Nrownum= 1             % Row position in the ASCII file of the variables (length(Vcolnum)=Nresponse)
        Nrepeat= 1             % Repeat the extraction of the value Nrepeat times
        LoutputInColumns = true
        VcoordIndex = []
        CSindexName = {}
    end
    
    properties (Dependent=true)        
        Ndata
        Nrows
    end
    
    methods
        
        function Xobj = Response(varargin)
            % Constructor Response object
            %
            %   Arguments:
            %   ==========
            %
            %   MANDATORY ARGUMENTS: -
            %                           if no arguments are passed to the extractor
            %                           constructor an empty object is created
            %
            %   - Sname:           Name of the associate COSSAN variables
            %   - Sfieldformat:    Format of the value to be read (as in MATLAB format string)
            %   - Clookoutfor:     if present define the string to be searched inside
            %                      the ASCII file in order to define the relative position  Format string
            %                      It can be a cell array
            %   - Svarname:        If present Ncolnum and Nrownum are relative respect to the
            %                      variable present in Cvarname
            %   - Ncolnum:         Colum position in the ASCII file of the variables
            %   - Nrownum:         Row position in the ASCII file of the variables
            %   - Sregexpression:  Regular expression
            %   - Nrepeat:         Repeat the extraction of values Nrepeat times
              
            %%  Argument Check
            opencossan.OpenCossan.validateCossanInputs(varargin{:});
            
            if nargin==0
                return
            end
            
            %% Setting property values
            for k = 1:2:length(varargin)
                switch(lower(varargin{k}))
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case 'sname'
                        Xobj.Sname=varargin{k+1};
                    case {'sfieldformat','sformat'}
                        Xobj.Sfieldformat=varargin{k+1};
                    case 'clookoutfor'
                        Xobj.Clookoutfor=varargin{k+1};
                    case 'svarname'
                        Xobj.Svarname=varargin{k+1};
                    case 'sregexpression'
                        Xobj.Sregexpression=varargin{k+1};
                    case {'ncolnum','ncol'}
                        Xobj.Ncolnum=varargin{k+1};
                    case {'nrownum','nrow'}
                        Xobj.Nrownum=varargin{k+1};
                    case 'nrepeat'
                        Xobj.Nrepeat=varargin{k+1};
                    case 'loutputincolumns'
                        Xobj.LoutputInColumns=varargin{k+1};
                    case 'vcoordindex'
                        Xobj.VcoordIndex=varargin{k+1};
                    otherwise
                        warning('openCOSSAN:Response:Response',['PropertyName ' varargin{k} ' has been ignored'])
                end
                
            end
                    
            if isempty(Xobj.Sname)
                error('openCOSSAN:Response:Response', ...
                    'Mandatory property Sname (name of the output) must be passed to the Response constructor.')
            end
            
            if isempty(Xobj.CSindexName)
                if ~isempty(Xobj.VcoordIndex)
                    Nindex = length(Xobj.VcoordIndex);
                else
                    Nindex = Xobj.Nrows;
                end
                Xobj.CSindexName = repmat({''},1,Nindex);
            end
            assert(length(Xobj.CSindexName)==Xobj.Nrows-length(Xobj.VcoordIndex),...
                'openCOSSAN:Response:Response',...
                ['The number of elements of CSindexName (' ...
                num2str(length(Xobj.CSindexName)) ') is not coherent with '...
                'the dimension of the data to be extracted (' num2str(Xobj.Nrows) ')'])
        end %end constructor
        
        disp(Xobj)
        
        function Nout = getOutputNrFromFormat(Xobj)
            Nout = length(strfind(Xobj.Sfieldformat,'%')) - ...
                length(strfind(Xobj.Sfieldformat,'%*'));
        end
        
        Xds = createDataseries(Xobj,Moutput)

        function Ndata = get.Ndata(Xobj)
            if Xobj.LoutputInColumns
                Ndata = Xobj.Nrepeat;
            else
                Ndata = Xobj.getOutputNrFromFormat;
            end
        end
        
        function Nrows = get.Nrows(Xobj)
            if Xobj.LoutputInColumns
                Nrows = Xobj.getOutputNrFromFormat;
            else
                assert(~isinf(Xobj.Nrepeat),'openCOSSAN:Response',...
                    'Nrepeat must be finite when the outputs are stored in rows.')
                Nrows = Xobj.Nrepeat;
            end
        end
        
    end
    
end
