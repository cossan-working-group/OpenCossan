classdef StochasticRanking < opencossan.optimization.Optimizer
    %   Stochastic Ranking Evolution Strategies is a gradient-free optimization algorithm that
    %   performs a stochastic search in the space of the design variables, subject to non-linear
    %   inequality constraints.
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@StochasticRanking
    
    properties
        Mu(1,1) {mustBeInteger} = 10;            %number of individuals in parent population
        Lambda(1,1) {mustBeInteger} = 100           %Number of individuals in offspring population
        Rho(1,1) {mustBeInteger} = 2             %Number of individuals chosen for recombination, i.e. construction of intermediate parent
        WinProbability(1,1) double {mustBePositive, mustBeLessThanOrEqual(WinProbability, 1)} = 0.45;          %Probability of an individual of winning a rank exchange because of fitness comparison
        RecombinationStrategy(1,:) char {mustBeMember(RecombinationStrategy, ...
            {'discrete', 'intermediate'})} = 'discrete'; %Recombination strategy to be used. Available options are 'discrete' and 'intermediate'; pass as a string
    end
    
    properties (Hidden)
        ExitReasons = containers.Map([0, 1, 2],[
            "Objective function tolerance reached.", ...
            "Design variable tolerance reached.", ...
            "Maximum number of iterations reached."]);
    end
    
    methods
        varargout = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
        
        function obj = StochasticRanking(varargin)
            
            if nargin == 0
                super_args = {"MaxIterations", 2000};
            else
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["Mu", "Lambda", "Rho", "WinProbability", "RecombinationStrategy", ...
                    "MaxIterations"], ...
                    {10, 100, 2, 0.45, 'discrete', 2000}, varargin{:});
            end
            
            obj@opencossan.optimization.Optimizer(super_args{:});
            
            if nargin > 0
                obj.Mu = optional.mu;
                obj.Lambda = optional.lambda;
                obj.Rho = optional.rho;
                obj.WinProbability = optional.winprobability;
                obj.RecombinationStrategy = optional.recombinationstrategy;
                obj.MaxIterations = optional.maxiterations;
            end
            
            % Validate Inputs
            assert(obj.Rho <= obj.Mu, ...
                'openCOSSAN:StochasticRanking', ...
                'Number of individuals chosen for the recombination (%i) must be lower or equal to the population size (%i)', ...
                obj.Rho,obj.Mu);
        end
    end
    
    methods (Access=private)
        [SexitFlag,xb,Statistics,Gm] = sres(Xobj,objfun,cons,mm,lu,lambda,G,mu,pf,varphi) % directly taken from Philip Runarsson
        [Ldone,SexitFlag]=outputFunction(Xobj,Tstatus); %Export resutls and check termination criteria
    end
end

