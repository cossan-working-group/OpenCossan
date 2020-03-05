function fh = plotMarkovChains(obj, names)
    %PLOTMARKOVCHAIN This method plots the markov chains for each level of the
    %subset simulation
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/plot@SubsetOutput
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
    
    if ~exist('names', 'var')
        names = obj.Samples.Properties.VariableNames(1:2);
    end
    
    if length(names) == 2
        fh = plotMarkovChains2D(obj, names);
    else
        tbl = obj.Samples;
        for i = 1:obj.NumberOfLevels
            % Remove rejected values
            indices = (tbl.Level == i) & (tbl.Vg > obj.Thresholds(i));
            tbl(indices, :) = [];
        end
        fh = parallelplot(tbl, "CoordinateVariables", names, 'GroupVariable', 'Level', 'LineAlpha', 0.5);
    end
end

function fh = plotMarkovChains2D(obj, names)
    fh = figure();
    hold on;
    box on;
    grid on;
    
    x = names(1);
    y = names(2);
    
    initialSamples = obj.Samples(obj.Samples.Level == 1, :);
    
    levels = length(unique(obj.Samples.Level));
    labels = strings(levels * 2 + 1, 0);
    
    scatter(initialSamples{:, x}, initialSamples{:, y}, '.');
    labels(1) = "Level_1";
    
    for i = 2:obj.NumberOfLevels
        levelSamples = obj.Samples(obj.Samples.Level == i, :);
        indices = levelSamples.Vg < obj.Thresholds(i);
        accepted = levelSamples(indices, :);
        rejected = levelSamples(~indices, :);
        
        scatter(accepted{:, x}, accepted{:, y}, 'o');
        scatter(rejected{:, x}, rejected{:, y}, '*');
        
        labels((i-2) * 2 + 2) = sprintf("Level_%i (accepted)", i);
        labels((i-2) * 2 + 3) = sprintf("Level_%i (rejected)", i);
    end
    
    legend(labels, 'location', 'bestoutside');
    
    hold off;
end