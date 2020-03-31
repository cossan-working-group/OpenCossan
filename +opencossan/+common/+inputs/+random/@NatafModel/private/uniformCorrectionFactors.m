function factor = uniformCorrectionFactors(~, rvj, rij)
    %UNIFORMCORRECTIONFACTORS Returns the seminalytical nataf model correction factors for
    %combinations including a uniform distribution.
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    switch class(rvj)
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.047 - 0.047 * rij^2;
        case 'opencossan.common.inputs.random.NormalRandomVariable'
            factor = 1.023;
        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
            factor = 1.133 + 0.029 * rij^2;
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor = 1.038 + 0.008 * rij ^2;
        case 'opencossan.common.inputs.random.LognormalRandomVariable'
            factor = 1.019 + 0.014 * rvj.CoV + 0.010 * rij ^2 + ...
                 + 0.249 * rvj.CoV^2;
        case {'opencossan.common.inputs.random.SmallIRandomVariable', ...
                'opencossan.common.inputs.random.LargeIRandomVariable'}
            factor = 1.055 + 0.015* rij ^2;
        case 'opencossan.common.inputs.random.WeibullRandomVariable'
            factor = 1.061 - 0.237 * rvj.CoV - 0.005 * rij^2 + 0.379 * rvj.CoV^2;
        otherwise
            factor = NaN;
    end
end
