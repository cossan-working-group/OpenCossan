function model = memoizeModel(optProb, cacheSize)
    
    if isempty(optProb.Model)
        model = {};
        return
    end
    
    if nargin == 1
        cacheSize = 1000;
    end
    
    function output = evaluate(x)
        input = optProb.Input.setDesignVariable(...
            'CSnames', optProb.DesignVariableNames,...
            'Mvalues', x);
        result = optProb.Model.apply(input.getTable());
        output = result.TableValues;
        opencossan.optimization.OptimizationRecorder.recordModelEvaluations(output);
    end
    
    model = memoize(@(x) evaluate(x));
    model.CacheSize = cacheSize;
end
