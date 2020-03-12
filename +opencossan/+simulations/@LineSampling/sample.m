function samples = sample(obj, varargin)
    %SAMPLE
    % This method generate a Samples object for the LineSampling.
    %
    % See also: https://cossan.co.uk/wiki/index.php/sample@LineSampling
    %
    % Author: Edoardo Patelli and Marco de Angelis
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
    
    [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs("input", varargin{:});
    optional = opencossan.common.utilities.parseOptionalNameValuePairs(...
        ["lines" "points"], {obj.NumberOfLines, obj.PointsOnLine}, varargin{:});
    
    validateattributes(required.input, {'opencossan.common.inputs.Input'}, {'scalar'});
    
    
    assert(~isempty(obj.Alpha), 'OpenCossan:LineSampling:sample', ...
        'Please define an important direction before running LineSampling.');
    
    assert(length(obj.Alpha) == required.input.NumberOfRandomInputs, 'OpenCossan:LineSampling:sample', ...
        'Important direction size incompatibel with input object.');
    
    %% Generate samples
    % sample points in a plane orthogonal to the important direction
    % (Xobj.Valpha) in a Standard Normal Space
    %
    % Generate random vector in the Standard Normal Space
    samplesInStdNorm = randn(required.input.NumberOfRandomInputs, optional.lines);
    % Compute the orthogonal vectors
    hyperPlanePoints = samplesInStdNorm - obj.Alpha * (obj.Alpha' * samplesInStdNorm);
    % Compute the distances from origin of the points on the hyperplane
    hpDistances = sqrt(sum(hyperPlanePoints.^2,1));
    % Sort the lines. This step is not mandatory. However it improves the
    % efficiency of the LineSampling adopting the adaptive option.
    % Furthermore it improves the stability of the CoV.
    [~, s2] = sort(hpDistances);
    hyperPlanePoints = hyperPlanePoints(:,s2);
    
    % Define the mesh. Points along the lines where the performance
    % function is evaluated
    hyperPlanePoints = repmat(hyperPlanePoints, length(optional.points), 1);
    alphaSet = repmat(obj.Alpha * optional.points , 1, optional.lines);
    lineSamplingPoints = reshape(hyperPlanePoints(:) + alphaSet(:), required.input.NumberOfRandomInputs, ...
        length(optional.points) * optional.lines);
    
    % Create the sample set
    samples = array2table(lineSamplingPoints');
    samples.Properties.VariableNames = required.input.RandomInputNames;
    samples = required.input.map2physical(samples);
    samples = required.input.addParametersToSamples(samples);
    samples = required.input.evaluateFunctionsOnSamples(samples);
    
end
