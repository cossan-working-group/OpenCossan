classdef EvolutionStrategy < opencossan.optimization.Optimizer
    %   Evolution Strategies is a gradient-free optimization algorithm that
    %   performs a stochastic search in the space of the design variables.
    
    %%  Properties of the object
    properties % Public access
        Nmu         = 10            %number of individuals in parent population
        Nlambda     = 100           %Number of individuals in offspring population
        Nrho        = 2             %Number of individuals chosen for recombination, i.e. construction of intermediate parent
        Srecombination = 'discrete' %Recombination strategy to be used. Available options are 'discrete' and 'intermediate'; pass as a string
        Vsigma      = 2             %Standard deviation for performing mutation; Vsigma is the strategy parameter of the continuous design variables
        Sselection  = '+'           %Scheme chosen for performing the selection steps. Two options are available: '+' implies that the selection is performed  considering both the parents and offspring while ',' implies that the selection is based in the offspring population; pass as a string
    end
    %%   Methods inherited from the superclass
    methods
        varargout    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
                
        function Xobj   = EvolutionStrategy(varargin)
            %EvolutionStrategies   Constructor function for a
            %EvolutionStrategies object
            %
            %
            %   Evolution Strategies is a gradient-free optimization algorithm
            %   that performs a stochastic search in the space of the design
            %   variables. 
            % 
            % Evolution Strategies solves unconstrained problems defined as
            % follow:
            %
            %           min f_obj(x) x in R^n
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/@EvolutionStrategy
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
            Xobj.Sdescription   = 'EvolutionStrategies object';
            Xobj.Nmax           = 1e5;
            
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
                            error('openCOSSAN:EvolutionStrategy',...
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
                    case  'srecombination'
                        assert(ismember(varargin{k+1},{'discrete' 'intermediate'}), ...
                            'openCOSSAN:EvolutionStrategy', ...
                            'Available options for Srecombination are ''discrete'' or ''intermediate''')
                        Xobj.Srecombination=varargin{k+1};
                    case  'sselection'
                        assert(ismember(varargin{k+1},{'+' ','}), ...
                            'openCOSSAN:EvolutionStrategy', ...
                            'Available options for Sselection are ''+'' or '',''')
                        Xobj.Srecombination=varargin{k+1};
                    case  'vsigma'
                        Xobj.Vsigma=varargin{k+1};
                    case  'toleranceobjectivefunction'
                        Xobj.toleranceObjectiveFunction=varargin{k+1};
                    case  'tolerancedesignvariables'
                        Xobj.toleranceDesignVariables=varargin{k+1};
                    otherwise
                        warning('openCOSSAN:EvolutionStrategy',...
                            ['PropertyName ' varargin{k} ' not valid ']);
                end

            end % input check

            %% Validate Inputs 
            assert(Xobj.Nrho<=Xobj.Nmu, ...
                  'openCOSSAN:EvolutionStrategy', ...
                  'Number of individuals chosen for the recombination (%i) must be lower or equal to the population size (%i)', ...
                  Xobj.Nrho,Xobj.Nmu);

        end % constructor
    end % methods
    
    methods (Access=private)
        Moffspring = recombination(Xobj,Mparents) % Recombine the individuals
        Moffspring = mutation(Xobj,Mparents)      % Perform random mutation 
        Mparents   = selection(Xobj,Mparents,Moffspring) % Perform selection
    end
end % classdef

