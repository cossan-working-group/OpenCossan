function samples = maprandomvariables(obj, input, factors)
    %MAPRANDOMVARIABLES Summary of this function goes here
    %   Detailed explanation goes here
    samples = array2table(obj.Perturbance * factors);
    samples.Properties.VariableNames = input.RandomInputNames;
    samples = input.map2physical(samples);
end

