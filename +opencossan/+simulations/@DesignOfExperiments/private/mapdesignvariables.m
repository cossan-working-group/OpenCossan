function samples = mapdesignvariables(obj, input, factors)
    %MAPDESIGNVARIABLES
    
    % The coordinates of the DOE points are transformed to actual values
    % using the following steps
        samples = zeros(size(factors));
        for idv = 1:input.NumberOfDesignVariables
            dv = input.DesignVariables(idv);
            
            % Xobj.LuseCurrentValues= TRUE => If MdoeFactor = 0, use CURRENT value of the DV
            if obj.UseCurrentValues
                % Identify the indices of zeros and other values
                zeroIndices = factors(:, idv) == 0;
                nonzeroIndices = find(factors(:, idv));
                
                % First map the zeros to the current values of the DVs
                samples(zeroIndices, idv) = dv.Value;
                
                if isa(dv, 'opencossan.optimization.ContinuousDesignVariable')
                    interval = dv.UpperBound - dv.LowerBound;
                    samples(nonzeroIndices,idv) = ...
                        dv.LowerBound + unifcdf(factors(nonzeroIndices, idv), -1, 1) .* interval;
                else
                    indices = unidinv(unifcdf(factors(nonzeroIndices, idv), -1, 1),...
                        length(dv.Support));
                    % Since unidinv returns NaN for zero, these are replaced woth the lowerbound, i.e.
                    % Vsupport(1) values
                    indices(isnan(indices)) = 1;
                    samples(nonzeroIndices, idv) = dv.Support(indices);
                end
                % Xobj.LuseCurrentValues = FALSE => If MdoeFactor = 0, use MEDIAN value of the interval of DV
            else
                if isa(dv, 'opencossan.optimization.ContinuousDesignVariable')
                    % For CONTINOUS DVs
                    interval = dv.UpperBound - dv.LowerBound;
                    samples(:, idv) = ...
                        dv.LowerBound + unifcdf(factors(:, idv), -1, 1) .* interval;
                else
                    % For DISCRETE DVs
                    indices = unidinv(unifcdf(factors(:, idv), -1, 1), length(dv.Support));
                    % Since unidinv returns NaN for zero, these are replaced woth the lowerbound, i.e.
                    % Vsupport(1) values
                    indices(isnan(indices)) = 1;
                    samples(:,idv) = dv.Support(indices);
                end
            end
        end
        
        samples = array2table(samples);
        samples.Properties.VariableNames = input.DesignVariableNames;
end

