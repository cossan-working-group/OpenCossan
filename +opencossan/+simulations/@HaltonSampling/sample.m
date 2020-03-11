function samples = sample(obj, varargin)
    %SAMPLE Generate samples using the Halton algorithms
    %
    % See also: http://cossan.co.uk/wiki/index.php/sample@HaltonSampling
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
    
    [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs("input", varargin{:});
    optional = opencossan.common.utilities.parseOptionalNameValuePairs("samples", {obj.NumberOfSamples}, varargin{:});
    
    validateattributes(required.input, {'opencossan.common.inputs.Input'}, {'scalar'});
    
    opencossan.OpenCossan.cossanDisp(sprintf("[HaltonSampling] Samples: (%i, %i)", ...
        optional.samples, required.input.NumberOfRandomInputs),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[HaltonSampling] Skip: %i", ...
        obj.Skip),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[HaltonSampling] Leap: %i", ...
        obj.Leap),3);
    opencossan.OpenCossan.cossanDisp(sprintf("[HaltonSampling] Scramble: %s", ...
        string(obj.Scramble)),3);
    
    qmc = haltonset(required.input.NumberOfRandomInputs,'Skip',obj.Skip,'Leap',obj.Leap);
    
    if obj.Scramble
        qmc = scramble(qmc, 'RR2');
    end
    
    samplesInHyperCube = net(qmc, optional.samples);
    
    samples = required.input.hypercube2physical(samplesInHyperCube);
    samples = required.input.addParametersToSamples(samples);
    samples = required.input.evaluateFunctionsOnSamples(samples);
end
