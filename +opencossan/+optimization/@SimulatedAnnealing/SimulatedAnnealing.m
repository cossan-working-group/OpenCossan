classdef SimulatedAnnealing < opencossan.optimization.Optimizer
    %   SimulatedAnnealing (SA) is a gradient-free optimization method. SA can be used to find a
    %   MINIMUM of a function.
    
    properties
        InitialTemperature(1,:) double = 100  % Initial Temperature
        ReannealInterval(1,1) {mustBeInteger} = 100  % number of moves required to update the T
        TemperatureFunction(1,:) char {mustBeMember(TemperatureFunction, {'temperatureexp', ...
            'temperaturefast', 'temperatureboltz'})} = 'temperatureexp';  % Temperature function
        AnnealingFunction(1,:) char {mustBeMember(AnnealingFunction, {'annealingfast', ...
            'annealingboltz'})} = 'annealingboltz';    % Function used to generate new solution  for the next iteration.
        StallIterLimit(1,1) {mustBeInteger} = 2000;    %Maximum number of moves without improvement
    end
    
    properties (Hidden)
        ExitReasons = containers.Map([1, 5, 0, -1, -2, -5],[
            "Average change in the value of the objective function over options.MaxStallIterations iterations is less than options.FunctionTolerance.", ...
            "options.ObjectiveLimit limit reached.", ...
            "Maximum number of function evaluations or iterations reached.", ...
            "Optimization terminated by an output function or plot function.", ...
            "No feasible point found.", ...
            "Time limit exceeded."]);
    end
    
    methods
        function obj = SimulatedAnnealing(varargin)
            %SIMULATEDANNEALING
            
            import opencossan.common.utilities.parseOptionalNameValuePairs;
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = parseOptionalNameValuePairs(...
                    ["InitialTemperature", "ReannealInterval", "TemperatureFunction", ...
                    "AnnealingFunction", "StallIterLimit"], ...
                    {100, 100, 'temperatureexp', 'annealingboltz', 2000}, varargin{:});
            end
            
            obj@opencossan.optimization.Optimizer(super_args{:});
            
            if nargin > 0
                obj.InitialTemperature = optional.initialtemperature;
                obj.ReannealInterval = optional.reannealinterval;
                obj.TemperatureFunction = optional.temperaturefunction;
                obj.AnnealingFunction = optional.annealingfunction;
                obj.StallIterLimit = optional.stalliterlimit;
            end
        end
        
        optimum = apply(obj,varargin);
    end
    
end
