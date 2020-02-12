classdef GeneticAlgorithms < opencossan.optimization.Optimizer
    %   GeneticAlgorithms is intended for solving an optimization problem by evaluating the
    %   objective function and constraints, i.e. gradients are not required.
    
    properties
        % Number of individuals in population
        PopulationSize(1,1) {mustBeInteger} = 20;
        % Number of elite individuals directly passed to the next generation
        EliteCount(1,1) {mustBeInteger} = 2;
        CrossoverFraction(1,1) double {mustBePositive, mustBeLessThanOrEqual(CrossoverFraction, 1)} = 0.8;
        StallGenLimit(1,1) {mustBeInteger} = 50;
        InitialPenalty(1,1) {mustBeInteger} = 10;
        FitnessScalingFcn(1,:) char {mustBeMember(FitnessScalingFcn, {'creationlinearfeasible', ...
            'fitscalingshiftlinear', 'fitscalingprop','fitscalingtop','fitscalingrank'})} = 'fitscalingrank';
        SelectionFcn(1,:) char {mustBeMember(SelectionFcn, {'selectionremainder', ...
            'selectionuniform', 'selectionstochunif', 'selectionroulette', ...
            'selectiontournament'})} = 'selectionstochunif';
        CrossoverFcn(1,:) char {mustBeMember(CrossoverFcn, {'crossoverheuristic', ...
            'crossoverscattered', 'crossoverintermediate', 'crossoversinglepoint', ...
            'crossovertwopoint', 'crossoverarithmetic'})} = 'crossoverscattered';
        MutationFcn(1,:) char {mustBeMember(MutationFcn, {'mutationuniform', ...
            'mutationadaptfeasible', 'mutationgaussian'})} = 'mutationgaussian';
        CreationFcn(1,:) char {mustBeMember(CreationFcn, {'gacreationuniform', ...
            'gacreationlinearfeasible'})} = 'gacreationlinearfeasible';
        MutationRate(1,1) double = 0.01;
        Scale(1,1) double = 1;
        Shrink(1,1) double = 1;
        ExtremeOptima(1,1) logical = false;
    end
    
    properties (Hidden)
        ExitReasons = containers.Map([4, 3, 2, 1, 0, -1, -2, -4, -5],[
            "Magnitude of step smaller than machine precision and constraint violation less than options.TolCon.", ...
            "The value of the fitness function did not change in options.StallGenLimit generations and constraint violation less than options.TolCon.", ...
            "Fitness limit reached and constraint violation less than options.TolCon.", ...
            "Average cumulative change in value of the fitness function over options.StallGenLimit generations less than options.TolFun and constraint violation less than options.TolCon.", ...
            "Maximum number of generations exceeded.", ...
            "Optimization terminated by the output or plot function.", ...
            "No feasible point found.", ...
            "Stall time limit exceeded.", ...
            "Time limit exceeded."]);
    end
    
    methods        
        function obj = GeneticAlgorithms(varargin)
            %GENETICALGORITHMS
            
            import opencossan.common.utilities.parseOptionalNameValuePairs;
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = parseOptionalNameValuePairs(...
                    ["PopulationSize", "EliteCount", "CrossoverFraction", "StallGenLimit", ...
                    "InitialPenalty", "FitnessScalingFcn", "SelectionFcn", "CrossoverFcn", ...
                    "MutationFcn", "CreationFcn", "MutationRate", "Scale", "Shrink", ...
                    "ExtremeOptima"], ...
                    {20, 2, 0.8, 50, 10, 'fitscalingrank', 'selectionstochunif', ...
                    'crossoverscattered', 'mutationgaussian', 'gacreationlinearfeasible', ...
                    0.01, 1, 1, false}, varargin{:});
            end
            
            obj@opencossan.optimization.Optimizer(super_args{:});
            
            if nargin > 0
                obj.PopulationSize = optional.populationsize;
                obj.EliteCount = optional.elitecount;
                obj.CrossoverFraction = optional.crossoverfraction;
                obj.StallGenLimit = optional.stallgenlimit;
                obj.InitialPenalty = optional.initialpenalty;
                obj.FitnessScalingFcn = optional.fitnessscalingfcn;
                obj.CrossoverFcn = optional.crossoverfcn;
                obj.MutationFcn = optional.mutationfcn;
                obj.CreationFcn = optional.creationfcn;
                obj.MutationRate = optional.mutationrate;
                obj.Scale = optional.scale;
                obj.Shrink = optional.shrink;
                obj.ExtremeOptima = optional.extremeoptima;
            end
        end
        
        optimum = apply(obj,varargin);
    end
end
