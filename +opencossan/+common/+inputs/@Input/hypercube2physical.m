function physical = hypercube2physical(obj, hypercube)
    %HYPERCUBE2PHISICAL This methods converts realization defined in the
    %hypercube in the phisical space
    %
    % See also: http://cossan.co.uk/wiki/index.php/hypercube2physical@Input
    %
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    physical = table();
    
    c = 1; % counter of columns
    
    % Map RandomVariables
    rvs = obj.RandomVariables;
    names = obj.RandomVariableNames;
    for i = 1:obj.NumberOfRandomVariables
        physical.(names(i)) = map2physical(rvs(i), norminv(hypercube(:, c)));
        c = c + 1;
    end
    
    % Map RandomVariableSets
    for set = obj.RandomVariableSets
        physical{:, set.Names} = map2physical(set, norminv(hypercube(:, c:c+set.Nrv-1)));
        c = c + set.Nrv;
    end

    % TODO: Add other inputs, e.g. GaussianMixture, StochasticProcess, etc.
end
