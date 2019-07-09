classdef MiniMax < opencossan.optimization.Optimizer
    %  MiniMax class is intended for solving an multi-objective optimization
    %  problems.
    %% Properties of the object
    properties % Public access
        finiteDifferencePerturbation    = 0.001 %Perturbation for performing finite differences (required for gradient estimation)
        SfiniteDifferenceType = 'forward'       % 'forward' or 'central' finite difference
    end
    
    properties (Constant)
        CfiniteDifferenceType={'forward' 'central' }
    end
    
    
    %% Methods inherited from the superclass
    methods
        varargout    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
        
        function Xobj   = MiniMax(varargin)
            %MiniMax Constructor function for class MiniMax
            %         This is the contructor for class MiniMax. It is intended
            %               for solving an multi-objective optimization problems
            %               using gradients of the objective function and
            %               constraints. MiniMax minimizes the worst-case value
            %               of a set of multivarable function starting at an
            %               initial estimated.
            %
            %               MiniMax is intended for solving the following class
            %               of problems
            %
            %               min_x max_i   f_i(x)
            %               subject to
            %               ceq(x)      =  0
            %               cineq(x)    <= 0
            %               lb <= x <= ub
            %
            % See Also:
            % http://cossan.cfd.liv.ac.uk/wiki/addIteration@MiniMax
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
            % =====================================================================
            % This file is part of openCOSSAN.  The open general purpose matlab
            % toolbox for numerical analysis, risk and uncertainty quantification.
            %
            % openCOSSAN is free software: you can redistribute it and/or modify
            % it under the terms of the GNU General Public License as published by
            % the Free Software Foundation, either version 3 of the License.
            %
            % openCOSSAN is distributed in the hope that it will be useful,
            % but WITHOUT ANY WARRANTY; without even the implied warranty of
            % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
            % GNU General Public License for more details.
            %
            %  You should have received a copy of the GNU General Public License
            %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
            % =====================================================================
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set predefined values
            Xobj.Sdescription   = 'MiniMax object';
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
                            error('openCOSSAN:optimization:CrossEntropy',...
                                ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end
                    case 'finitedifferenceperturbation'
                        Xobj.finiteDifferencePerturbation=varargin{k+1};
                        
                    case 'sfinitedifferencetype'
                        assert(ismember(varargin{k+1},Xobj.CfiniteDifferenceType), ...
                            'openCOSSAN:MiniMax', ...
                            strcat('Available options for SfiniteDifferenceType are: ',sprintf('%s ', Xobj.CfiniteDifferenceType{:})))
                        Xobj.SfiniteDifferenceType=varargin{k+1};
                    case  'toleranceobjectivefunction'
                        Xobj.toleranceObjectiveFunction=varargin{k+1};
                    case  'toleranceconstraint'
                        Xobj.toleranceConstraint=varargin{k+1};
                    case  'tolerancedesignvariables'
                        Xobj.toleranceDesignVariables=varargin{k+1};
                    otherwise
                        error('openCOSSAN:SequentialQuadraticProgramming',...
                            ['PropertyName ' varargin{k} ' not valid ']);
                end
            end % input check
        end % constructor
    end % methods
end % classdef
