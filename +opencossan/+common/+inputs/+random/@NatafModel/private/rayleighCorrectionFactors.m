function factor = rayleighCorrectionFactors(~, rvj, rij)
    %NORMALFACTOR Summary of this function goes here
    %   Detailed explanation goes here
    switch class(rvj)
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor = 1.028 - 0.029 * rij;
        case 'opencossan.common.inputs.random.LognormalRandomVariable'
            factor = 1.011 + 0.001 * rij + 0.014 * rvj.CoV + 0.004 * rij^2 + ...
                0.231 * rvj.CoV^2 - 0.130 * rvj.CoV * rij;
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.038 + 0.008 * rij ^2;
        case 'opencossan.common.inputs.random.WeibullRandomVariable'
            factor = 1.036 - 0.038 * rij +.266 * rvj.CoV + 0.028 * rij^2 + ...
                0.383 * rvj.CoV^2 -0.229 * rij * rvj.CoV;
        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
            factor = 1.123 - 0.100 * rij + 0.021 * rij ^2;
        case 'opencossan.common.inputs.random.NormalRandomVariable'
            factor = 1.014;
        case 'opencossan.common.inputs.random.SmallIRandomVariable'
            factor = 1.046 + 0.045 * rij + 0.006 * rij ^2;
        case 'opencossan.common.inputs.random.LargeIRandomVariable'
            factor = 1.046 - 0.045 * rij + 0.006 * rij ^2;
        otherwise
            factor = NaN;
    end
end
