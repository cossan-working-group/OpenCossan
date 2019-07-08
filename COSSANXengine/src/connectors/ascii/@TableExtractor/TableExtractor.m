classdef TableExtractor < Extractor
    %TABLEEXTRACTOR Read the response of a solver from a table
    %
    % See Also: http://cossan.co.uk/wiki/index.php/@TableExtractor
    %
    % Author: Matteo Broggi. Edoardo Patelli
    % COSSAN Working Group
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
        Sdelimiter           % delimiter between columns
        Sformat              % user defined format
        Nheaderlines=0       % number of lines to skip from beginning of file
        CcolumnPosition={}    % identify columns to extract 
        ClinePosition={}      % identify lines to extract
        NcoordinateColumn     % extract coordinates from the specified column
        SheaderIdentifier     % Character used to define the header
    end
    
    properties (Access=private, Dependent=true)
        % Nothing here
    end
    
    methods
        
        function Xobj  = TableExtractor(varargin)
            % Constractor for a TableExtractor object
            % A TableExtractor allows to read data from a file written in a
            % table format. 
            % It is possible to extract specific columns and rows using the
            % arguments "CcolumnPosition" and "ClinePosition", specify the
            % column containing the coordinate using "NcoordinateColumn".
            %
            % The names of the variables extracted are defined using the
            % properties "Coutputnames". 
            %
            % See Also: TutorialTableExtractor 
            %
            % Author: Edoardo Patelli
            % COSSAN Working Group
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
            if isempty(varargin)
                %compatibility for empty constructor
                return
            end
            
            %% Check Inputs
            OpenCossan.validateCossanInputs(varargin{:});
            
            %% Set options
            
            for iVopt=1:2:length(varargin)
                switch lower(varargin{iVopt})
                    % Inputs herited from the superclass (EXTRACTOR)
                    case 'lverbose'
                        Xobj.Lverbose = varargin{iVopt + 1};
                    case 'sdescription'
                        Xobj.Sdescription = varargin{iVopt + 1};
                    case 'srelativepath'
                        Xobj.Srelativepath = varargin{iVopt + 1};
                    case 'sfile'
                        Xobj.Sfile = varargin{iVopt + 1};
                        % Input specific for the TableExtractor
                    case 'nheaderlines'
                        Xobj.Nheaderlines = varargin{iVopt + 1};
                    case 'sdelimiter'
                        Xobj.Sdelimiter = varargin{iVopt + 1};
                    case 'sformat'
                        Xobj.Sformat = varargin{iVopt + 1};
                    case 'sheaderidentifier'
                        Xobj.SheaderIdentifier = varargin{iVopt + 1};
                    case 'soutputname'                                               
                        assert(isempty(Xobj.Coutputnames),'OpenCossan:TableExtractor:CoutputnamePredefined',...
                            'Coutputname already defined (%s)! \nIt is not possible to use Soutputname with Coutputnames!\n',...
                            sprintf(' "%s",',Xobj.Coutputnames{:}))
                        % This is necessary to keep the compatibility with
                        % the current Extractor object
                        Xobj.Xresponse(1).Sname=varargin{iVopt + 1};                        
                        
                    case 'coutputnames'
                        assert(isempty(Xobj.Coutputnames),'OpenCossan:TableExtractor:SoutputnamePredefined',...
                            'Soutputname already defined ("%s")! \nIt is not possible to use Soutputname with Coutputnames',...
                             Xobj.Coutputnames)
                        % This is necessary to keep the compatibility with
                        % the current Extractor object
                        for n=1:length(varargin{iVopt + 1})
                            Xobj.Xresponse(n).Sname=varargin{iVopt + 1}{n};  
                        end
                    case 'ccolumnposition'
                        Xobj.CcolumnPosition = varargin{iVopt + 1};
                    case 'clineposition'
                        Xobj.ClinePosition = varargin{iVopt + 1};
                    case 'ncoordinatecolumn'
                        Xobj.NcoordinateColumn=varargin{iVopt + 1};
                    otherwise
                        error('openCOSSAN:TableExtractor',['Unknown property: ' varargin{iVopt}])
                end
            end % end of inputs definition
            
            %% Check validity of the input
            assert(~isempty(Xobj.Coutputnames),...
                'openCOSSAN:TableExtractor:noOutputNames',...
                'Name of the response(s) need to be specified')
            
            if ~isempty(Xobj.CcolumnPosition)
                assert(length(Xobj.CcolumnPosition)==length(Xobj.Coutputnames),...
                'openCOSSAN:TableExtractor:wrong number of colums',...
                'The length of CcolumnPosition (%i) must be equal to the number of output defined in Coutputnames(%i)',...
                length(Xobj.CcolumnPosition),length(Xobj.Coutputnames))
            end
            
            if ~isempty(Xobj.ClinePosition)
                assert(length(Xobj.ClinePosition)==length(Xobj.Coutputnames),...
                'openCOSSAN:TableExtractor:wrong number of colums',...
                'The length of ClinePosition (%i) must be equal to the number of output defined in Coutputnames(%i)',...
                length(Xobj.ClinePosition),length(Xobj.Coutputnames))
            end
            
            % Check if an output is present more than once in the Extractor
            [~, Nunique]=unique(Xobj.Coutputnames);
            assert(length(Nunique)==length(Xobj.Coutputnames), ...
                'openCOSSAN:TableExtractor:DuclicateNames',...
                'Duplicated output names defined in "Coutputnames" : %s\n', Xobj.Coutputnames{:})
            
            if ~isempty(Xobj.Srelativepath)
                if~(strcmp(Xobj.Srelativepath(end),filesep)) % add / or \ at the end of the path
                    Xobj.Srelativepath  = [Xobj.Srelativepath filesep];
                end
            end
            
            % File path must be defined
            assert(~isempty(Xobj.Sfile),...
                'openCOSSAN:TableExtractor:NoFileDefined',...
                'No file name defined for the TableExtractor.\n Use "Sfile" to provide the name of the file')
            
            %% Check lengths of CcolumnPosition and ClinePosition
            Xobj.CcolumnPosition(end+1:length(Xobj.Coutputnames))={':'};
            Xobj.ClinePosition(end+1:length(Xobj.Coutputnames))={':'};

        end %end constructor
        
        [Tout, LsuccessfullExtract] = extract(Xe,varargin)
        
    end
    

    
end
