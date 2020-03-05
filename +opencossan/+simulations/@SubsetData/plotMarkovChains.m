function fh = plotMarkovChains(obj)
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
    
    fh = figure();
    hold on;
    box on;
    grid on;
    
    initialSamples = obj.Samples(obj.Samples.Level == 0, :);
    
    levels = length(unique(obj.Samples.Level));
    labels = strings(levels * 2 + 1, 0);
    
    scatter(initialSamples{:,1}, initialSamples{:,2}, '.');
    labels(1) = "Initial Samples";
    
    for i = 1:obj.NumberOfLevels
        levelSamples = obj.Samples(obj.Samples.Level == i, :);
        indices = levelSamples.Vg < obj.Thresholds(i);
        accepted = levelSamples(indices, 1:2);
        rejected = levelSamples(~indices, 1:2);
        
        scatter(accepted{:,1}, accepted{:, 2}, 'o');
        scatter(rejected{:, 1}, rejected{:, 2}, '*');
        
        labels((i-1) * 2 + 2) = sprintf("Level_%i (accepted)", i);
        labels((i-1) * 2 + 3) = sprintf("Level_%i (rejected)", i);
    end
    
    legend(labels, 'location', 'bestoutside');
    
    hold off;
end