function factor = normalCorrectionFactors(~, rvj)
    %NORMALFACTOR Summary of this function goes here
    %   Detailed explanation goes here
    switch class(rvj)
        case {'opencossan.common.inputs.random.LognormalRandomVariable', ...
                'opencossan.common.inputs.random.WeibullRandomVariable' }
            factor = rvj.CoV / sqrt(log(1 + rvj.CoV^2));
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.023;
        case {'opencossan.common.inputs.random.ExponentialRandomVariable', ...
                'opencossan.common.inputs.random.LargeIRandomVariable' }
            factor = 1.107;
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor = 1.014;
        case 'opencossan.common.inputs.random.SmallIRandomVariable'
            factor = 1.031;
        otherwise
            factor = NaN;
    end
end
