function designPoint = HLRF(obj, varargin)
    %HLRF This method computes the so-called design point adopting the gradient of
    %the function by means the linar approximations.
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/HLRF@ProbabilisticModel
    
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
    
    import opencossan.sensitivity.LocalSensitivityFiniteDifference
    import opencossan.sensitivity.LocalSensitivityMonteCarlo
    import opencossan.reliability.DesignPoint
    
    optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
        ["referencepoint", "alpha", "tolerance" "maxIterations", "usefinitedifferences"], ...
        {[], [], 1e-2, 10, true}, varargin{:});
    
    u = optional.referencepoint;
    if isempty(u)
        u = array2table(zeros(1, obj.Input.NumberOfRandomInputs));
        u.Properties.VariableNames = obj.Input.RandomInputNames;
    end
    
    alpha = optional.alpha;
    
    numberOfSamples= 0;
    iteration = 0;
    delta = Inf;
    
    while delta > optional.tolerance && iteration ~= optional.maxiterations
        iteration = iteration + 1;
        
        physical = obj.Input.map2physical(u);
        
        if optional.usefinitedifferences
            localSensitivity = LocalSensitivityFiniteDifference('Xtarget',obj, ...
                'Coutputname',{obj.PerformanceFunctionVariable}, ...
                'Cinputnames', obj.Input.RandomInputNames, 'VreferencePoint', physical);
        else
            if ~isempty(alpha)
                localSensitivity = LocalSensitivityMonteCarlo('Xtarget',obj, ...
                    'Coutputname',{obj.PerformanceFunctionVariable},...
                    'Cinputnames',obj.Input.RandomInputNames,'VreferencePoint',physical,...
                    'Valpha',alpha);
            else
                localSensitivity = LocalSensitivityMonteCarlo('Xtarget',obj, ...
                    'Coutputname',{obj.SperformanceFunctionVariable},...
                    'Cinputnames',obj.Input.RandomInputNames,'VreferencePoint',physical);
            end
        end
        
        % Compute the gradient
        [gradient, out] = localSensitivity.computeGradientStandardNormalSpace();
        numberOfSamples = numberOfSamples + out.NumberOfSamples;
        
        Vg = out.Samples.(obj.PerformanceFunctionVariable);
        if iteration == 1
            perfomanceAtOrigin = Vg(1);
        end
        
        evaluationPoint = obj.Input.map2stdnorm(gradient.VreferencePoint);
        evaluationPoint = evaluationPoint{:,:};
        
        alpha = gradient.Valpha;
        
        b = (evaluationPoint * alpha) * alpha';
        u{: , :} = b - Vg(1) / norm(gradient.Vgradient) * alpha';
        
        % Compute safety factor beta
        if iteration == 1
            beta_last  = norm(u{:,:});
        else
            beta  = norm(u{:,:});
            delta = abs((beta - beta_last) / beta_last);
            opencossan.OpenCossan.cossanDisp(sprintf('* %i Convergence factor %e ',iteration, delta),2)
            beta_last = beta;
        end
    end
    
    %% Construct the outputs
    designPoint = DesignPoint('Description','DesignPoint from HLRF algorithm', ...
        'performanceatorigin', perfomanceAtOrigin, ...
        'FunctionEvaluations', numberOfSamples, ...
        'designpoint', obj.Input.map2physical(u), ...
        'model', obj);
end