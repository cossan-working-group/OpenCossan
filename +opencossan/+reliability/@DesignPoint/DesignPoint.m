classdef DesignPoint
    %DesignPoint This class contains the design point associated with a
    %probabilistic model
    %
    % Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
    % Author: Edoardo Patelli
    
    %% Properties of the object
    properties  %Public access
        Sdescription             %description of the object
        NFunctionEvaluations     %number of function evaluations
        XOptimizer               %Optimizer object used to identify design point
        perfomanceAtOrigin       % value of the perfomance function at the origin of the SNS
    end
    
    properties(SetAccess=protected)
        VDesignPointPhysical        % coordinates of the design point in the physical space
        XProbabilisticModel         % ProbabilisticModel object
        XHybridModel                % HybridModel object
        Xinput                      % Input object
    end
    
    properties  (Dependent=true, SetAccess=protected)
        VDesignPointStdNormal           %coordinates of the design point in the standard normal space
        VDirectionDesignPointPhysical   %unit vector containing direction of design point in the physical space
        VDirectionDesignPointStdNormal  %unit vector containing direction of design point in the standard normal space
        ReliabilityIndex                %Euclidean norm of the design point w.r.t. the origin
        form                            % First order reliability
        CnamesRandomVariable            %Name of teh Random Variables
    end
    
    %% Methods of the class
    methods
        Xo = set(Xobj,varargin)  %This method allows setting properties of the Xobj object
        
        disp(Xobj)               %This method shows the summary of the Xobj
        
        
        function Xoutput  = DesignPoint(varargin)
            %% DesignPoint Constructor
            %DesignPoint Constructor of DesignPoint object; this object
            %contains the coordinates of the design point in both the physical
            %and the standard normal space. In addition, it also contains the
            %vector describing the direction of the design point and its
            %Euclidean norm
            %
            %   MANDATORY ARGUMENTS:
            %   - 'XProbabilisticModel' : A ProbabilisticModel object
            %   - 'VDesignPointPhysical' or 'VDirectionDesignPointStdNormal':
            %   coordinates of the design point, either in the physical or the
            %   standard normal space, respectively
            %
            %   OPTIONAL ARGUMENTS:
            %   - Sdescription  : description of the object
            %   - XOptimizer    : Optimizer object used to identify design point
            %   - NFunctionEvaluations  : number of function evaluations
            %   required to identify design point
            %
            %   OUTPUT ARGUMENTS:
            %
            %   Xdp: a DesignPoint object
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@DesignPoint
            %
            % Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo Patelli
            
            if nargin==0
                % Create an empty object
                return
            end
            
            %% Validate input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set values passed by the user
            for ivar=1:2:length(varargin)
                switch lower(varargin{ivar})
                    case 'vdesignpointphysical'
                        %  DesignPoint in physical space
                        Xoutput.VDesignPointPhysical = varargin{ivar+1};    %define design point in physical space
                    case 'vdesignpointstdnormal'
                        % DesignPoint in standard normal space
                        VdpSNS=varargin{ivar+1};
                    case 'xprobabilisticmodel'
                        % Probabilistic model
                        if isa(varargin{ivar+1},'opencossan.reliability.ProbabilisticModel')
                            Xoutput.XProbabilisticModel = varargin{ivar+1};
                            Xoutput.Xinput = Xoutput.XProbabilisticModel.Xinput;
                        else
                            error('openCOSSAN:DesignPoint:DesignPoint',...
                                'field XProbabilisticModel must contain a ProbabilisticModel');
                        end
                    case 'xhybridmodel'
                        % Probabilistic model
                        if isa(varargin{ivar+1},'opencossan.reliability.HybridModel')
                            Xoutput.XHybridModel    = varargin{ivar+1};
                            Xoutput.Xinput=Xoutput.XHybridModel.Xinput;
                        else
                            error('openCOSSAN:DesignPoint:DesignPoint',...
                                'field XHybridModel must contain a HybridModel');
                        end
                    case 'xinput'
                        % Input object
                        if isa(varargin{ivar+1},'opencossan.common.inputs.Input')
                            Xoutput.Xinput=varargin{ivar+1};
                        else
                            error('openCOSSAN:DesignPoint:DesignPoint',...
                                'field Xinput must contain a Input obhect');
                        end
                    case 'sdescription'
                        % Description
                        Xoutput.Sdescription    = varargin{ivar+1};
                    case 'nfunctionevaluations'
                        %  Number of function evaluations
                        Xoutput.NFunctionEvaluations  = varargin{ivar+1};
                    case 'perfomanceatorigin'
                        Xoutput.perfomanceAtOrigin = varargin{ivar+1};
                    case 'xoptimizer'
                        % Optimizer used to solved optimization problem
                        if strcmp(superclasses(varargin{ivar+1}),'opencossan.optimization.Optimizer')   %check whether or not object is an Optimizer
                            Xoutput.XOptimizer  = varargin{ivar+1};
                        else
                            error('openCOSSAN:DesignPoint:DesignPoint',...
                                'the field associated with XOptimizer must contain and Optimizer object');
                        end
                    otherwise
                        error('openCOSSAN:DesignPoint:DesignPoint',...
                             'The Input Argument %s is not valid', varargin{ivar});
                end
            end
            
            % compute the design point in Physical space if necessary
            if exist('VdpSNS','var')
                Xoutput.VDesignPointPhysical= ...
                    Xoutput.Xinput.map2physical(VdpSNS);
            end
            
            %3.3.   Check consistency of the object
            checkConsistency(Xoutput);
            
        end      %of constructor
        
        
        %%  Dependent fields
        function VDirectionDesignPointPhysical = get.VDirectionDesignPointPhysical(Xobj)
            VDirectionDesignPointPhysical   = Xobj.VDesignPointPhysical/...
                norm(Xobj.VDesignPointPhysical);
        end
        %%  Function for getting direction of design point in standard
        %%  normal space
        function VDirectionDesignPointStdNormal = get.VDirectionDesignPointStdNormal(Xobj)
            VDirectionDesignPointStdNormal   = Xobj.VDesignPointStdNormal/...
                norm(Xobj.VDesignPointStdNormal);
        end
        %%  Function for getting Euclidean norm of design point
        function ReliabilityIndex = get.ReliabilityIndex(Xobj)
            ReliabilityIndex   = norm(Xobj.VDesignPointStdNormal);
        end
        %%  Function for getting design point in Standard Normal space
        function VDesignPointStdNormal = get.VDesignPointStdNormal(Xobj)
            VDesignPointStdNormal  =  Xobj.Xinput.map2stdnorm(Xobj.VDesignPointPhysical);
        end
        
        %%  Function for getting the Name of the RandomVariable
        function CnamesRandomVariable = get.CnamesRandomVariable(Xobj)
            CnamesRandomVariable  =  Xobj.Xinput.CnamesRandomVariable;
        end
        
        %%  Function for getting FORM
        function form = get.form(Xobj)
            if Xobj.perfomanceAtOrigin > 0
                form  =  normcdf(-Xobj.ReliabilityIndex);
            else
                form  =  normcdf(Xobj.ReliabilityIndex);
            end
        end
        
    end     %of methods
    % Define private methods
    methods (Access=private)
        checkConsistency(Xobj);
        
    end
end     %of classdef
