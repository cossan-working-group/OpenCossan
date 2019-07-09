classdef FaultTree
    % FAULTTREE object for system reliability
    % This object defines the connection logic between the events
    % (PerformanceFunctions)
    %
    % See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@FaultTree
    
    properties
        Sdescription % Description of the FaultTree object
    end
    
    properties (SetAccess = protected)
        VnodeConnections    % Define the output connections of the current node
        CnodeNames          % name of the object forming of the current node
        CnodeTypes          % Define the type of node (e.g. AND/OR Input/Output)
        McutSets            % Cut-Sets of the Fault tree (logic array)
        MminimalCutSets     % Cut-Sets of the Fault tree  (logic array)
        CminimalCutSets     % Minimal Cut Sets of the Fault tree 
    end
    
    properties (Dependent = true, SetAccess = protected)
        Ccomponents  % List of the components defined in the FaultTree
        NbasicEvents % Number of basic events defined in the FaultTree
    end
    
    methods
               
        %% Constructor
        function Xobj= FaultTree(varargin)
           %FAULTTREE object for system reliability
           %   this object contains the performance function objects and their
           %   connection logic
           %
            % See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@FaultTree
            %
            % Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
            % Author: Edoardo-Patelli
            
           if nargin==0
               return
           end
           
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'cnodetypes'}
                        Xobj.CnodeTypes=varargin{k+1};
                    case {'cnodenames'}
                        Xobj.CnodeNames=varargin{k+1};
                    case {'vnodeconnections'}
                        Xobj.VnodeConnections=varargin{k+1};
                    otherwise
                        error('openCOSSAN:reliability:FaultTree',...
                            'Field name %s not allowed',varargin{k});
                end
            end
            
            %% Check consistency of the passed variables
            if length(Xobj.CnodeTypes)~=length(Xobj.CnodeNames) || length(Xobj.CnodeTypes)~=length(Xobj.VnodeConnections)
                error('openCOSSAN:reliability:FaultTree',...
                    ['Length of Cnodetype Cnodenames and Vnodeout must be the same \n Cnodetype: ' ...
                    num2str(length(Xobj.CnodeTypes)) ' \n Cnodenames: ' num2str(length(Xobj.CnodeNames)) ...
                    ' \n Vnodeout: ' num2str(length(Xobj.VnodeConnections))])
            end
            
            %% Check Cnodetype
            CallowedType={'Input','Output','AND','OR'};
            
            for ncomp=1:length(Xobj.CnodeTypes)
                assert(ismember(Xobj.CnodeTypes{ncomp},CallowedType),...
                    'openCOSSAN:FaultTree',...
                    ['The node type ' Xobj.CnodeTypes{ncomp} ' at position ' num2str(ncomp) ' is not allowed'])
                %% Check outputs
                if strcmp(Xobj.CnodeTypes{ncomp},'Output') 
                    assert(Xobj.VnodeConnections(ncomp)==0,'openCOSSAN:FaultTree',...
                        'The output node can not be attached to 0')
                end
            end
            
            % Check the validity of the fault tree
            assert(Xobj.NbasicEvents>1,'openCOSSAN:FaultTree',...
                    'The Fault tree must contain more the 1 basic event')
                
            % Check the top event is defined at the first position
            assert(strcmp(Xobj.CnodeTypes{1},'Output'),'openCOSSAN:FaultTree',...
                    'The TOP EVENT must be defined as first event')     

        end % constructor
        
        disp(Xobj)
        
        Xobj=addNodes(Xobj,varargin) % Add more nodes to the FaultTree
        
        Xobj=removeNodes(Xobj,varargin) % Remove nodes from the FaultTree
                
        [Xobj,varargout]=findCutSets(Xobj,varargin) % Identify cut-sets of 
                                                    % the FaultTree         
                                                    
        [Xobj,varargout]=findMinimalCutSets(Xobj,varargin) % Identify the 
                                        % Minimal Cut-Sets of the FaultTree
         
        varargout=plotTree(Xobj,varargin) % plot the FaultTree in a matlab figure
        
        function Ccomponents = get.Ccomponents(Xobj)
            % This function should return only the name of the components (i.e.
            % inputs)
            
            Ccomponents=Xobj.CnodeNames(strcmp(Xobj.CnodeTypes,'Input'));
            Ccomponents=unique(Ccomponents);
            
%             for i=1:length(Xobj.CnodeNames)
%                 if ~isempty(Xobj.CnodeNames{i})
%                     if ~exist('Cnames','var')
%                         Cnames=Xobj.CnodeNames(i);
%                     elseif ~any(strcmpi(Xobj.CnodeNames{i},Cnames))
%                         Cnames{end+1}=Xobj.CnodeNames{i}; %#ok<AGROW>
%                     end
%                 end
%             end
%             Ccomponents=Cnames;
            
        end % ModuluCnodeTypess get method
        
        function NbasicEvents = get.NbasicEvents(Xobj)
            NbasicEvents=length(find(strcmp(Xobj.CnodeTypes,'Input')==1));
        end
    end
end
