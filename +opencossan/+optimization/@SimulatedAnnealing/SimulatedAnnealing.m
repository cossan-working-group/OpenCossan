classdef SimulatedAnnealing < opencossan.optimization.Optimizer
    %   SimulatedAnnealing (SA) is a gradient-free optimization method. SA can
    %   be used to find a MINIMUM of a function.
    %% Properties of the object
    properties % Public access
        k1 = 0.9   % 1st parameter for the annealing strategy (for temperatureCossan)
        k2 = 1     % 2nd parameter for the annealing strategy (for temperatureCossan)
        k3 = 0     % 3rd parameter for the annealing strategy (for temperatureCossan)
        Vsigma              % Parameter of the annealingCossan function
        initialTemperature   = 100  % Initial Temperature
        NreannealInterval    = 100  % number of moves required to update the T
        StemperatureFunction = 'temperatureexp'  % Temperature function
        SannealingFunction = 'annealingboltz'    % Function used to generate new solution  for the next iteration.
        Nmaxmoves   = 2000    %Maximum number of moves without improvement
    end
    
    properties (Hidden,SetAccess = private)
        CtemperatureFunction={'temperatureexp' 'temperaturefast' 'temperatureboltz' 'temperatureCossan'}
        CannealingFunction={'annealinguniform' 'annealingfast' 'annealingboltz' 'annealingCossan'}
    end
    
    %% Methods inherited from the superclass
    methods
        [Xoptimum,varargout]= apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
        [Lstop,Toptions,Loptchanged] = outputFunction(XOptimizer,Toptions,optimvalues,Sflag)
                
        function Xobj   = SimulatedAnnealing(varargin)
            %% Constructor
            %SimulatedAnnealing    Constructor function for class SimulatedAnnealing
            %
            %   SimulatedAnnealing      This is the contructor for class the
            %               SimulatedAnnealing; Simulated Annealing (SA) can be used to
            %               find a MINIMUM of a function. It is intended for solving
            %               the problem
            %
            %                       min f_obj(x)
            %                       x in R^n
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SimultatedAnnealing
            %
            % Copyright~1993-2011,COSSAN Working Group, University~of~Innsbruck, Austria
            % Author: Edoardo Patelli
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set predefined values
            Xobj.Sdescription   = 'SimulatedAnnealing object';
            
            % Process input arguments
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    % From the super-class
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case  {'nmax','nmaxmodelevaluations'}
                        Xobj.Nmax=varargin{k+1};
                    case 'nmaxiterations'
                        Xobj.NmaxIterations=varargin{k+1};
                    case  'timeout'
                        Xobj.timeout=varargin{k+1};
                    case  'objectivelimit'
                        Xobj.objectiveLimit=varargin{k+1};
                    case  'toleranceobjectivefunction'
                        Xobj.toleranceObjectiveFunction=varargin{k+1};
                    case  'tolerancedesignvariables'
                        Xobj.toleranceDesignVariables=varargin{k+1};
                    case 'lintermediateresults'
                        Xobj.Lintermediateresults=varargin{k+1};
                    case  'scalingfactor'
                        Xobj.scalingFactor=varargin{k+1};
                    case  'penaltyfactor'
                        Xobj.penaltyFactor=varargin{k+1};
                    case  'xjobmanager'
                        Xobj.XjobManager=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.RandomNumberGenerator = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        if isa(varargin{k+1},'RandStream')
                            Xobj.XrandomNumberGenerator  = varargin{k+1};
                        else
                            error('openCOSSAN:optimization:SimulatedAnnealing',...
                                ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end
                        % Simulated Annealing properties
                    case  'stemperaturefunction'
                        assert(ismember(varargin{k+1},Xobj.CtemperatureFunction), ...
                            'openCOSSAN:SimulatedAnnealing', ...
                            strcat('Available options for StemperatureFunction are: ',sprintf('%s ', Xobj.CtemperatureFunction{:})))
                        Xobj.StemperatureFunction=varargin{k+1};
                        
                    case  'sannealingfunction'
                        assert(ismember(varargin{k+1},Xobj.CannealingFunction), ...
                            'openCOSSAN:SimulatedAnnealing', ...
                            strcat('Available options for Sannealingfunction are: ',sprintf('%s ',Xobj.CannealingFunction{:})))
                        Xobj.SannealingFunction=varargin{k+1};
                    case  'k1'
                        Xobj.k1=varargin{k+1};
                    case  'k2'
                        Xobj.k2=varargin{k+1};
                    case  'k3'
                        Xobj.k3=varargin{k+1};
                    case  'initialtemperature'
                        Xobj.initialTemperature=varargin{k+1};
                    case  'nreannealinterval'
                        Xobj.NreannealInterval=varargin{k+1};
                    case  'vsigma'
                        Xobj.Vsigma=varargin{k+1};
                    case  'nmaxmoves'
                        Xobj.Nmaxmoves=varargin{k+1};
                    otherwise
                        error('OpenCossan:SimulatedAnnealing',...
                            'PropertyName %s  not valid ',varargin{k});
                end
                
            end % input check
            
            
        end % constructor
    end % methods
end % class
