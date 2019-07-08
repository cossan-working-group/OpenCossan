classdef SequentialQuadraticProgramming < Optimizer
    %               SequentialQuadraticProgrammingis intended
    %               for solving an optimization problem using gradients of the
    %               objective function and constraints.
    %% 1.   Properties of the object
    properties % Public access
        finiteDifferencePerturbation    = 0.001 %Perturbation for performing finite differences (required for gradient estimation)
        SfiniteDifferenceType = 'forward' % Finite differences, used to estimate gradients,
    end
    
    %%  Methods 
    methods
        varargout    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
        
        function Xobj   = SequentialQuadraticProgramming(varargin)
            %SEQUENTIALQUADRATICPROGRAMMING    Constructor function for class
            %                                   SequentialQuadraticProgramming
            %
            %   SequentialQuadraticProgramming
            %               This is the contructor for class
            %               SequentialQuadraticProgramming; it is intended
            %               for solving an optimization problem using gradients of the
            %               objective function and constraints. When generating the
            %               constructor, it is possible to select the parameters of
            %               the optimization algorithm. It should be noted that default
            %               parameters are provided for the algorithm; nonetheless,
            %               the user should always check whether or not a particular
            %               set of parameters is appropriate for the problem at hand. A
            %               poor selection on these parameters may prevent finding the
            %               correct solution.
            %
            %               SequentialQuadraticProgramming is intended for solving
            %               the following class of problems
            %
            %                       min     f_obj(x)
            %                       subject to
            %                               ceq(x)      =  0
            %                               cineq(x)    <= 0
            %                               lb <= x <= ub
            
            % =========================================================================
            %% COSSAN-X - The next generation of the computational stochastic analysis
            % University of Innsbruck, Copyright 1993-2011 IfM
            % =========================================================================
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set predefined values
            Xobj.Sdescription   = 'SequentialQuadraticProgramming object';
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
                        if isa(varargin{k+1},'RandStream'),
                            Xobj.XrandomNumberGenerator  = varargin{k+1};    
                        else
                            error('openCOSSAN:SequentialQuadraticProgramming',...
                              ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end  
                    case 'finitedifferenceperturbation'
                        Xobj.finiteDifferencePerturbation=varargin{k+1};
                     case 'sfinitedifferencetype'
                        CallowedValues={'forward','central'};
                        assert(ismember(varargin{k+1},CallowedValues),...
                              'openCOSSAN:SequentialQuadraticProgramming',...
                              'Value %s not valid\nValid SfiniteDifferenceType are: ''%s'' and ''%s'' ', ...
                              varargin{k+1},CallowedValues{1},CallowedValues{2})
                        Xobj.SfiniteDifferenceType=varargin{k+1};
                    case  'toleranceobjectivefunction'
                        Xobj.toleranceObjectiveFunction=varargin{k+1};
                    case  'toleranceconstraint'
                        Xobj.toleranceConstraint=varargin{k+1};
                    case  'tolerancedesignvariables'
                        Xobj.toleranceDesignVariables=varargin{k+1};
                    otherwise
                        warning('openCOSSAN:SequentialQuadraticProgramming',...
                            ['PropertyName ' varargin{k} ' not valid ']);
                end
            end % input check
        end % constructor
    end % methods
end % classdef
