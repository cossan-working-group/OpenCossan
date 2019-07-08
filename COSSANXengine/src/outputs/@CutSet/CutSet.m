classdef CutSet
    % CutSet This class define thw CutSet Output object.
    % The object might contain the FailureProbability object, the
    % DesignPoint object of the set of components that form the cut-set
    
    properties (SetAccess = protected) % Public get access
        XFailureProbability       % FailureProbability object
        XDesignPoint              % DesignPoint object of the cutset
        XFaultTree                % FaultTree
        SFaultTreeName            % Name of FaultTree Object
        Mcutset                   % failure probability associated to each batch
        VcutsetIndex              % Indeces of the components that form the cut-set
        lowerBound                % Lower bound of the failure probability of the cutset
        upperBound                % Upper bound of the failure probability of the cutset
        VfailureProbabilityEvents % Failure probability of the basic events
        MDesignPointStdNormalEvents % Coordinates of the desing point of each basic event
        Mpf2                      % Matrix that contains the cross probability
    end
    
    
    properties  % Public  access
        Sdescription              % Description of the object
    end
    
    properties  (Dependent) % Dependent Field
        failureProbability         % Failure Probability of the cutset
        kappa                      % Kappa value for the cut set
    end
    
    methods
        
        %% constructor
        function Xobj=CutSet(varargin)
            % This method initialize the CutSet object
            %
            % Please see the Reference Manual for more detailed information
            %
            % Usage
            %  Xcs=CutSet('VcutSetIndex',[1 4 5]);
            %  Xcs=CutSet('VcutSetIndex',[1 4 5],'XFaultTree',FaultTreeObject);
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@CutSet
            %
            % Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
            % Author: Edoardo-Patelli
            
            
            if nargin==0
                % Create an empty object
                return
            end
            
            %% Validate input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'xfaulttree'}
                        if isa(varargin{k+1},'FaultTree')
                            Xobj.XFaultTree=varargin{k+1};
                            Xobj.SFaultTreeName=inputname(k+1);
                        else
                            error('openCOSSAN:output:CutSet',...
                                [' The object passed after the PropertyName '...
                                ' XFaultTree must be a FaultTree object']);
                        end
                    case {'xdesignpoint','xdesignpoints'}
                        if isa(varargin{k+1},'DesignPoint')
                            Xobj.XDesignPoint=varargin{k+1};
                        else
                            error('openCOSSAN:output:CutSet',...
                                [' The object passed after the PropertyName '...
                                ' XDesignPoint must be a DesignPoint object']);
                        end
                    case {'xfailureprobability'}
                        if isa(varargin{k+1},'FailureProbability')
                            Xobj.XFailureProbability=varargin{k+1};
                        else
                            error('openCOSSAN:CutSet',...
                                [' The object passed after the PropertyName '...
                                ' XFailureProbability must be a FailureProbability object']);
                        end
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'mcutset'}
                        Xobj.Mcutset=varargin{k+1};
                        Xobj.VcutsetIndex=find(dec2bin(Xobj.Mcutset)=='1');
                    case {'lowerbound'}
                        Xobj.lowerBound=varargin{k+1};
                    case {'upperbound'}
                        Xobj.upperBound=varargin{k+1};
                    case {'vcutsetindex'}
                        Xobj.VcutsetIndex=varargin{k+1};
                    case {'vfailureprobabilityevents'}
                        Xobj.VfailureProbabilityEvents=varargin{k+1};
                    case {'mdesignpointstdnormalevents'}
                        Xobj.MDesignPointStdNormalEvents=varargin{k+1};
                    case {'mpf2'}
                        Xobj.Mpf2=varargin{k+1};
                    otherwise
                        error('openCOSSAN:CutSet',...
                            'Input argument %s is not allowed',varargin{k})
                end
            end
            
            %% Check inputs
            if isempty(Xobj.VcutsetIndex)
                error('openCOSSAN:output:CutSet',...
                    'It is necessary to define the VcutsetIndex to construct a CutSet object')
            end
            
            if ~isempty(Xobj.Mpf2)
                assert(size(Xobj.Mpf2,1)==length(Xobj.VcutsetIndex) && size(Xobj.Mpf2,2)==length(Xobj.VcutsetIndex),...
                'openCOSSAN:CutSet:computeBounds',...
                strcat('Mpf2 must be a square matrix equal to the number of events', ...
                ' defined in the cut-set (%i)'),length(Xobj.VcutsetIndex));
            end
        end
        
        %% Other methods
        display(Xobj);                  % Display method
        
        [Xobj varargout]=computeBounds(Xobj,varargin) % Estimate the bounds of the cutset
        
        %% Dependent methods
        function failureProbability=get.failureProbability(Xobj)
            if isempty(Xobj.XFailureProbability)
                failureProbability=prod(Xobj.VfailureProbabilityEvents);
            else
                failureProbability=Xobj.XFailureProbability.pfhat;
            end
        end
        
        function kappa=get.kappa(Xobj)
            if isempty(Xobj.MDesignPointStdNormalEvents)
                kappa=[];
            else                
                Malpha=zeros(size(Xobj.MDesignPointStdNormalEvents));
                 for n=1:size(Xobj.MDesignPointStdNormalEvents,1)
                    Malpha(n,:)=Xobj.MDesignPointStdNormalEvents(n,:)/norm(Xobj.MDesignPointStdNormalEvents(n,:)); 
                 end
                kappa=sqrt(det(Malpha*Malpha'));
            end
        end
        
    end % end method
    
    
end

