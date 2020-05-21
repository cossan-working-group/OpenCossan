function simData = apply(obj, model)
    %APPLY Creates samples using the simulations object and applys the model to it.
    validateattributes(model, {'opencossan.common.Model'}, {'scalar'});
    
    samples = obj.sample('input', model.Input);
    simData = model.apply(samples);
end

