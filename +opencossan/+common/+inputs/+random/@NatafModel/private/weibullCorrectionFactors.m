function factor = weibullCorrectionFactors(~, rvi, rvj, rij)
    %WEIBULLCORRECTIONFACTORS Returns the seminalytical nataf model correction factors for
    %combinations including a weibull distribution.
    
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
        case 'opencossan.common.inputs.random.WeibullRandomVariable'
            covi = rvi.CoV;
            covj = rvj.CoV;
            factor = 1.086 + 0.054 * rij + 0.104 * (covi + covj) ...
                -0.055 * rij^2 + 0.662 * (covi^2 + covj^2) ...
                -0.57 * rij * (covi + covj) + 0.203 * (covi * covj) ...
                -0.02 * rij^3 - 0.218 * (covi^3 + covj^3) ...
                -0.371 * rij * (covi^2 + covj^2) + 0.257 * rij^2 * (covi + covj) ...
                +0.141 * (covi + covj) * covi * covj;
        case 'opencossan.common.inputs.random.NormalRandomVariable'
            factor = rvi.CoV / sqrt(log(1 + rvi^2));
        case 'opencossan.common.inputs.random.LognormalRandomVariable'
            covj = rvj.CoV;
            covi = rvi.CoV;
            factor = 1.026 + 0.082 * rij - 0.019 * covj + 0.222 * covi ...
                + 0.018 * rij^2 + 0.288 * covj^2 + 0.379 * covi^2 ...
                -0.441 * rij * covj + 0.126 * covj * covi^2 - 0.277 * rij * covi;
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.033 + 0.305 * rvi.CoV + 0.074*rij^2 + 0.405 * rvi.CoV^2;
        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
            factor = 1.109 - 0.152 * rij + 0.361 * rvi.CoV ...
                + 0.13 * rij^2 + 0.455 * rvi.CoV^2 - 0.728 * rij * rvi.CoV;
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor = 1.036 - 0.038*rij +.266 * rvi.CoV ...
                + 0.028 * rij^2 + 0.383 * rvi.CoV^2 -0.229 * rij * rvi.CoV;
        case 'opencossan.common.inputs.random.LargeIRandomVariable'
            factor = 1.056 - 0.06 * rij + ...
                0.263 * rvi.CoV + ...
                0.02 * rij^2 + ...
                0.383 * rvi.CoV^2 - ...
                0.322 * rij * rvi.CoV;
        case 'opencossan.common.inputs.random.SmallIRandomVariable'
            factor = 1.056 + 0.06 * rij + 0.263 * rvi.CoV^2 ...
                + 0.02 * rij^2 + 0.383 * rvi.CoV^2 + 0.322 * rij * rvi.CoV^2;
        otherwise
            factor = NaN;
    end
end
