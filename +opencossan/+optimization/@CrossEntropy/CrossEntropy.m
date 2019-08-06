classdef CrossEntropy < opencossan.optimization.Optimizer
    %   Cross Entropy is a gradient-free unconstrained optimization algorithm
    %   based in stochastic search; if parameters of the model are tuned
    %   correctly, the solution provided by CE may correspond to the global
    %   optimum.
    
    %% Properties of the object
    properties % Public access
        NFunEvalsIter   = 100   %Number of Function Evaluations per Iteration
        NUpdate         = 20    %Number of samples per iteration used to update the associated stochastic problem
        tolSigma        = 0.001 %Termination tolerance on the standard deviation of the associated stochastic problem (scalar)
    end
    %% 2.    Methods inherited from the superclass
    methods
        varargout    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
        
        function Xobj   = CrossEntropy(varargin)
            %CROSSENTROPY   Constructor function for class CrossEntropy
            %
            %   CE  Gradient-free unconstrained optimization algorithm based in
            %       stochastic search; if parameters of the model are tuned correctly,
            %       the solution provided by CE may correspond to the global optimum.
            %       This algorithm solves the problem:
            %
            %           min f_obj(x)
            %                x in R^n
            %   REFERENCES:
            %
            %   (1) De Boer, P-T., Kroese, D.P, Mannor, S. and Rubinstein, R.Y. (2005).
            %   A Tutorial on the Cross-Entropy Method. Annals of Operations Research,
            %   134 (1), 19--67.
            %   (2) Wikipedia (http://en.wikipedia.org/wiki/Cross-entropy_method) for a
            %   quick overview
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/@CrossEntropy
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
            Xobj.Sdescription   = 'CrossEntropy object';
            Xobj.Nmax           = 1e5;
            
            % Process input arguments
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case  {'nmax' 'nmaxmodelevaluations'}
                        Xobj.Nmax=varargin{k+1};
                    case 'lintermediateresults'
                        Xobj.Lintermediateresults=varargin{k+1};
                    case  'scalingfactor'
                        Xobj.scalingFactor=varargin{k+1};
                    case  'timeout'
                        Xobj.timeout=varargin{k+1};
                    case  'xjobmanager'
                        Xobj.XjobManager=varargin{k+1};
                    case  {'nmaxiteration','nmaxiterations'}
                        Xobj.NmaxIterations=varargin{k+1};
                    case 'nfunevalsiter'
                        Xobj.NFunEvalsIter=varargin{k+1};
                    case  'nupdate'
                        Xobj.NUpdate=varargin{k+1};
                    case  'tolsigma'
                        Xobj.tolSigma=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.RandomNumberGenerator = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        if isa(varargin{k+1},'RandStream'),
                            Xobj.XrandomNumberGenerator  = varargin{k+1};
                        else
                            error('openCOSSAN:CrossEntropy',...
                                ['argument associated with (' varargin{k} ') is not a RandStream object']);
                        end
                    otherwise
                        error('openCOSSAN:CrossEntropy:wrongInputArgument',...
                            'PropertyName %s is not valid input argument ', varargin{k} );
                end
            end % input check
        end % constructor
    end % methods
end % classdef
