function factor = lognormalCorrectionFactors(~, rvi, rvj, rij)
    %LOGNORMALCORRECTIONFACTORS Returns the seminalytical nataf model correction factors for
    %combinations including a lognormal distribution.
    
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
