function samples = sample(obj, varargin)
    %SAMPLE
    [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs("input", varargin{:});
    optional = opencossan.common.utilities.parseOptionalNameValuePairs("samples", {obj.NumberOfSamples}, varargin{:});
    
    validateattributes(required.input, {'opencossan.common.inputs.Input'}, {'scalar'});
    
    opencossan.OpenCossan.cossanDisp(sprintf("[SobolSampling] Samples: (%i, %i)", ...
        optional.samples, required.input.NumberOfRandomInputs),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[SobolSampling] Skip: %i", ...
        obj.Skip),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[SobolSampling] Leap: %i", ...
        obj.Leap),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[SobolSampling] Scramble: %s", ...
        string(obj.Scramble)),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[SobolSampling] PointOrder: %s", ...
        obj.PointOrder),3);
    
    qmc = sobolset(required.input.NumberOfRandomInputs,'Skip',obj.Skip,'Leap',obj.Leap);
    
    if obj.Scramble
        qmc = scramble(qmc, 'MatousekAffineOwen');
    end
    
    samplesInHyperCube = net(qmc, optional.samples);
    
    samples = array2table(norminv(samplesInHyperCube));
    samples.Properties.VariableNames = required.input.RandomInputNames;
    
    samples = required.input.map2physical(samples);
    samples = required.input.completeSamples(samples);    
end
