classdef Cobyla < opencossan.optimization.Optimizer
    %   COBYLA      COBYLA is intended
    %               for solving an optimization problem using the gradient-free
    %               algorithm COBYLA. When generating the constructor, it is
    %               possible to select the parameters of the optimization
    %               algorithm. It should be noted that default parameters are
    %               provided for the algorithm; nonetheless,
    %               the user should always check whether or not a particular
    %               set of parameters is appropriate for the problem at hand. A
    %               poor selection on these parameters may prevent finding the
    %               correct solution.
    %% 1.   Properties of the object
    properties % Public access
        rho_ini     = 1     %Size of initial Trust Region
        rho_end     = 1e-3  %Size of target Trust Region
    end
    %% 2.    Methods inherited from the superclass
    methods
        varargout    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
       
        
        function Xobj   = Cobyla(varargin)
            %% 3.    Constructor
            %COBYLA    Constructor function for class COBYLA
            %
            %   COBYLA      This is the contructor for class COBYLA; it is intended
            %               for solving an optimization problem using the gradient-free
            %               algorithm COBYLA. When generating the constructor, it is
            %               possible to select the parameters of the optimization
            %               algorithm. It should be noted that default parameters are
            %               provided for the algorithm; nonetheless,
            %               the user should always check whether or not a particular
            %               set of parameters is appropriate for the problem at hand. A
            %               poor selection on these parameters may prevent finding the
            %               correct solution.
            %
            % IMPORTANT: COBYLA will try to make all the values of the
            % constraints positive. Hence a scaling factor -1 is used! 
            %
            %   OUTPUT:
            %   - Xobj      : A Cobyla object
            %
            %   EXAMPLE:
            %
            %   Xobj    = Cobyla('Sdescription','my optimizer','Nmax',1e3);
            %
            %
            % ==================================================================
            % COSSAN-X - The next generation of the computational stochastic analysis
            % University of Innsbruck, Copyright 1993-2011 IfM
            % ==================================================================
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set predefined values
            Xobj.Sdescription   = 'Cobyla object';
            Xobj.Nmax           = 1e3;
            Xobj.scalingFactorConstraints  = -1; % Must be negative 
            
            % Process input arguments
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case  {'nmax','nmaxmodelevaluations','nmaxiterations'}
                        Xobj.Nmax=varargin{k+1};
                    case  'nevaluationsperbatch'
                        Xobj.NEvaluationsPerBatch=varargin{k+1};
                    case  'scalingfactor'
                        Xobj.scalingFactor=varargin{k+1};
                    case  'scalingfactorconstraints'
                        Xobj.scalingFactorConstraints=varargin{k+1};
                    case  'xjobmanager'
                        Xobj.XjobManager=varargin{k+1};
                    case  {'rho_ini','initialtrustregion'}
                        Xobj.rho_ini=varargin{k+1};
                    case  {'rho_end','finaltrustregion'}
                        Xobj.rho_end=varargin{k+1};
                    otherwise
                        warning('openCOSSAN:Cobyla',...
                            'PropertyName %s not valid',varargin{k});
                end
            end
            
            %  Check consistency of Optimization object w.r.t. the
            %trust region
            assert(Xobj.rho_ini>=Xobj.rho_end,...
                'openCOSSAN:Cobyla',...
                ['the size of the final trust region rho_end (' num2str(Xobj.rho_end) ') '...
                'should be smaller than the initial trust region rho_ini (' num2str(Xobj.rho_ini) ' )']);
            
            
            assert(Xobj.scalingFactorConstraints<0,...
                'openCOSSAN:Cobyla:wrongScalingFactor',...
                ['COBYLA will try to make all the values of the constraints positive.' ...
                'So the scaling factor must be negative.\n Defined value: %f'],Xobj.scalingFactor);
            
        end
        
    end
    
end
