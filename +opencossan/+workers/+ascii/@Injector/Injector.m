classdef Injector < opencossan.common.CossanObject
    % class Injector
    %
    % The objects of class Injector create a connection between a FE ascii
    % input file and COSSAN. Values of COSSAN inputs (i.e.,
    % RandomVariables, Functions and Parameters) are inserted in the input
    % files in place of identifiers inserted in the file. This identifiers
    % can be manually inserted or inserted by using the GUI.
    % These objects create a "link" between an ASCII input file and the
    % COSSAN input objects, with the paradigm "one object, one file".
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
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Injector
    %
    % Author: Matteo Broggi and Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties
        RelativePath(1,1) string = ['.' filesep]   %  This is the RELATIVE path to the working directory
        FileName(1,1) string           %  Name of the ASCII input file
        ScanFileName(1,1) string                  % Name of the file with identifiers to be scanned
        WorkingDirectory(1,1) string       % directory where the FE simulation is performed - set by Connector
        Identifiers(1,:) opencossan.workers.ascii.Identifier % Array of Identifier objects - set by the scanFile method
    end
    
    properties (Constant,Hidden=true)
        Sexpr_name = 'name="(.+?)"';
        Sexpr_index = 'index="(.+?)"';
        Sexpr_format = 'format="(.+?)"';
        Sexpr_formatlength = '%([0-9]+)';
        Sexpr_originalvalue= 'original="(.+?)"';
        Sexpr_identifier = '<cossan\s.+?/>';      
    end
    
    properties (Dependent = true)
        Nvariable
        InputNames(1,:) string % array of strings with the names of the input quantities
        ScanFilePath(1,1) string
    end
    
    methods
        function obj = Injector(varargin)
            % INJECTOR Create a new Injector object
            %
            % obj = Injector('ScanFileName',identifier_file,'FileName',
            % injected_file) will create a new Injector object.
            % The template file (path and name) with the identifier will be
            % scanned, and it is passed to the property 'ScanFileName'. 
            % Then, for each analyisis, the sampled values will be inserted
            % in the identifier location, creating a new file with the name
            % specified in 'FileName'.
            %
            % The identifiers contained in the template file must be in the
            % format:
            %
            % <cossan name="Xh" format="%12.6e" original="0.2"/>
            %
            
            %% Processing inputs
            if nargin == 0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["ScanFileName", "FileName"], varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["RelativePath","Identifiers"],{[],[]}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            % Process all the arguments
            
            if nargin > 0
                obj.ScanFileName = required.scanfilename;
                obj.FileName = required.filename;
                
                if isempty(optional.relativepath)
                    obj.RelativePath = '';
                else
                    obj.RelativePath = optional.relativepath;
                end
                
                if isempty(optional.identifiers)
                    % if the identifier vector is not passed to the
                    % constructor, it is assembled by scanning the template
                    % file.
                    
                    % does the template file exist?
                    assert( exist(obj.ScanFileName,'file')==2,...
                        'OpenCossan:Injector:noScanFile','The file to be scanned does not exist \n Filename: %s',...
                        obj.ScanFileName);
                end
            end
            
            
            
            %% Define main parameters of responses
            % Use file with identifiers to create injector
            if isempty(obj.Identifiers)
                % if the array of the identifiers is not passed to the
                % constructor, invoke the createByScan method
                if ~isempty(obj.ScanFileName) && exist(fullfile(obj.ScanFileName),'file')
                    obj= createByScan(obj);

                    if strcmp(obj.ScanFilePath,obj.RelativePath) && strcmp(obj.ScanFileName,obj.FileName)
                        error('openCOSSAN:Injector:wrongIdentifierName',...
                            ['The file with the identifiers and the file without the identifiers have the same name\n',...
                            ' Filename: %s'],  obj.ScanFileName,obj.FileName')
                    end

                    %% Include original values in the input file
                    if ~isempty(obj.Identifiers)
                        obj.replaceIdentifiers();
                    else
                        copyfile(fullfile(obj.ScanFilePath,obj.ScanFileName),...
                            fullfile(obj.ScanFilePath,obj.FileName),'f')
                    end
                else
                    error('openCOSSAN:Injector:NoScanFile','The file to be scanned does not exist \n Filename: %s',...
                        fullfile(obj.ScanFilePath,obj.ScanFileName));
                end
                
            end

        end % end constructor
        
        function InputNames = get.InputNames(obj)
            InputNames = unique({obj.Identifiers.Name}); 
        end
        
        function Nvariable = get.Nvariable(Xobj)
            Nvariable = length(Xobj.Cinputnames);
        end
        
        function path = get.ScanFilePath(obj)
            path = fileparts(obj.ScanFileName);
        end
        
        function replaceIdentifiers(obj)
            %REPLACE_IDENTIFIERS private function for the injector
            %   Require the fid number of file and the structure of value to be
            %   injected
            % Arguments: 'Nfid_old' identifiers of the file with the identifiers
            %                     'Nfid_new' identifiers of the file without
            %                     identifiers
            %                     'Tinput' Structure of the injected value
            %                     varargout: log file
            
            import opencossan.workers.ascii.Identifier
            
            %% open the files
            Nfid_old = fopen(fullfile(obj.ScanFileName));
            Nfid_new=fopen(fullfile(obj.ScanFilePath,obj.FileName),'w+');
            
            assert(Nfid_old ~= -1,'openCOSSAN:Injector:MissingTemplateFile',...
                    'Input file %s does not exist', obj.ScanFileName)
            
            assert(Nfid_new ~= -1,'openCOSSAN:Injector:CantWriteTargetFile', ...
                    'Cannot write on injected input file %s \nCheck file permissions.', ....
                    fullfile(obj.ScanFilePath,obj.FileName))
            
            % initialize the variables
            line_id = 0; var_id = 0;
            while 1
                Stline = fgetl(Nfid_old);    % read one line at time
                line_id = line_id + 1;
                
                if ~ischar(Stline)      % EOF found
                    opencossan.OpenCossan.cossanDisp(['EOF found after ' num2str(line_id) ' lines'],2);
                    break
                end
                
                % find a matching identifier
                [~, s, e] = regexp(Stline,obj.Sexpr_identifier, 'match', 'start', 'end');
                
                if ~isempty(s)
                    fseek(Nfid_old,0,'cof');
                    
                    Snew = {};
                    for it=1:length(s)
                        var_id=var_id+1;
                        Sformat = obj.Identifiers(var_id).FieldFormat;
                        
                        % Replace the xml identifier in the string with the
                        % original value
                        % the array of identifiers is passed in order to substitute
                        % the original values
                        switch lower(Sformat)
                            case {'nastran8'}
                                Svalue= opencossan.common.utilities.num2nastran8(obj.Identifiers(var_id).OriginalValue);
                                [Snew{it}, errmsg] = sprintf(Svalue);%#ok<*AGROW>
                            case {'nastran16'}
                                Svalue= opencossan.common.utilities.num2nastran16(obj.Identifiers(var_id).OriginalValue);
                                [Snew{it}, errmsg] =sprintf(Svalue);
                            otherwise
                                [Vpos]=regexp(Sformat,'%');
                                if length(Vpos)>1
                                    warning('COSSAN:injector:scan_file',...
                                        'Multiple fields in the injector are not allowed');
                                    OpenCossan.cossanDisp(['Sformat: ' Sformat ' replaced with ' Sformat(Vpos(1):Vpos(2)-1) ],1)
                                    Sformat=Sformat(Vpos(1):Vpos(2)-1);
                                end
                                
                                [Snew{it}, errmsg] = sprintf(Sformat,obj.Identifiers(var_id).OriginalValue);
                        end
                        
                        if ~isempty(errmsg)
                            warning('openCOSSAN:inject:replace_identifiers',errmsg);
                        end
                    end
                    
                    if length(s)==1
                        % need to convert the char array into string
                        % because now strcat remove trailing spaces from
                        % char arrays!
                        Stline=strcat(string(Stline(1:s(it)-1)),Snew{1},string(Stline(e(it)+1:end)));
                    else
                        Stline_old=Stline; % this is a character array
                        Stline=string(Stline_old(1:s(1)-1));
                        for it=1:length(s)-1
                            Stline=strcat(Stline,Snew{it},string(Stline_old(e(it)+1:s(it+1)-1)));
                        end
                        Stline=strcat(Stline,Snew{end},string(Stline_old(e(end)+1:end)));
                    end
                    
                end
                fprintf(Nfid_new,'%s\n',Stline);
            end
            
            %% close the opened files
            fclose(Nfid_old);
            fclose(Nfid_new);
            
            opencossan.OpenCossan.cossanDisp(['Injected target input file with original values: ' ....
                fullfile(obj.ScanFilePath,obj.FileName) ],4)
        end
        
        inject(obj,TableInput)
        
    end
    
    methods (Access= private)

        Xidentifier=scanFile(Xobj,Nfid)         % Scan ASCII file with identifier
        
        function obj = createByScan(obj)
            %CREATEBYSCAN Private function to create the Injector from the scanning on an input
            %file containing the COSSAN identifiers
            % Arguments: injector Object
            
            opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Injector.createByScan] File to be scanned: ' obj.ScanFileName],2)
            
            % Change the eventual windows line termination to unix line
            % termination
            opencossan.common.utilities.dos2unix(obj.ScanFileName)

            % open the file with identifiers
            Nfid = fopen(obj.ScanFileName,'r');
            
            % Scan file
            obj.Identifiers = obj.scanFile(Nfid);
            
            fclose(Nfid);
            opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Injector.createByScan] Close File to be scanned: ' obj.ScanFileName],2)
            
            if isempty(obj.Identifiers)
                warning('openCOSSAN:Injector:createByScan',...
                    ['No identifiers found in file ' obj.ScanFileName ...
                    '\nConsider including this file in the property Caddfiles of Connector.'])
            end
            
            if isempty(obj.Description)
                % if no description is given, create one
                obj.Sdescription=['Injector created from file ' obj.ScanFileName];
            end
            
            opencossan.OpenCossan.cossanDisp('[COSSAN-X.Injector.createByScan] Identifier identified correctly',4)
        end   
        
    end
    
end

