classdef BFGS < opencossan.optimization.Optimizer
    % BFFS class is intended for solving unconstrained nonlinear optimization
    % problem using gradients
    
    
    %% Properties of the object
    properties % Public access
        finiteDifferencePerturbation    = 0.001 %Perturbation for performing 
                                                % finite differences (required
                                                % for gradient estimation)
        SfiniteDifferenceType = 'forward'       % Finite differences, used to 
                                                % estimate gradients
    end
    
    %%  Methods inherited from the superclass
    methods
        varargout    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
        
        function Xobj   = BFGS(varargin)
            %BFGS   Constructor function for optimizer BFGS
            %
            %   
            %
            % =========================================================================
            % COSSAN-X - The next generation of the computational stochastic analysis
            % University of Innsbruck, Copyright 1993-2011 IfM
            % =========================================================================
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set predefined values
            Xobj.Sdescription   = 'BFGS object';
            Xobj.Nmax           = 1e3;
            
            % Process input arguments
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case  {'nmax','nmaxmodelevaluations'}
                        Xobj.Nmax=varargin{k+1};
                    case 'lintermediateresults'
                        Xobj.Lintermediateresults=varargin{k+1};
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
                        assert(isa(varargin{k+1},'RandStream'),...
                            'openCOSSAN:optimization:BFGS',...
                            'RandStream object expected after property name %s',varargin{k})
                        
                            Xobj.XrandomNumberGenerator  = varargin{k+1};    
                    case 'finitedifferenceperturbation'
                        Xobj.finiteDifferencePerturbation=varargin{k+1};
                    case 'sfinitedifferencetype'
                        CallowedValues={'forward','central'};
                        assert(ismember(varargin{k+1},CallowedValues),...
                              'openCOSSAN:optimization:BFGS',...
                              'Value %s not valid\nValid SfiniteDifferenceType are: ''%s'' and ''%s'' ', ...
                              varargin{k+1},CallowedValues{1},CallowedValues{2})
                        Xobj.SfiniteDifferenceType=varargin{k+1};
                    case  'timeout'
                        Xobj.timeout=varargin{k+1};
                    case  'toleranceobjectivefunction'
                        Xobj.toleranceObjectiveFunction=varargin{k+1};
                    case  'tolerancedesignvariables'
                        Xobj.toleranceDesignVariables=varargin{k+1};
                    otherwise
                        warning('OpenCossan:BFGS',...
                            'PropertyName %s  not valid ',varargin{k});
                end
            end % input check
        end % constructor
    end % methods
end % classdef
