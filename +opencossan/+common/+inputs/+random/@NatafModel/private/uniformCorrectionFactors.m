function factor = uniformCorrectionFactors(~, rvj, rij)
    %NORMALFACTOR Summary of this function goes here
    %   Detailed explanation goes here
    switch class(rvj)
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.047 - 0.047 * rij^2;
        case 'opencossan.common.inputs.random.NormalRandomVariable'
            factor = 1.023;
        case 'opencossan.common.inputs.random.LogNormalRandomVariable'
            factor = 1.019 + 0.010 * rij ^2 +...
                0.014 * rvj.CoV + 0.249 * rvj.CoV^2;
        case 'opencossan.common.inputs.random.WeibullRandomVariable'
            factor = 1.033 + 0.305 * rvj.CoV ...
                + 0.074 * rij^2 + 0.405 * rvj.CoV^2;
        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
            factor = 1.133 + 0.029 * rij^2;
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor = 1.038 + 0.008 * rij ^2;
        case {'opencossan.common.inputs.random.SmallIRandomVariable', ...
                'opencossan.common.inputs.random.LargeIRandomVariable'}
            factor = 1.055 + 0.015* rij ^2;
        otherwise
            factor = NaN;
    end
end
