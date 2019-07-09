classdef Simplex < opencossan.optimization.Optimizer
    %SIMPLEX The simplex class define the optimizator SIMPLEX to solve
    % unconstrained nonlinear problems  using a gradients free method 
    
      
    %%  Methods
    methods
        varargout    = apply(Xobj,varargin)  % This method perform the simulation
                                             % adopting the Xobj
        
        function Xobj   = Simplex(varargin)
            %SIMPLEX    Constructor function for class Simplex
            %
            %   
            %
            %   Simplex method is intended for solving unconstrained nonlinear
            %   problem  using a gradinet free method. 
            %
            % =========================================================================
            % COSSAN-X - The next generation of the computational stochastic analysis
            % University of Innsbruck, Copyright 1993-2011 IfM
            % =========================================================================
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set predefined values
            Xobj.Sdescription   = 'Simplex object';
            Xobj.Nmax           = 1e3;
            
            % Process input arguments
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case  {'nmax','nmaxmodelevaluations'}
                        Xobj.Nmax=varargin{k+1};
                    case  'scalingfactor'
                        Xobj.scalingFactor=varargin{k+1};
                    case  'xjobmanager'
                        Xobj.XjobManager=varargin{k+1};
                    case  'nmaxiterations'
                        Xobj.NmaxIterations=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.RandomNumberGenerator = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        if isa(varargin{k+1},'RandStream'),
                            Xobj.XrandomNumberGenerator  = varargin{k+1};    
                        else
                            warning('openCOSSAN:optimization:CrossEntropy',...
                              ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end  
                    case  'toleranceobjectivefunction'
                        Xobj.toleranceObjectiveFunction=varargin{k+1};
                    case  'tolerancedesignvariables'
                        Xobj.toleranceDesignVariables=varargin{k+1};
                    otherwise
                        warning('openCOSSAN:Simplex',...
                            ['PropertyName ' varargin{k} ' not valid ']);
                end
            end % input check
        end % constructor
    end % methods
end % classdef
