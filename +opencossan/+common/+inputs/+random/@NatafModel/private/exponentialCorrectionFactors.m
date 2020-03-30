function factor = exponentialCorrectionFactors(~, rvj, rij)
    %NORMALFACTOR Summary of this function goes here
    %   Detailed explanation goes here
    switch class(rvj)
        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
            factor = 1.229 - 0.367 * rij + 0.153* rij^2;
        case 'opencossan.common.inputs.random.NormalRandomVariable'
            factor = 1.107;
        case 'opencossan.common.inputs.random.LognormalRandomVariable'
            factor = 1.098 + 0.003 * rij + 0.019 * rvj.CoV + 0.025 * rij^2 + ...
                0.303 * rvj.CoV ^2 - 0.437 * rvj.CoV * rij;
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.133 + 0.029 * rij^2;
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor = 1.123 - 0.100 * rij + 0.021 * rij ^2;
        case 'opencossan.common.inputs.random.WeibullRandomVariable'
            factor = 1.109 - 0.152 * rij + 0.361 * rvj.CoV + 0.13 * rij^2 + ...
                0.455 * rvj.CoV^2 - 0.728 * rij * rvj.CoV;
        case 'opencossan.common.inputs.random.SmallIRandomVariable'
            factor = 1.142 + 0.154 * rij + 0.031 * rij ^2;
        case 'opencossan.common.inputs.random.LargeIRandomVariable'
            factor = 1.142 - 0.154 * rij + 0.031 * rij ^2;
        otherwise
            factor = NaN;
    end
end
