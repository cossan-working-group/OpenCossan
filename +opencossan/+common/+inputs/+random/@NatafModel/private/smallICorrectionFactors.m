function factor = smallICorrectionFactors(~, rvj, rij)
    %SMALLICORRECTIONFACTORS Returns the seminalytical nataf model correction factors for
    %combinations including a small I distribution.
    
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
        case 'opencossan.common.inputs.random.SmallIRandomVariable'
            factor = 1.064 - 0.069 * rij + 0.005 * rij^2;
        case 'opencossan.common.inputs.random.ExponentialRandomVariable'
            factor = 1.142 + 0.154 * rij + 0.031 * rij ^2;
        case 'opencossan.common.inputs.random.UniformRandomVariable'
            factor = 1.055 + 0.015* rij ^2;
        case 'opencossan.common.inputs.random.RayleighRandomVariable'
            factor = 1.046 + 0.045 * rij + 0.006 * rij ^2;
        case 'opencossan.common.inputs.random.LognormalRandomVariable'
            factor = 1.029 - 0.001 * rij + 0.014 * rvj.CoV + 0.004 * rij^2 + ...
                0.233 * rvj.CoV^2 + 0.197 * rvj.CoV * rij;
        case 'opencossan.common.inputs.random.WeibullRandomVariable'
            factor = 1.064 - 0.065 * rij - 0.210 * rvj.CoV + 0.003 * rij^2 + ...
                0.356 * rvj.CoV^2 + 0.211 * rij * rvj.CoV;
        case 'opencossan.common.inputs.random.NormalRandomVariable'
            factor = 1.031;
        case 'opencossan.common.inputs.random.LargeIRandomVariable'
            factor = 1.064 + 0.069 * rij + 0.005 * rij^2;
        otherwise
            factor = NaN;
    end
end
