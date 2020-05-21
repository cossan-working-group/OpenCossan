classdef ProbabilisticModel < opencossan.common.Model
    %PROBABILISTICMODEL COSSAN class to perform reliability analysis
    %   This class define a probabilistic model as a combination of a
    %   physical model (Model) and a performance function (PerformanceFunction).
    %   This class allows to estimate the failure probability associated to the
    %   Probabilistic Model adopting different Simulation objects
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    properties (Dependent=true)
        PerformanceFunctionVariable     % Name of the output of the performance function
        StdDeviationIndicatorFunction
    end
    
    methods
        function obj = ProbabilisticModel(varargin)
            %PROBABILISTICMODEL COSSAN class to perform reliability analysis
            %   This class define a probabilistic model as a combination of a
            %   physical model (Model) and a performance function (PerformanceFunction).
            %   This class allows to perform reliability analysis and uncertainty quantification
            
            if nargin == 0
                superArg = {};
            else
                [required, varargin] = ...
                    opencossan.common.utilities.parseRequiredNameValuePairs(...
                    "performancefunction", varargin{:});
                
                OptionalsArguments={"Model", []};
                
                [modelArg, superArg] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    [OptionalsArguments{:,1}],{OptionalsArguments{:,2}}, varargin{:});
                
                
            end
            
            obj@opencossan.common.Model(superArg{:});
            
            if ~isempty(modelArg.model)
                obj=modelArg.model;
            end
            
            % Add PerformanceFunction to Evaluator
            obj.Evaluator = obj.Evaluator.add('Solver',required.performancefunction);
            
        end
        
        function variable = get.PerformanceFunctionVariable(obj)
            % Return the name of the output of the performance function
            for i = 1:numel(obj.Evaluator.Solver)
                if isa(obj.Evaluator.Solver(i),'opencossan.reliability.PerformanceFunction')
                    variable = obj.Evaluator.Solver(i).OutputNames{:};
                    return;
                end
            end
        end
        
        function indicatorFunction = get.StdDeviationIndicatorFunction(obj)
            % Return the standard deviation indicator function of the
            % performance function
            for i = 1:numel(obj.Evaluator.Solver)
                if isa(obj.Evaluator.Solver(i),'opencossan.reliability.PerformanceFunction')
                    indicatorFunction = obj.Evaluator.Solver(i).StdDeviationIndicatorFunction;
                    return;
                end
            end
        end
        
        [pf, out] = computeFailureProbability(obj, Xsimulation);
        [designPoint, opt] = designPointIdentification(obj, varargin);
        [designPoint, opt] = HLRF(obj, varargin);
        [beta, MPoints, VpfValues] = lineSearch(obj, varargin);
    end
    
    methods (Access=private)
        Xop = prepareOptimizationProblem(Xpm,Mu0);
    end
end
