classdef StochasticRanking < Optimizer
    %   Stochastic Ranking Evolution Strategies is a gradient-free     
    %   optimization algorithm that performs a stochastic search in the
    %   space of the design variables, subject to non-linear inequality
    %   constraints.
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@StochasticRanking
    
    %%  Properties of the object
    properties % Public access
        Nmu         = 10            %number of individuals in parent population
        Nlambda     = 100           %Number of individuals in offspring population
        Nrho        = 2             %Number of individuals chosen for recombination, i.e. construction of intermediate parent
        probWin    = 0.45          %Probability of an individual of winning a rank exchange because of fitness comparison
        Srecombination = 'discrete' %Recombination strategy to be used. Available options are 'discrete' and 'intermediate'; pass as a string
        Vsigma                      %Standard deviation for performing mutation; Vsigma is the strategy parameter of the continuous design variables
    end
    %%   Methods inherited from the superclass
    methods
        varargout    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
                
        function Xobj   = StochasticRanking(varargin)
            %StochasticRanking   Constructor function for class
            %StochasticRanking
            %
            %   Stochastic Ranking Evolution Strategies
            %
            %   Stochastic Ranking  Evolution Strategies is a gradient-free
            %   optimization algorithm that performs a stochastic search in
            %   the space of the design variables and subject to a set of
            %   inequality constraints. Stochastic Ranking Evolution
            %   Strategies solves the problem:
            %
            %                       min     f_obj(x)
            %                       subject to
            %                               cineq(x)    <= 0
            %                               lb <= x <= ub
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@StochasticRanking
            %
            % =========================================================================
            % COSSAN-X - The next generation of the computational stochastic analysis
            % University of Liverpool, Copyright 1993-2012 
            % =========================================================================
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set predefined values
            Xobj.Sdescription   = 'StochasticRanking object';
            Xobj.Nmax           = 2000;
            
            % Process input arguments
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case  {'nmax','nmaxmodelevaluations'}
                        Xobj.Nmax=varargin{k+1};
                    case 'lintermediedresults'
                        Xobj.Lintermediedresults=varargin{k+1};
                    case  'scalingfactor'
                        Xobj.scalingFactor=varargin{k+1};
                    case  'timeout'
                        Xobj.timeout=varargin{k+1};
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
                            error('openCOSSAN:StochasticRanking',...
                              ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end   
                    case 'deltaobjectivefunction'
                        Xobj.deltaObjectiveFunction=varargin{k+1};
                    case 'nmu'
                        Xobj.Nmu=varargin{k+1};
                    case  'nlambda'
                        Xobj.Nlambda=varargin{k+1};
                    case 'nrho'
                        Xobj.Nrho=varargin{k+1};
                    case 'probwin'
                        if (varargin{k+1}>0) && (varargin{k+1}<=0.5)
                            Xobj.probWin = varargin{k+1};
                        else
                            error('openCOSSAN:StochasticRanking',...
                                strcat('Probability of an individual of winning',...
                                ' a rank exchange because of fitness comparison ',...
                                'must be in the range [0.0 0.5]'))
                        end
                    case  'srecombination'
                        assert(ismember(varargin{k+1},{'discrete' 'intermediate'}), ...
                            'openCOSSAN:StochasticRanking', ...
                            'Available options for Srecombination are ''discrete'' or ''intermediate''')
                        Xobj.Srecombination=varargin{k+1};
                    case  'vsigma'
                        Xobj.Vsigma=varargin{k+1};
                    case  'toleranceobjectivefunction'
                        Xobj.toleranceObjectiveFunction=varargin{k+1};
                    case  'tolerancedesignvariables'
                        Xobj.toleranceDesignVariables=varargin{k+1};
                    otherwise
                        warning('openCOSSAN:StochasticRanking',...
                            ['PropertyName ' varargin{k} ' not valid ']);
                end

            end % input check

            %% Validate Inputs 
            assert(Xobj.Nrho<=Xobj.Nmu, ...
                  'openCOSSAN:StochasticRanking', ...
                  'Number of individuals chosen for the recombination (%i) must be lower or equal to the population size (%i)', ...
                  Xobj.Nrho,Xobj.Nmu);

        end % constructor       
        
    end % methods
    
    methods (Access=private)
        [SexitFlag,xb,Statistics,Gm] = sres(Xobj,objfun,cons,mm,lu,lambda,G,mu,pf,varphi) % directly taken from Philip Runarsson
        [Ldone,SexitFlag]=outputFunction(Xobj,Tstatus); %Export resutls and check termination criteria        
    end
end % classdef

