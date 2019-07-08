classdef SolutionSequence
    % This class define the solution sequences. It is most used to define
    % user defined solution sequences. 
    %
    % Author: Edoardo Patelli
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
    
    %% Methods of the class
    
    properties % Public access
        Sdescription           % Description of the Matlab I/O
        Spath           = './' % Default path
        Sfile                  % matlab script (.m extension can be added or omitted, it will be stripped away by the constructor method)
        Coutputnames           % Names of the output created by the SolutionSequence 
        Cinputnames            % Names of the required inputs
        Sscript                % field that  contains the script to be executed (i.e. there is no file to be executed but this script)
        CprovidedObjectTypes   % Type of Cossan objects computed
        Cobject2output         % Customizable method to extract quantity of interest from computed output
        CglobalObjects         % Names of global variables 
        Cobject2input          % Customizable method to construct inputs required by the solution sequence script interest from computed output
        CobjectsNames          % List of Cossan objects required to run SolutionSequence
        CobjectsTypes          % Type of Cossan objects required to evaluate the Mio
        Cxobjects              % Cossan objects required to run SolutionSequence
        XjobManager            % JobManager Object for executing SolutionSequence on a remote machine
    end
    
    properties (Dependent = true, SetAccess = protected)
        LpostProcess           % Flag for postprocess stage
    end
    
    methods
        
        %% Constructor
        function Xobj   = SolutionSequence(varargin)
            %% SolutionSequence
            %
            %   This class defines an solution sequence that can be
            %   customize by the user.
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SolutionSequence
            %
            % Author: Edoardo Patelli
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
            
            if isempty(varargin)
                % Construct an empty object used by the subclasses
                % Please DO NOT REMOVE this
                return
            end
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set Default values
            Shostname='';
            Nconcurrent=Inf;
            
            % Set parameters defined by the user
            for k=1:2:length(varargin),
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription = varargin{k+1};
                    case 'spath'
                        Xobj.Spath = varargin{k+1};
                    case 'sfile'
                        Xobj.Sfile = varargin{k+1};
                    case 'coutputnames'
                        Xobj.Coutputnames = varargin{k+1};
                    case 'cinputnames'
                        Xobj.Cinputnames = varargin{k+1};
                    case 'sscript'
                        Xobj.Sscript = varargin{k+1};
                    case 'cprovidedobjecttypes'
                        Xobj.CprovidedObjectTypes = varargin{k+1};
                    case 'cobject2output'
                        Xobj.Cobject2output = varargin{k+1};
                    case 'cobject2input'
                        Xobj.Cobject2input = varargin{k+1};
                    case 'cglobalobjects'
                        Xobj.CglobalObjects=varargin{k+1};
                    case {'cobjectsnames' 'cobjectnames'}
                        Xobj.CobjectsNames = varargin{k+1};
                        
                        CreservedNames={'XobjSolutionSequence','varargin','varargout'};
                        assert(~any(ismember(Xobj.CobjectsNames,CreservedNames)),...
                            'openCOSSAN:SolutionSequence', ...
                            'It is not possible to use the objectname %s in Cobjectsnames',Xobj.CobjectsNames)
                    case {'cobjectstypes' 'cobjectinputtypes'}
                        Xobj.CobjectsTypes = varargin{k+1};
                    case 'cxobjects'
                        Xobj.Cxobjects = varargin{k+1};
                    case 'ccxobjects'
                        for n=1:length(varargin{k+1})
                            Xobj.Cxobjects{n} = varargin{k+1}{n}{1};
                        end
                    case 'xjobmanager'
                        Xobj.XjobManager = varargin{k+1};
                    case 'cxjobmanager'
                        Xobj.XjobManager = varargin{k+1}{1};
                    case 'xjobmanagerinterface'
                        assert(isa(varargin{k+1},'JobManagerInterface'), ...
                            'openCOSSAN:SolutionSequence', ...
                            'The object of class %s is not valid after the PropertyName %s', ...
                            class(varargin{k+1}),varargin{k})
                        XjobInterface=varargin{k+1};
                    case 'cxjobmanagerinterface'
                        assert(isa(varargin{k+1}{1},'JobManagerInterface'), ...
                            'openCOSSAN:SolutionSequence', ...
                            'The object of class %s is not valid after the PropertyName %s', ...
                            class(varargin{k+1}{1}),varargin{k})
                        XjobInterface=varargin{k+1}{1};
                    case {'cshostnames'}
                        Shostname=varargin{k+1}{1};
                    case {'csqueues'}
                        Squeue=varargin{k+1}{1};
                    case {'shostname'}
                        Shostname=varargin{k+1};
                    case {'squeue'}
                        Squeue=varargin{k+1};
                    case {'vconcurrent','nconcurrent'}
                        Nconcurrent=varargin{k+1};
                    otherwise
                        error('openCOSSAN:SolutionSequence',...
                            'Field name %s not allowed', varargin{k});
                end
            end
            
            %% Setting the JobManager if the interface is provided
            
            % Setting the JobManager
            if exist('XjobInterface','var')
                % If the JobManagerInterface is defined check that
                % Squeues,Shostnamesm and Nconcurrent exist
                
                assert(logical(exist('Squeue','var')), ...
                    'openCOSSAN:SolutionSequence', ...
                    'The properties Squeue must be defined')
                
                % Setting the connector
                Xobj.XjobManager=JobManager('XjobManagerInterface',XjobInterface, ...
                    'Squeue',Squeue,'Shostname',Shostname, ...
                    'Nconcurrent',Nconcurrent,...
                    'Sdescription','JobManager created by SolutionSequence');
            end
            
            if isempty(Xobj.CobjectsTypes) && ~isempty(Xobj.Cxobjects)
                for n=1:length(Xobj.Cxobjects)
                    Xobj.CobjectsTypes{n}=class(Xobj.Cxobjects{n});
                end
            end
            
            assert(length(Xobj.CobjectsTypes)==length(Xobj.CobjectsNames),...
                'openCOSSAN:SolutionSequence', ...
                'The length of CobjectsTypes (%i) must be equal to the length of CXobject (%i)',...
                length(Xobj.CobjectsTypes),length(Xobj.CobjectsNames))
            
            
            
            assert(~isempty(Xobj.Coutputnames),'openCOSSAN:SolutionSequence', ...
                'Mandatory input Coutputnames cannot be empty.')
            
            if isempty(Xobj.CprovidedObjectTypes)
                Xobj.CprovidedObjectTypes=cell(length(Xobj.Coutputnames),1);
            else
                assert(length(Xobj.CprovidedObjectTypes)==length(Xobj.Coutputnames), ...
                    'openCOSSAN:SolutionSequence', ...
                    'Length of the CprovidedObjectTypes (%i) must be equal to the length of Coutputnames (%i)', ...
                    length(Xobj.CprovidedObjectTypes),length(Xobj.Coutputnames))
            end
            
            
            if isempty(Xobj.Cobject2output)
                Xobj.Cobject2output=cell(length(Xobj.CprovidedObjectTypes),1);
            else
                assert(length(Xobj.CprovidedObjectTypes)==length(Xobj.Cobject2output), ...
                    'openCOSSAN:SolutionSequence', ...
                    'Length of the Cobject2output (%i) must be equal to the length of CprovidedObjectTypes (%i)', ...
                    length(Xobj.Cobject2output),length(Xobj.CprovidedObjectTypes))
            end
            
            
            
        end     %of constructor
        
        % ealuate the script
        [varargout]=userDefinedAnalysis(Xobj,varargin);
        
        % Apply the solution sequences
        [varargout]=apply(Xobj,Xtarget);
        
        display(Xobj)
        
        function LpostProcess=get.LpostProcess(Xobj)
            if isempty(Xobj.Cobject2output{1}) && ...
                    strcmp(Xobj.CprovidedObjectTypes{1},'SimulationData') && ...
                    length(Xobj.CprovidedObjectTypes)==1
                LpostProcess=false;
            else
                LpostProcess=true;
            end
        end
        
    end    %of methods
    
    methods (Access=private)
        [varargout]=runScript(Xobj,varargin);
    end
    
end     %of class definition
