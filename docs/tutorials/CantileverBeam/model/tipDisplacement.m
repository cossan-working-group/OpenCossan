% This script computes the tips displacement (w) of the cantilever beam

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2019 COSSAN WORKING GROUP

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

% By running the loop in decreasing order, the struct array is fully initialized during the first run
for n = numel(Tinput):-1:1
    Toutput(n).w = (Tinput(n).rho * 9.81 * Tinput(n).b * Tinput(n).h * Tinput(n).L^4) / (8 * Tinput(n).E * Tinput(n).I) + ...
        (Tinput(n).P * Tinput(n).L^3) / (3 * Tinput(n).E * Tinput(n).I);
end
