classdef Injector
    % class Injector
    %
    % The objects of class Injector create a connection between a FE ascii
    % input file and OpenCossan. Values of OpenCossan inputs (i.e.,
    % RandomVariables, Functions and Parameters) are inserted in the input
    % files in place of identifiers inserted in the file. This identifiers
    % can be manually inserted or inserted by using the GUI.
    % These objects create a "link" between an ASCII input file and the
    % OpenCossan input objects, with the paradigm "one object, one file".
    %
    % EXAMPLE of an identifier:
    %
    % <cossan name="Xmat1" format="%8.2e" original="1001" />
    %
    % 'Name' is the name of the COSSAN input variable to be injected
    % 'Format' is a string identifying the format that is used to write the
    % numerical value in the input file. The format string of Matlab are
    % used. Moreover, the format "nastran8" and "nastran16", used
    % specifically by Nastran, are available.
    % 'Original' is the original numerical value that will be replaced.
    %
    % See Also: https://cossan.co.uk/wiki/index.php/@Injector
    %
    % Author: Matteo Broggi and Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of OpenCossan.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % OpenCossan is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % OpenCossan is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with OpenCossan.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties
        Stype = 'scan'          % Type of Injector. Available types: 'empty' or 'scan'
        Sdescription            % Description of the injector
        Srelativepath = ['.' filesep]   %  This is the RELATIVE path to the working directory
        Sfile                   %  Name of the ASCII input file
        Sscanfilename           % Name of the file with identifiers to be scanned
        Sscanfilepath=['.' filesep]     % Path of the file with identifiers './'
        Sworkingdirectory       % directory where the FE simulation is performed - set by Connector
        Xidentifier             % Array of Identifier objects
        Cinputnames
    end
    
    properties (Hidden=true,SetAccess = private)
        Lreplaceidentifiers=false    % replace identifiers
    end
    
    properties (Constant,Hidden=true)  
        % Define regular expression strings  
        Sexpr_name = 'name="(.+?)"';
        Sexpr_index = 'index="(.+?)"';
        Sexpr_format = 'format="(.+?)"';
        Sexpr_formatlength = '%([0-9]+)';
        Sexpr_originalvalue= 'original="(.+?)"';
        Sexpr = '<cossan\s.+?/>';
        Sexpr_includefile = 'includefile="(.+?)"';            
    end
    
    properties (Dependent = true, SetAccess = protected)
        Nvariable
    end
    
    methods
        function Xinjector = Injector(varargin)
            % Constructor injector object
            %
            %   MANDATORY ARGUMENTS: -
            %                           if no arguments are passed to the injector
            %                           constructor an empty object is created
            %
            %   OPTIONAL ARGUMENTS:
            %
            %   - Sdescription: description
            %   - Stype: 'Interactive' this option allows to generate the extractor
            %            interactively
            %            'empty' generate the an empty injector
            %            'scan' generate the injector scanning an input file with
            %            the COSSAN identifiers (default value)
            %   - Srelativepath: path of the file
            %   - Sfile: file name of the file
            %   - Nvar: Number of variables to be injected
            %   - Sname: Name of the associate COSSAN variables
            %   - Nindex: Index of the variable (only for vector and matrix)
            %   - Sfieldformat: Format string
            %                   '%' + Maximum field width + conversion character
            %                   (see fscanf for more information)
            %    - Slookoutfor: if present define the string to be searched inside the ASCII file
            %                   in order to define the relative position
            %    - Svarname: if present Ccolnum and Crownum are relative respect to the
            %                variable present in Cvarname
            %    - Ncolnum: Colum position in the ASCII file of the variables
            %    - Nrownum: Row  position in the ASCII file of the variables
            %    - Nposition: Absolute position inside the input file
            %    - Sregexpression: Regular expression
            %    - Sscanfilename: name of the file with the COSSAN indentifiers
            %                     (mandatory with the option Stype=scan)
            %    - Sscanfilepath: path of the file with the COSSAN indentifiers
            %                     (mandatory with the option Stype=scan)
            %
            %
            %
            %   EXAMPLES:
            %   Usage:  Xi  = injector('Sdescription','Injector Object', 'Stype','scan', ...
            %                         'Sscanfilename','input.cossan','Sscanpathname','./', ...
            %                         'Soutputname','input.txt')
            %
            % See Also: https://cossan.co.uk/wiki/index.php/@Injector
            %
            % Author: Matteo Broggi and Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: https://www.cossan.co.uk
            
            % =====================================================================
            % This file is part of OpenCossan.  The open general purpose matlab
            % toolbox for numerical analysis, risk and uncertainty quantification.
            %
            % OpenCossan is free software: you can redistribute it and/or modify
            % it under the terms of the GNU General Public License as published by
            % the Free Software Foundation, either version 3 of the License.
            %
            % OpenCossan is distributed in the hope that it will be useful,
            % but WITHOUT ANY WARRANTY; without even the implied warranty of
            % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
            % GNU General Public License for more details.
            %
            %  You should have received a copy of the GNU General Public License
            %  along with OpenCossan.  If not, see <http://www.gnu.org/licenses/>.
            % =====================================================================
            %
            
            %% Create empty object (This is needed by subclasses)
            if nargin==0
                return
            end
            
            %% Processing Inputs
            
            % Process all the arguments and assign them the corresponding
            % default value if not passed
            
            OpenCossan.validateCossanInputs(varargin{:});
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'stype'}
                        Xinjector.Stype=varargin{k+1};
                    case {'sdescription'}
                        Xinjector.Sdescription=varargin{k+1};
                    case {'srelativepath'}
                        Xinjector.Srelativepath=varargin{k+1};
                        if not(strcmp(Xinjector.Srelativepath(end),filesep))
                            Xinjector.Srelativepath  = [Xinjector.Srelativepath filesep];
                        end
                    case {'sfile'}
                        Xinjector.Sfile=varargin{k+1};
                    case {'sscanfilename'}
                        Xinjector.Sscanfilename=varargin{k+1};
                    case {'sscanfilepath'}
                        Xinjector.Sscanfilepath=varargin{k+1};
                        if not(strcmp(Xinjector.Sscanfilepath(end),filesep))
                            Xinjector.Sscanfilepath  = [Xinjector.Sscanfilepath filesep];
                        end
                    case {'sworkingdirectory'}
                        Xinjector.Sworkingdirectory=varargin{k+1};
                        if not(strcmp(Xinjector.Sscanfilepath(end),filesep))
                            Xinjector.Sscanfilepath  = [Xinjector.Sscanfilepath filesep];
                        end
                    case {'xidentifier'}
                        Xinjector.Xidentifier=varargin{k+1};
                    case {'lreplaceidentifiers'}
                        Xinjector.Lreplaceidentifiers=varargin{k+1};
                    otherwise
                        error('OpenCossan:injector:unknownInputArgument', ...
                            ' The PropertyName %s is not a valid input argument',varargin{k})
                end
            end
            
            
            %% Define main parameters of responses
            if ~strcmpi(Xinjector.Stype, 'empty')
                % Use file with identifiers to create injector
                if isempty(Xinjector.Xidentifier)
                    % if the array of the identifiers is not passed to the
                    % constructor, invoke the createByScan method
                    if ~isempty(Xinjector.Sscanfilename) && exist(fullfile(Xinjector.Sscanfilepath,Xinjector.Sscanfilename),'file')
                        Xinjector= createByScan(Xinjector);

                        if strcmp(Xinjector.Sscanfilepath,Xinjector.Srelativepath) && strcmp(Xinjector.Sscanfilename,Xinjector.Sfile)
                            error('OpenCossan:injector:wronngIdentifierName',...
                                ['The file with the identifiers and the file without the identifiers have the same name\n',...
                                ' Filename: %s'],  Xinjector.Sscanfilename,Xinjector.Sfile')
                        end
                        
                        %% Include orginal values in the input file
                        if ~isempty(Xinjector.Xidentifier)
                            Xinjector.replaceIdentifiers;
                        else
                            copyfile(fullfile(Xinjector.Sscanfilepath,Xinjector.Sscanfilename),...
                                fullfile(Xinjector.Sscanfilepath,Xinjector.Sfile),'f')
                        end
                    else
                        error('OpenCossan:injector:noscanfile','The file to be scanned does not exist \n Filename: %s',...
                            fullfile(Xinjector.Sscanfilepath,Xinjector.Sscanfilename));
                    end
                end
            end
            
            %% Set
            Xidentifiers = Xinjector.Xidentifier;
            if isempty(Xidentifiers)
                Xinjector.Cinputnames={};
            else
                Xinjector.Cinputnames=cell(size(Xidentifiers));
                for n=1:length(Xidentifiers)
                    Xinjector.Cinputnames(n) = {Xidentifiers(n).Sname};
                end
                Xinjector.Cinputnames = unique(Xinjector.Cinputnames);
            end
        end % end constructor
        
        function Nvariable = get.Nvariable(Xobj)
            Nvariable = length(Xobj.Cinputnames);
        end
        
        function replaceIdentifiers(Xinjector)
            %REPLACE_IDENTIFIERS private function for the injector
            %   Require the fid number of file and the structure of value to be
            %   injected
            % Arguments: 'Nfid_old' identifiers of the file with the identifiers
            %                     'Nfid_new' identifiers of the file without
            %                     identifiers
            %                     'Tinput' Structure of the injected value
            %                     varargout: log file
            
            %% open the files
            Nfid_old = fopen(fullfile(Xinjector.Sscanfilepath,Xinjector.Sscanfilename));
            Nfid_new=fopen(fullfile(Xinjector.Sscanfilepath,Xinjector.Sfile),'w+');
            
            if (Nfid_old == -1)
                error('OpenCossan:Injector:Injector',...
                    ['Input file ' fullfile(Xinjector.Sscanfilepath,...
                    Xinjector.Sscanfilename) ' does not exist'])
            end
            if (Nfid_new == -1)
                error('OpenCossan:Injector:Injector', ...
                    ['Cannot write on injected input file ' ....
                    fullfile(Xinjector.Sscanfilepath,Xinjector.Sfile) ...
                    '\n Check file permissions.'])
            end
            
            % initialize the variables
            line_id = 0; var_id = 0;
            while 1
                Stline = fgetl(Nfid_old);    % read one line at time
                line_id = line_id + 1;
                
                if ~ischar(Stline)      % EOF found
                    OpenCossan.cossanDisp(['EOF found after ' num2str(line_id) ' lines'],2);
                    break
                end
                
                % find a matching identifier
                [~, s, e] = regexp(Stline,Xinjector.Sexpr, 'match', 'start', 'end');
                
                if ~isempty(s)
                    fseek(Nfid_old,0,'cof');
                    
                    Snew = {};
                    for it=1:length(s)
                        var_id=var_id+1;
                        Sformat = Xinjector.Xidentifier(var_id).Sfieldformat;
                        
                        % Replace the xml identifier in the string with the
                        % original value
                        % the array of identifiers is passed in order to substitute
                        % the original values
                        switch lower(Sformat)
                            case {'nastran8'}
                                Svalue= Identifier.num2nastran8(Xinjector.Xidentifier(var_id).Noriginal);
                                [Snew{it}, errmsg] = sprintf(Svalue);%#ok<*AGROW>
                            case {'nastran16'}
                                Svalue= Identifier.num2nastran16(Xinjector.Xidentifier(var_id).Noriginal);
                                [Snew{it}, errmsg] =sprintf(Svalue);
                            case {'nastran16_table'}
                                Svalue= Xinjector.Xidentifier(var_id).Soriginal;
                                [Snew{it}, errmsg] =sprintf(num2str(Svalue));
                            case {'abaqus_table'}
                                Svalue= Xinjector.Xidentifier(var_id).Soriginal;
                                [Snew{it}, errmsg] =sprintf(Svalue);
                            otherwise
                                [Vpos]=regexp(Sformat,'%');
                                if length(Vpos)>1
                                    warning('OpenCossan:injector:scan_file',...
                                        'Multiple fields in the injector are not allowed');
                                    OpenCossan.cossanDisp(['Sformat: ' Sformat ' replaced with ' Sformat(Vpos(1):Vpos(2)-1) ],1)
                                    Sformat=Sformat(Vpos(1):Vpos(2)-1);
                                end
                                
                                [Snew{it}, errmsg] = sprintf(Sformat,Xinjector.Xidentifier(var_id).Noriginal);
                        end
                        
                        if ~isempty(errmsg)
                            warning('OpenCossan:inject:replace_identifiers',errmsg);
                        end
                    end
                    
                    if length(s)==1
                        Stline=[Stline(1:s(it)-1) Snew{1} Stline(e(it)+1:end)];
                    else
                        Stline_old=Stline;
                        Stline=Stline_old(1:s(1)-1);
                        for it=1:length(s)-1
                            Stline=[Stline Snew{it} Stline_old(e(it)+1:s(it+1)-1)];
                        end
                        Stline=[Stline Snew{end} Stline_old(e(end)+1:end)];
                    end
                    
                end
                fprintf(Nfid_new,'%s\n',Stline);
            end
            
            %% close the opened files
            fclose(Nfid_old);
            fclose(Nfid_new);
            
            OpenCossan.cossanDisp(['Injected input file with original values: ' ....
                fullfile(Xinjector.Sscanfilepath,Xinjector.Sfile) ],4)
        end
        
        inject(Xi,Pinput)
        
        display(Xi)
    end
    
    methods (Access= private)

        Xidentifier=scanFile(Xobj,Nfid)         % Scan ASCII file with identifier
        
        function Xinj = createByScan(Xinj)
            %CREATEBYSCAN Private function to create the Injector from the scanning on an input
            %file containing the OpenCossan identifiers
            % Arguments: 'Xinj' injector Object
            %                      'Scanfullname' Full name (path+name) of the file
            %                      with the identifiers
            
            
            Scanfullname= fullfile(Xinj.Sscanfilepath,Xinj.Sscanfilename);
            
            OpenCossan.cossanDisp(['[OpenCossan.Injector.createByScan] File to be scanned: ' Scanfullname],2)
            
            % Open file to scan
            [Nfid, Serror] = fopen(Scanfullname,'r'); % open ASCII file
            
            if Nfid<0
                error('OpenCossan:Injector:createbyscan',...
                    ['The file' Sscanfullname ' does not exist. ' Serror ])
            end
            % remove the wrong line termination that can be included in a
            % file if it was created/modified in windows
            Vbytes = fread(Nfid,'uint8=>uint8');
            fclose(Nfid);
            Nfid = fopen(Scanfullname,'w');
            Vbytes(Vbytes==uint8(13))=[]; % remove the CR ascii character
            fwrite(Nfid,Vbytes,'uint8');
            fclose(Nfid);
            
            % reopen the file after the CRs have been removed
            Nfid = fopen(Scanfullname,'r');
            
            % Scan file
            Xinj.Xidentifier = Xinj.scanFile(Nfid);
            
            fclose(Nfid);
            OpenCossan.cossanDisp(['[OpenCossan.Injector.createByScan] Close File to be scanned: ' Scanfullname],2)
            
            if isempty(Xinj.Xidentifier)
                warning('OpenCossan:Injector:createByScan',...
                    ['No identifiers found in file ' Scanfullname ...
                    '\nConsider including this file in the property Caddfiles of Connector.'])
            end
            
            Xinj.Sdescription=['Injector created from file ' Scanfullname];
            
            OpenCossan.cossanDisp('[OpenCossan.Injector.createByScan] Identifier identified correctly',4)
        end   
        
    end
    
end

