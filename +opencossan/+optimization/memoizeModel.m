function model = memoizeModel(optProb, cacheSize)
    
    if isempty(optProb.Model)
        model = {};
        return
    end
    
    if nargin == 1
        cacheSize = 1000;
    end
    
    function output = evaluate(x)
        input = array2table(x);
        input.Properties.VariableNames = optProb.DesignVariableNames;
        input = optProb.Input.completeSamples(input);
        result = optProb.Model.apply(input);
        output = result.Samples;
        opencossan.optimization.OptimizationRecorder.recordModelEvaluations(output);
    end
    
    model = memoize(@(x) evaluate(x));
    model.CacheSize = cacheSize;
end
