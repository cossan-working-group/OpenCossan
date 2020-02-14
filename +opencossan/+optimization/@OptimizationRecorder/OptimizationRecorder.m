classdef (Sealed) OptimizationRecorder < handle
    %OPTIMIZATIONRECORDER Singleton class to record results of constraint
    %and objective function evaluations during the optimization.
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2019 COSSAN WORKING GROUP

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
    
    properties
        % Results of constraint evaluations
        Constraints table = table();
        % Results of objective function evaluations
        ObjectiveFunction table = table();
        ModelEvaluations table = table();
    end
    
    properties (Dependent)
        % Number of constraint evaluations
        ConstraintEvaluations;
        % Number of objective function evaluations
        ObjectiveFunctionEvaluations;
    end
    
    methods (Access=private)
        % Private constructor for the singleton
        function obj = OptimizationRecorder()
        end
    end
    
    methods
        function evaluations = get.ConstraintEvaluations(obj)
            evaluations = height(obj.Constraints);
        end
        
        function evaluations = get.ObjectiveFunctionEvaluations(obj)
            evaluations = height(obj.ObjectiveFunction);
        end
    end
    
    methods (Static)
        function obj = getInstance()
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = opencossan.optimization.OptimizationRecorder();
            end
            obj = localObj;
        end
        
        function recordConstraints(variables, constraints)
            recorder = opencossan.optimization.OptimizationRecorder.getInstance();
            
            recorder.Constraints = [
                recorder.Constraints; ...
                table(variables,constraints,'VariableNames', ...
                {'DesignVariables', 'Constraints'})];
        end
        
        function recordObjectiveFunction(variables, objFcn)
            recorder = opencossan.optimization.OptimizationRecorder.getInstance();
            
            recorder.ObjectiveFunction = [
                recorder.ObjectiveFunction; ...
                table(variables,objFcn,'VariableNames', ...
                {'DesignVariables', 'ObjectiveFunction'})];
        end
        
        function recordModelEvaluations(model)
            recorder = opencossan.optimization.OptimizationRecorder.getInstance();
            recorder.ModelEvaluations = [
                recorder.ModelEvaluations; model];
        end
        
        function values = getModelEvaluation(names, values)
            recorder = opencossan.optimization.OptimizationRecorder.getInstance();
            if isempty(recorder.ModelEvaluations)
                values = [];
            else
                idx = all(table2array(recorder.ModelEvaluations(:, names)) == values,2);
                values = recorder.ModelEvaluations(idx,:);
            end
        end
        
        function clear()
            recorder = opencossan.optimization.OptimizationRecorder.getInstance();
            recorder.Constraints = table();
            recorder.ObjectiveFunction = table();
            recorder.ModelEvaluations = table();
        end
    end
end

