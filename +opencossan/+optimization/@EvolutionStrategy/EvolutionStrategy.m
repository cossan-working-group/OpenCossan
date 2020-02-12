classdef EvolutionStrategy < opencossan.optimization.Optimizer
    %   Evolution Strategies is a gradient-free optimization algorithm that
    %   performs a stochastic search in the space of the design variables.
    
    properties
        Nmu         = 10            %number of individuals in parent population
        Nlambda     = 100           %Number of individuals in offspring population
        Nrho        = 2             %Number of individuals chosen for recombination, i.e. construction of intermediate parent
        RecombinationStrategy = 'discrete' %Recombination strategy to be used. Available options are 'discrete' and 'intermediate'; pass as a string
        Sigma      = 2             %Standard deviation for performing mutation; Vsigma is the strategy parameter of the continuous design variables
        SelectionScheme  = '+'           %Scheme chosen for performing the selection steps. Two options are available: '+' implies that the selection is performed  considering both the parents and offspring while ',' implies that the selection is based in the offspring population; pass as a string
    end
    
    properties (Hidden)
        ExitReasons = containers.Map([0, 1, 2, 3, 4],[
            "Change in objective function smaller than the defined tolerance.", ...
            "Maximum number of iterations reached.", ...
            "Maximum number of objective function evaluations reached.", ...
            "Maximum number of model evaluations reached.", ...
            "Change in design variables smaller than the defined tolerance."]);
    end
    
    methods
        varargout = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
                
        function obj = EvolutionStrategy(varargin)
            % EVOLUTIONSTRATEGY
            import opencossan.common.utilities.parseOptionalNameValuePairs;
            if nargin == 0
                super_args = {"MaxFunctionEvaluations", 1e5};
            else
                [optional, super_args] = parseOptionalNameValuePairs(...
                    ["Nmu", "Nlambda", "Nrho", "Sigma", "RecombinationStrategy", ...
                    "SelectionScheme", "MaxFunctionEvaluations"], ...
                    {10, 100, 2, 2, 'discrete', '+', 1e5}, varargin{:});
            end
            
            obj@opencossan.optimization.Optimizer(super_args{:});
            
            if nargin > 0
                obj.Nmu = optional.nmu;
                obj.Nlambda = optional.nlambda;
                obj.Nrho = optional.nrho;
                obj.Sigma = optional.sigma;
                obj.RecombinationStrategy = optional.recombinationstrategy;
                obj.SelectionScheme = optional.selectionscheme;
                obj.MaxFunctionEvaluations = optional.maxfunctionevaluations;
            end
             
            assert(obj.Nrho <= obj.Nmu, ...
                  'openCOSSAN:EvolutionStrategy', ...
                  'Number of individuals chosen for the recombination (%i) must be lower or equal to the population size (%i)', ...
                  obj.Nrho, obj.Nmu);
        end
    end
    
    methods (Access=private)
        offsprings = recombination(obj, parents)
        offsprings = mutation(obj, parents) 
        parents = selection(obj, parents, offspring)
    end
end
