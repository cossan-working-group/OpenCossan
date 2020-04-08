function [samples, weights] = sampleWithDesignPoint(obj, varargin)
    %SAMPLEWITHDESIGNPOINT Summary of this function goes here
    %   Detailed explanation goes here
    [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs("input", varargin{:});
    optional = opencossan.common.utilities.parseOptionalNameValuePairs("samples", {obj.NumberOfSamples}, varargin{:});
    
    validateattributes(required.input, {'opencossan.common.inputs.Input'}, {'scalar'});
    validateattributes(optional.samples, {'numeric'}, {'scalar', 'integer'});
    
    assert(all(contains(obj.DesignPoint.Variables, required.input.RandomInputNames)), ...
        'OpenCossan:ImportanceSampling:sample', ...
        'Variables from the proposal distribution not found in the input.');
    
    beta = obj.DesignPoint.ReliabilityIndex;
    alpha = obj.DesignPoint.DirectionStdNormal;
    
    Zsns = randn(optional.samples, numel(alpha));
    Znorm = Zsns - (Zsns * alpha') * alpha;
    
    b = exp(-beta^2/2) / (normcdf(-beta) * sqrt(2 * pi));
    v = 2 * (b - beta);
    
    Zforced = normrnd(b, v, optional.samples, 1);
    Zis = Znorm + Zforced * alpha;
    
    weights = normpdf(Zforced) ./ normpdf(Zforced, b, v);
    
    samples = array2table(Zis);
    samples.Properties.VariableNames = obj.DesignPoint.Variables;
    samples = required.input.map2physical(samples);
    samples = required.input.completeSamples(samples);
end

