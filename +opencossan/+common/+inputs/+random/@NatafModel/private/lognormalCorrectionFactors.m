function factor = lognormalCorrectionFactors(~, rvi, rvj, rij)
    %NORMALFACTOR Summary of this function goes here
    %   Detailed explanation goes here
    switch class(rvj)
        case 'opencossan.common.inputs.random.LognormalRandomVariable'
            factor = log(1 + rij * rvi.CoV * rvj.CoV) / ...
                (rij * sqrt(log(1 + rvi.CoV^2) * log(1 + rvj.CoV^2)));
        case 'opencossan.common.inputs.random.WeibullRandomVariable'
            factor = 1.026 + 0.082 * rij - 0.019 * rvi.CoV + 0.222 * rvj.CoV ...
                + 0.018 * rij^2 + 0.288 * rvi.CoV^2 + 0.379 * rvj.CoV^2 ...
                -0.441 * rij * rvi.CoV + 0.126 * rvi.CoV * rvj.CoV^2 - 0.277 * rij * rvj.CoV;
        case 'opencossan.common.inputs.random.NormalRandomVariable'
            factor = rvi.CoV / sqrt(log(1 + rvi.CoV^2));
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.019 + 0.010 * rij ^2 + 0.014 * rvi.CoV + 0.249 * rvi.CoV^2;
        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
            factor = 1.098 + 0.003 * rij + 0.019 * rvi.CoV + 0.025 * rij^2 + ...
                0.303 * rvi.CoV ^2 - 0.437 * rvi.CoV * rij;
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor =  1.011 + 0.001 * rij + 0.014 * rvi.CoV + 0.004 * rij^2 + ...
                0.231 * rvi.CoV^2 - 0.130 * rvi.CoV * rij;
        case 'opencossan.common.inputs.random.SmallIRandomVariable'
            factor = 1.029 - 0.001 * rij + 0.014 * rvi.CoV + 0.004 * rij^2 + ...
                0.233 * rvi.CoV^2 + 0.197 * rvi.CoV * rij;
        case 'opencossan.common.inputs.random.LargeIRandomVariable'
            factor = 1.029 + 0.001 * rij + 0.014 * rvi.CoV + 0.004 * rij^2 + ...
                0.233 * rvi.CoV^2 - 0.197 * rvi.CoV * rij;
        otherwise
            factor = NaN;
    end
end
