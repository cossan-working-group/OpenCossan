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
            factor = 1.063 - 0.004 * rij - 0.200 * (covi + covj) - ...
                0.001 * rij^2 + 0.337 * (covi^2 + covj^2) + 0.007 * rij * (covi + covj) - ...
                0.007 * covi * covj;
        case 'opencossan.common.inputs.random.NormalRandomVariable'
            factor = 1.031 - 0.195 * rvi.CoV + 0.328 * rvi.CoV^2;
        case 'opencossan.common.inputs.random.LognormalRandomVariable'
            factor = 1.031 + 0.052 * rij + 0.011 * rvj.CoV - 0.210 * rvi.CoV + ...
                0.002 * rij^2 + 0.220 * rvj.CoV^2 + 0.350 * rvi.CoV^2 + ...
                0.005 * rij * rvj.CoV + 0.009 * rvj.CoV * rvi.CoV - 0.174 * rij * rvi.CoV;
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.061 - 0.237 * rvi.CoV - 0.005 * rij^2 + 0.379 * rvi.CoV^2;
        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
            factor = 1.147 + 0.145 * rij - 0.271 * rvi.CoV + 0.010 * rij^2 + ...
                0.459 * rvi.CoV^2 - 0.467 * rij * rvi.CoV;
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor = 1.047 + 0.042 * rij - 0.212 * rvi.CoV + 0.353 * rvi.CoV^2 - ...
                0.136 * rij * rvi.CoV;
        case 'opencossan.common.inputs.random.LargeIRandomVariable'
            factor = 1.064 + 0.065 * rij - 0.210 * rvi.CoV + 0.003 * rij^2 + ...
                0.356 * rvi.CoV^2 - 0.211 * rij * rvi.CoV;
        case 'opencossan.common.inputs.random.SmallIRandomVariable'
            factor = 1.064 - 0.065 * rij - 0.210 * rvi.CoV + 0.003 * rij^2 + ...
                0.356 * rvi.CoV^2 + 0.211 * rij * rvi.CoV;
        otherwise
            factor = NaN;
    end
end
