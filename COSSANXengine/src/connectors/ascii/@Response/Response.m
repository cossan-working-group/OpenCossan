classdef Response
    % Class RESPONSE
    %
    % Objects of this class contain information for Extractor to find data
    % to extract inside an ASCII output file. Each Response object
    % identifies a COSSAN output.
    
    properties
        Sdescription
        Sname = ''             % Name of the associate COSSAN output
        Sfieldformat = '%e'    % Format string '%' +  Maximum field width + conversion character (see fscanf for more information)
        Clookoutfor = {}       % if present define the string to be searched inside the ASCII file in order to define the relative position
        Svarname = ''          % if present Vcolnum and Vrownum are relative respect to the variable present in Svarname
        Ncolnum= 1             % Colum position in the ASCII file of the variables (length(Vcolnum)=Nresponse)
        Nrownum= 1             % Row position in the ASCII file of the variables (length(Vcolnum)=Nresponse)
        Nrepeat= 1             % Repeat the extraction of the value Nrepeat times
        NrepeatAnchor=1        % Repeat the extraction search of Clookoutfor NrepeatAnchor
        VcoordColumn = []       % Identify which column is used to identify the Mcoord in Dataseries
        VcoordRow = []          % Identify which row is used to identify the Mcoord in Dataseries
        CSindexName = {}
        LisMatrix=false        % If true the output from rows and colums are stored as a matrix.
                               % If false the output are concatenate in a single vector
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
            %   - Nrepeat:         Repeat the extraction of values Nrepeat
            %                      times.  
            %   - NrepeatAnchor:   Repeat the extraction of values
            %                      NrepeatAnchor using the Clookoutfor
            %   - LisMatrix        Read multiple rows (defined in Nrepeat
            %                      and NrepeatAnchor and store the results as a matrix vector)
              
            %%  Argument Check
            OpenCossan.validateCossanInputs(varargin{:});
            
            if nargin==0
                return
            end
            SfieldformatInput=[];
            
            %% Setting property values
            for k = 1:2:length(varargin)
                switch(lower(varargin{k}))
                    case 'sname'
                        Xobj.Sname=varargin{k+1};
                    case {'sfieldformat','sformat'}
                        SfieldformatInput=varargin{k+1};
                    case 'clookoutfor'
                        if strcmp(varargin{k+1},'')
                            Xobj.Clookoutfor={};
                        else
                            Xobj.Clookoutfor=varargin{k+1};
                        end
                    case 'svarname'
                        Xobj.Svarname=varargin{k+1};
                    case {'ncolnum','ncol','colnum'}
                        Xobj.Ncolnum=varargin{k+1};
                    case {'nrownum','nrow','rownum'}
                        Xobj.Nrownum=varargin{k+1};
                    case 'nrepeat'
                        Xobj.Nrepeat=varargin{k+1};
                    case 'nrepeatanchor'
                        Xobj.NrepeatAnchor=varargin{k+1};
                    case 'vcoordcolumn'
                        Xobj.VcoordColumn=varargin{k+1};
                    case 'vcoordrow'
                        Xobj.VcoordRow=varargin{k+1};    
                    case 'csindexname'
                        Xobj.CSindexName=varargin{k+1};
                    case 'lismatrix'
                        Xobj.LisMatrix=varargin{k+1}; 
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1}; 
                    otherwise
                        error('OpenCossan:Response:wrongInputArgument', ...
                              'PropertyName %s is not valid', varargin{k})
                end
                
            end
                    
            assert(~isempty(Xobj.Sname), ....
                   'OpenCossan:Response:NoNameDefined', ...
                   ['It is necessary to define the name of the output ', ...
                   'using the mandatory property Sname.'])
            
               
            if isempty(Xobj.CSindexName)
                if ~isempty(Xobj.VcoordColumn) 
                    Nindex = length(Xobj.VcoordColumn);
                elseif ~isempty(Xobj.VcoordRow)
                    Nindex = length(Xobj.VcoordRow);
                else
                    Nindex = Xobj.Nrows;
                end
                if ~isinf(Nindex)
                    Xobj.CSindexName = repmat({''},1,Nindex);
                end
            end
                       
           % Check Field Format and add termination term and skip term. 
           % The scanf function skip the Xresponse(iresponse).Ccolnum{1}
           % characters and than read the real value
            if Xobj.Ncolnum<=1
                Xobj.Sfieldformat=[SfieldformatInput '%*'];
            else
                Xobj.Sfieldformat=['%*' num2str(Xobj.Ncolnum-1) 'c' SfieldformatInput '%*'];
            end
            
            assert(~(isempty(Xobj.Clookoutfor) & Xobj.NrepeatAnchor>1), ....
                   'OpenCossan:Response:NrepeatAnchorNotValid', ...
                   ['It is not possible to use NrepeatAnchor without defining ', ...
                   'Clookoutfor.'])

        end %end constructor
        
        display(Xobj)      
                
        function Nout = getOutputNrFromFormat(Xobj)
            Nout = length(strfind(Xobj.Sfieldformat,'%')) - ...
                length(strfind(Xobj.Sfieldformat,'%*'));
        end
        
        Xds = createDataseries(Xobj,Moutput)

        function Ndata = get.Ndata(Xobj)
            if Xobj.LisMatrix
                Ndata = Xobj.Nrepeat*Xobj.NrepeatAnchor;
            else
                Ndata = Xobj.getOutputNrFromFormat*Xobj.Nrepeat*Xobj.NrepeatAnchor;
            end
        end
        
        function Nrows = get.Nrows(Xobj)
            if Xobj.LisMatrix
                Nrows = Xobj.getOutputNrFromFormat*Xobj.NrepeatAnchor;
            else
                assert(~isinf(Xobj.Nrepeat),'OpenCossan:Response',...
                    'Nrepeat must be finite when the outputs are stored in rows.')

                Nrows = Xobj.Nrepeat*Xobj.NrepeatAnchor;
            end
        end
        
        % Extract response from the file with file identifaction Nfid. 
        % The methods returns a structure with the values extracted and a
        % second structure with the absolute position of the values
        % extracted 
        [Toutput,TresponsePosition,LresponseSuccess]=extract(Xobj,varargin)
    end
    
    %%    
    
    methods (Access=private)
        % These methods can only be accessed from methods of Response
        % object. 
        TfileInfo = findRelativePosition(Xobj,Nfid,TfileInfo)
        [Toutput,TfileInfo] = readResponse(Xobj,Nfid,TfileInfo)
    end
end
