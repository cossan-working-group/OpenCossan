classdef SystemReliability
    %SYSTEMRELIABILITY This object is a collector of different
    %ProbabilisticModel with the assiciate FaultTree and CutSet objects
    %   Detailed explanation goes here
    
    properties
        Sdescription          % Description of the SystemReliability object
        Mdp_u                 % design point of the Mmcs
        Vbeta                 % design point of the Mmcs
    end
    
    properties (SetAccess = protected)
        Cnames                  % names of the Components Objects
        Xmodel                  % Physical Model objects (Only 1 Physical model can currently be hanlded)
        XperformanceFunctions   % Performance function Objects
        XFaultTree              % FaultTree object
        XdesignPoints           % Design points of each member
        XfailureProbability     % FailureProbability of each basic event
    end
    
    properties (Dependent)
        VfailureProbabilityBasicEvents % Failure probability assiciated to the basic events
        NperformanceFunctions           % Number of PerformanceFunction defined
    end
    
    %% Public methods
    methods
        
        Xo=apply(Xobj,varargin) % This method perform the simulation of the
        % SystemReliability
        
        Xobj=designPointIdentification(Xobj,varargin) % Identify the
        % DesignPoint of the base components defined in the SystemReliability
        % object
        
        % Identify the intersection between linear limit state functions
        [varargout] = findLinearIntersection(Xobj,varargin)
        
        [varargout] = findIntersection(Xobj,varargin) % Identify the
        % intersection between limit state functions  that form a specific
        % cut-set. This method linearize the limit state functions iteratively
        % around the intersection point (identified by means of the method
        % findLinearIntersection.
        
        varargout=pf(Xobj,varargin) % Compute the failure probability of the minimal cut sets.
        
        [Xobj varargout]=pfComponents(Xobj,varargin); % Compute the failureprobability of
        % each component defined in the SystemReliability object.
        
        [Xcutset varargout] = pfLinearIntersection(Xobj,varargin); % Compute pf
        % associate to the intersection between 2 linearized performance
        % functions. This methods is mainly used to estimate the bounds of
        % the cut-sets
        
        [Xcutset varargout] = computeBounds(Xobj,varargin); % Compute the bounds of
        % the cut-sets. Can be used to estimate the first order and second
        % order of the bound of the defined cut-set(s).
        
        display(Xobj)  % This method shows the summary of the SystemReliability object
        
        Xcutset = getCutset(Xobj,varargin); % Retrieve CutSet from the SystemReliability object
        
        
        %% constructor
        function Xobj= SystemReliability(varargin)
            % SYSTEMRELIABILITY This method is used to construct an object of
            % type SystemReliability. It contains a model and a number of
            % different PerformanceFucntion.
            %
            % See Also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@SystemReliability
            %
            % Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
            % Author: Edoardo-Patelli
            
            % Allows construction empty object
            if nargin==0
                return
            end
            
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'xfaulttree','cxfaulttree'}
                        if iscell(varargin{k+1})
                            Xobj.XFaultTree=varargin{k+1}{1};
                        else
                            Xobj.XFaultTree=varargin{k+1};
                        end
                        assert(isa(Xobj.XFaultTree,'FaultTree'),...
                            'openCOSSAN:SystemReliability',...
                            'An object of type %s is not valid after the PropertyName %s', ...
                            class(Xobj.XFaultTree),varargin{k});
                    case {'cmembers','cprobabilisticmodelnames'}
                        Xobj.Cnames=varargin{k+1};
                    case {}
                        assert(isa(varargin{k+1}(1),'PerformanceFunction'),...
                            'openCOSSAN:SystemReliability',...
                            ['An object PerformanceFunction is required after the PropertyName ' varargin{k} ]);
                        Xobj.XperformanceFunctions=varargin{k+1};
                    case {'cxperformancefunctions','xperformancefunctions'}
                        if iscell(varargin{k+1})
                            Xobj.XperformanceFunctions=varargin{k+1}{1};
                            for n=2:length(varargin{k+1})
                                Xobj.XperformanceFunctions(n)=varargin{k+1}{n};
                            end
                        else
                            Xobj.XperformanceFunctions=varargin{k+1};
                        end
                        
                        assert(isa(Xobj.XperformanceFunctions(1),'PerformanceFunction'),...
                            'openCOSSAN:SystemReliability',...
                            'An object of type %s at position %i is not valid after the PropertyName %s', ...
                            class(Xobj.XFaultTree),1,varargin{k});
                        
                    case {'xmodel','cxmodel'}
                        if iscell(varargin{k+1})
                            Xobj.Xmodel=varargin{k+1}{1};
                        else
                            Xobj.Xmodel=varargin{k+1};
                        end
                        
                        assert(isa(Xobj.Xmodel,'Model'),...
                            'openCOSSAN:SystemReliability',...
                            'An object of type %s is not valid after the PropertyName %s', ...
                            class(Xobj.Xmodel),varargin{k});
                    otherwise
                        error('openCOSSAN:SystemReliability',...
                            'Property Name %s is not allowed',varargin{k});
                end
            end
            
            %% Validate constructor
            assert(~isempty(Xobj.XFaultTree), ...
                'openCOSSAN:reliability:SystemReliability', ...
                'A FaultTree object is required to define SystemReliability object')
            
            assert(~isempty(Xobj.Cnames), ...
                'openCOSSAN:reliability:SystemReliability', ...
                'Names of the performance functions are required')
            
            assert(~isempty(Xobj.XperformanceFunctions), ...
                'openCOSSAN:reliability:SystemReliability', ...
                'Performance functions objects are required')
            
            assert(~isempty(Xobj.Xmodel), ...
                'openCOSSAN:reliability:SystemReliability', ...
                'A model object is required')
            
        end % constructor
        
        
        function VfailureProbabilityBasicEvents=get.VfailureProbabilityBasicEvents(Xobj)
            % Failure Probability associated with each basic event
            VfailureProbabilityBasicEvents=zeros(length(Xobj.XfailureProbability),1);
            for n=1:length(VfailureProbabilityBasicEvents)
                VfailureProbabilityBasicEvents(n)=Xobj.XfailureProbability(n).pfhat;
            end
        end
        
        function NperformanceFunctions=get.NperformanceFunctions(Xobj)
            % Number of PerformanceFunction defined
            NperformanceFunctions=length(Xobj.XperformanceFunctions);
        end
    end % end method
    
    
    
    methods (Access = private)
        
        function Cmcs=getMinimalCutSets(Xsys)
            % Private function to retrieve Minimal Cut Set from the
            % FaultTree
            
            if ~isempty(Xsys.XFaultTree)
                Cftmcs = Xsys.XFaultTree.CminimalCutSets;
                if ~isempty(Cftmcs)
                    % Associate position of the minimal cut set and the objects defined in
                    % the SystemReliability object
                    for ics=1:size(Cftmcs,1)
                        Vindex=zeros(length(Cftmcs{ics}),1);
                        for n=1:length(Vindex)
                            ind=find(strcmp(Cftmcs{ics}{n},Xsys.Cnames));
                            if ~isempty(ind)
                                Vindex(n)=ind;
                            else
                                error('openCOSSAN:reliability:SystemRaliabiliy:getMinimalCutSets',...
                                    ['The object ' Cftmcs{ics}{n} ' is not present in the SystemReliability object']);
                            end
                        end
                        Cmcs{ics}=Vindex; %#ok<AGROW>
                    end
                else
                    Cmcs=[];
                end
            else
                Cmcs=[];
            end
        end
    end
end

