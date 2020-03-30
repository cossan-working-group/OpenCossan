function factor = largeICorrectionFactors(~, rvj, rij)
    %NORMALFACTOR Summary of this function goes here
    %   Detailed explanation goes here
    switch class(rvj)
        case 'opencossan.common.inputs.random.LargeIRandomVariable'
            factor = 1.064 - 0.069 * rij + 0.005 * rij^2;
        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
            factor = 1.142 - 0.154 * rij + 0.031 * rij ^2;
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.055 + 0.015 * rij ^2;
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor = 1.046 - 0.045 * rij + 0.006 * rij ^2;
        case 'opencossan.common.inputs.random.LognormalRandomVariable'
            factor = 1.029 + 0.001 * rij + 0.014 * rvj.CoV + 0.004 * rij^2 + ...
                0.233 * rvj.CoV^2 - 0.197 * rvj.CoV * rij;
        case 'opencossan.common.inputs.random.WeibullRandomVariable'
            factor = 1.056 - 0.06 * rij + 0.263 * rvj.CoV + 0.02 * rij^2 + ...
                0.383 * rvj.CoV^2 - 0.322 * rij * rvj.CoV;
        case 'opencossan.common.inputs.random.NormalRandomVariable'
            factor = 1.107;
        case 'opencossan.common.inputs.random.SmallIRandomVariable'
            factor = 1.064 + 0.069 * rij + 0.005 * rij^2;
        otherwise
            factor = NaN;
    end
end
